import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetmind_ai/features/meetings/presentation/providers/meeting_file_controller.dart';
import 'dart:io';

import '../../../../core/network/api_failure.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/error_feedback.dart';
import '../../../../core/widgets/empty_state.dart';

/// The meeting Details screen's "Files" tab — mirrors
/// `WorkspaceFileController`'s screen-side shape, scoped to one meeting.
class MeetingFilesTab extends ConsumerStatefulWidget {
  const MeetingFilesTab({super.key, required this.meetingId});

  final String meetingId;

  @override
  ConsumerState<MeetingFilesTab> createState() => _MeetingFilesTabState();
}

class _MeetingFilesTabState extends ConsumerState<MeetingFilesTab> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() => _uploading = true);
    await runOrNotify(
      context,
          () => ref.read(meetingFilesControllerProvider(widget.meetingId).notifier).upload(File(path)),
    );
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _confirmDelete(String fileId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove file?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await runOrNotify(
      context,
          () => ref.read(meetingFilesControllerProvider(widget.meetingId).notifier).delete(fileId),
    );
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(meetingFilesControllerProvider(widget.meetingId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.small(
        onPressed: _uploading ? null : _pickAndUpload,
        child: _uploading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.upload_file),
      ),
      body: files.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(ApiFailure.from(error).message)),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'No files yet',
              message: 'Tap the upload button to attach a file to this meeting.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(meetingFilesControllerProvider(widget.meetingId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final file = list[index];
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(file.originalFilename, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${_formatSize(file.size)} · ${file.uploadedBy.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(file.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
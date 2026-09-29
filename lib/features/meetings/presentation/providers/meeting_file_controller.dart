import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meeting_file.dart';
import 'meeting_file_providers.dart';

/// autoDispose + family by meetingId — the file list only matters while
/// the meeting's Files tab is open, mirroring `TaskCandidatesController`.
class MeetingFilesController extends AutoDisposeFamilyAsyncNotifier<List<MeetingFile>, String> {
  @override
  Future<List<MeetingFile>> build(String arg) => ref.read(listMeetingFilesUseCaseProvider)(arg);

  Future<void> upload(File file) async {
    await ref.read(uploadMeetingFileUseCaseProvider)(arg, file);
    await _reload();
  }

  Future<void> delete(String fileId) async {
    await ref.read(deleteMeetingFileUseCaseProvider)(arg, fileId);
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(listMeetingFilesUseCaseProvider)(arg));
  }
}

final meetingFilesControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MeetingFilesController, List<MeetingFile>, String>(MeetingFilesController.new);
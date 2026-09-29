import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/app_user.dart';

/// A file attached to a single meeting — the per-meeting "Files" tab.
/// Deliberately distinct from workspace-level files (see the `workspace`
/// feature's own file entity): this one is scoped to one meeting, same
/// distinction the backend draws between `MeetingFile` and `WorkspaceFile`.
class MeetingFile extends Equatable {
  const MeetingFile({
    required this.id,
    required this.meetingId,
    required this.originalFilename,
    required this.uploadedBy,
    required this.createdAt,
    this.size,
  });

  final String id;
  final String meetingId;
  final String originalFilename;
  final int? size;
  final AppUser uploadedBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, meetingId, originalFilename, size, uploadedBy, createdAt];
}
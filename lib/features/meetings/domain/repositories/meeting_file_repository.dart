import 'dart:io';

import '../entities/meeting_file.dart';

/// Implemented by data/repositories/meeting_file_repository_impl.dart.
abstract interface class MeetingFileRepository {
  Future<List<MeetingFile>> list(String meetingId);

  Future<MeetingFile> upload(String meetingId, File file);

  Future<void> delete(String meetingId, String fileId);
}
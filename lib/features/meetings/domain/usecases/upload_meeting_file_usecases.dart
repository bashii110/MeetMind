import 'dart:io';

import '../entities/meeting_file.dart';
import '../repositories/meeting_file_repository.dart';

class UploadMeetingFileUseCase {
  const UploadMeetingFileUseCase(this._repository);

  final MeetingFileRepository _repository;

  Future<MeetingFile> call(String meetingId, File file) => _repository.upload(meetingId, file);
}
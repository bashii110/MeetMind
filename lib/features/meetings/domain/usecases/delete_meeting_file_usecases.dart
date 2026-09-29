import '../repositories/meeting_file_repository.dart';

class DeleteMeetingFileUseCase {
  const DeleteMeetingFileUseCase(this._repository);

  final MeetingFileRepository _repository;

  Future<void> call(String meetingId, String fileId) => _repository.delete(meetingId, fileId);
}
import '../entities/meeting_file.dart';
import '../repositories/meeting_file_repository.dart';

class ListMeetingFilesUseCase {
  const ListMeetingFilesUseCase(this._repository);

  final MeetingFileRepository _repository;

  Future<List<MeetingFile>> call(String meetingId) => _repository.list(meetingId);
}
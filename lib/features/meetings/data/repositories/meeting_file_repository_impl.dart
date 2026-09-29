import 'dart:io';

import 'package:meetmind_ai/features/meetings/data/datasources/meeting_file_remote_datasource.dart';

import '../../domain/entities/meeting_file.dart';
import '../../domain/repositories/meeting_file_repository.dart';


class MeetingFileRepositoryImpl implements MeetingFileRepository {
  const MeetingFileRepositoryImpl(this._remote);

  final MeetingFileRemoteDataSource _remote;

  @override
  Future<List<MeetingFile>> list(String meetingId) => _remote.list(meetingId);

  @override
  Future<MeetingFile> upload(String meetingId, File file) => _remote.upload(meetingId, file);

  @override
  Future<void> delete(String meetingId, String fileId) => _remote.delete(meetingId, fileId);
}
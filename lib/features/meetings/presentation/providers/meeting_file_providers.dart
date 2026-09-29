import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetmind_ai/features/meetings/data/datasources/meeting_file_remote_datasource.dart';
import 'package:meetmind_ai/features/meetings/domain/usecases/delete_meeting_file_usecases.dart';
import 'package:meetmind_ai/features/meetings/domain/usecases/list_meeting_files_usecases.dart';
import 'package:meetmind_ai/features/meetings/domain/usecases/upload_meeting_file_usecases.dart';

import '../../../../core/di/providers.dart';
import '../../data/repositories/meeting_file_repository_impl.dart';
import '../../domain/repositories/meeting_file_repository.dart';

final meetingFileRemoteDataSourceProvider = Provider(
      (ref) => MeetingFileRemoteDataSource(ref.watch(dioProvider)),
);

final meetingFileRepositoryProvider = Provider<MeetingFileRepository>(
      (ref) => MeetingFileRepositoryImpl(ref.watch(meetingFileRemoteDataSourceProvider)),
);

final listMeetingFilesUseCaseProvider =
Provider((ref) => ListMeetingFilesUseCase(ref.watch(meetingFileRepositoryProvider)));
final uploadMeetingFileUseCaseProvider =
Provider((ref) => UploadMeetingFileUseCase(ref.watch(meetingFileRepositoryProvider)));
final deleteMeetingFileUseCaseProvider =
Provider((ref) => DeleteMeetingFileUseCase(ref.watch(meetingFileRepositoryProvider)));
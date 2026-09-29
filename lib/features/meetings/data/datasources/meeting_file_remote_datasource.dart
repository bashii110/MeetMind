import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../models/meeting_file_model.dart';

/// Talks to /meetings/{id}/files — see backend
/// MeetingFileController + routes/api.php.
class MeetingFileRemoteDataSource {
  const MeetingFileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MeetingFileModel>> list(String meetingId) async {
    final response = await _dio.get('/meetings/$meetingId/files');
    final list = response.data['data'] as List;
    return list.map((e) => MeetingFileModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MeetingFileModel> upload(String meetingId, dynamic file) async {
    final path = (file).path as String;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: p.basename(path)),
    });
    final response = await _dio.post('/meetings/$meetingId/files', data: form);
    return MeetingFileModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String meetingId, String fileId) {
    return _dio.delete('/meetings/$meetingId/files/$fileId');
  }
}
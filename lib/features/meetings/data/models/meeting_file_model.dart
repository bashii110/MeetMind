import '../../../auth/data/models/app_user_model.dart';
import '../../domain/entities/meeting_file.dart';

class MeetingFileModel extends MeetingFile {
  const MeetingFileModel({
    required super.id,
    required super.meetingId,
    required super.originalFilename,
    required super.uploadedBy,
    required super.createdAt,
    super.size,
  });

  factory MeetingFileModel.fromJson(Map<String, dynamic> json) {
    return MeetingFileModel(
      id: json['id'].toString(),
      meetingId: json['meeting_id'].toString(),
      originalFilename: json['original_filename'] as String? ?? 'file',
      size: json['size'] as int?,
      uploadedBy: AppUserModel.fromJson((json['uploaded_by'] as Map?)?.cast<String, dynamic>() ?? const {}),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
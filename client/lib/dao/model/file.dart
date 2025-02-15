import '../base/base_model.dart';

class FileUploadStatus {
  static const int PENDING = 0;
  static const int UPLOADING = 1;
  static const int COMPLETED = 2;
  static const int FAILED = 3;
}

class FileRecord implements BaseModel {
  final int? id;
  final String fileId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String fileType;
  final int uploadStatus;
  final String? messageId;
  final int createdAt;
  final int updatedAt;

  FileRecord({
    this.id,
    required this.fileId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.uploadStatus,
    this.messageId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_id': fileId,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'file_type': fileType,
      'upload_status': uploadStatus,
      'message_id': messageId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'files';

  factory FileRecord.fromMap(Map<String, dynamic> map) {
    return FileRecord(
      id: map['id'],
      fileId: map['file_id'],
      fileName: map['file_name'],
      filePath: map['file_path'],
      fileSize: map['file_size'],
      fileType: map['file_type'],
      uploadStatus: map['upload_status'],
      messageId: map['message_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

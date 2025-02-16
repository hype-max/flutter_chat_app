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
      'fileId': fileId,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadStatus': uploadStatus,
      'messageId': messageId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'files';

  factory FileRecord.fromMap(Map<String, dynamic> map) {
    return FileRecord(
      id: map['id'],
      fileId: map['fileId'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      fileSize: map['fileSize'],
      fileType: map['fileType'],
      uploadStatus: map['uploadStatus'],
      messageId: map['messageId'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../dao/model/message.dart';
import '../../api/chat_api.dart';

class FileMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;

  const FileMessageWidget({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  State<FileMessageWidget> createState() => _FileMessageWidgetState();
}

class _FileMessageWidgetState extends State<FileMessageWidget> {
  String? _localPath;
  bool _isLoading = false;
  final _chatApi = ChatApi();

  Future<void> _downloadFile() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final fileData = jsonDecode(widget.message.content);
      final fileId = fileData['fileId'];
      final fileName = fileData['fileName'];

      _localPath = await _chatApi.downloadFile(fileId, fileName);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // 打开文件
        final uri = Uri.file(_localPath!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载文件失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileData = jsonDecode(widget.message.content);
    final fileName = fileData['fileName'] ?? 'Unknown file';
    final fileSize = fileData['fileSize'] ?? 0;

    return GestureDetector(
      onTap: _downloadFile,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.insert_drive_file, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

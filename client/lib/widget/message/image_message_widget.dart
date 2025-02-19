import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../dao/model/message.dart';
import '../../api/chat_api.dart';

class ImageMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;

  const ImageMessageWidget({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  State<ImageMessageWidget> createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<ImageMessageWidget> {
  String? _localPath;
  bool _isLoading = false;
  final _chatApi = ChatApi();

  @override
  void initState() {
    super.initState();
    _downloadImage();
  }

  Future<void> _downloadImage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final imageData = jsonDecode(widget.message.content);
      final fileId = imageData['fileId'];
      final fileName = imageData['fileName'];

      _localPath = await _chatApi.downloadFile(fileId, fileName);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_localPath != null) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Image.file(File(_localPath!)),
            ),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _isLoading
              ? Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _localPath != null
                  ? Image.file(
                      File(_localPath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.red),
                      ),
                    ),
        ),
      ),
    );
  }
}

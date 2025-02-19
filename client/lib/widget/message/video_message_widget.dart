import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../dao/model/message.dart';
import '../../api/chat_api.dart';
import 'package:video_player/video_player.dart';

class VideoMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;

  const VideoMessageWidget({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _localPath;
  final _chatApi = ChatApi();

  @override
  void initState() {
    super.initState();
    _downloadAndInitVideo();
  }

  Future<void> _downloadAndInitVideo() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final videoData = jsonDecode(widget.message.content);
      final fileId = videoData['fileId'];
      final fileName = videoData['fileName'];

      _localPath = await _chatApi.downloadFile(fileId, fileName);
      
      _controller = VideoPlayerController.file(File(_localPath!));
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载视频失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isInitialized) {
      return Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 150,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

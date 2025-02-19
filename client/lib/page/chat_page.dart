import 'dart:convert';
import 'dart:io';
import 'package:chat_client/widget/message/image_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/mvc.dart';
import '../controller/chat_controller.dart';
import '../dao/model/message.dart';
import '../service/user_service.dart';
import '../widget/message/file_message_widget.dart';
import '../widget/message/audio_message_widget.dart';
import '../widget/message/video_message_widget.dart';
import '../widget/dialog/record_dialog.dart';

class ChatPage extends MvcView<ChatController> {
  const ChatPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: controller.isLoading && controller.messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(controller.messages[index]);
                  },
                ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildMessageItem(Message message) {
    final currentUser = UserService().currentUser;
    if (currentUser == null) return const SizedBox();

    final bool isMe = message.senderId == currentUser.id;
    var avatar = controller.getAvatar(message.senderId);
    var senderName = controller.getUsername(message.senderId) ?? '未知用户';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Container(
                  key: ValueKey(message.id),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildMessageContent(message),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    _formatTime(message.sendTime ?? 0),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    final bool isMe = message.senderId == UserService().currentUser?.id;
    switch (message.contentType) {
      case MessageContentType.TEXT:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        );
      case MessageContentType.IMAGE:
        return ImageMessageWidget(message: message, isMe: isMe);
      case MessageContentType.FILE:
        return FileMessageWidget(message: message, isMe: isMe);
      case MessageContentType.AUDIO:
        return AudioMessageWidget(message: message, isMe: isMe);
      case MessageContentType.VIDEO:
        return VideoMessageWidget(message: message, isMe: isMe);
      default:
        return Text(
          '不支持的消息类型',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        );
    }
  }

  Widget _buildInputBar() {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text('发送图片'),
                          onTap: () async {
                            Navigator.pop(context);
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              controller.uploadAndSendFile(
                                File(image.path),
                                MessageContentType.IMAGE,
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.video_library),
                          title: const Text('发送视频'),
                          onTap: () async {
                            Navigator.pop(context);
                            final ImagePicker picker = ImagePicker();
                            final XFile? video = await picker.pickVideo(
                                source: ImageSource.gallery);
                            if (video != null) {
                              controller.uploadAndSendFile(
                                File(video.path),
                                MessageContentType.VIDEO,
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mic),
                          title: const Text('发送语音'),
                          onTap: () async {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => RecordDialog(
                                onRecordComplete: (file) {
                                  controller.uploadAndSendFile(
                                    file,
                                    MessageContentType.AUDIO,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: const Text('发送文件'),
                          onTap: () async {
                            Navigator.pop(context);
                            final FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              final file = result.files.first;
                              if (file.path != null) {
                                controller.uploadAndSendFile(
                                  File(file.path!),
                                  MessageContentType.FILE,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: controller.sendMessage,
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays >= 7) {
        return '${time.month}-${time.day}';
      }
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

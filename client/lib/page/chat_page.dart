import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/chat_controller.dart';
import '../dao/model/message.dart';
import '../service/user_service.dart';

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
    switch (message.contentType) {
      case 1: // 文本消息
        return Text(
          message.content,
          style: TextStyle(
            color: message.senderId == UserService().currentUser?.id
                ? Colors.white
                : Colors.black,
          ),
        );
      case 2: // 图片消息
        return Image.network(
          message.content,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, color: Colors.red);
          },
        );
      case 3: // 文件消息
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_file),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.senderId == UserService().currentUser?.id
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ],
        );
      default:
        return Text(
          '不支持的消息类型',
          style: TextStyle(
            color: message.senderId == UserService().currentUser?.id
                ? Colors.white
                : Colors.black,
          ),
        );
    }
  }

  Widget _buildInputBar() {
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
                // TODO: 实现发送图片、文件等功能
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

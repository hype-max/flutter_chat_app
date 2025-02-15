import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/chat_controller.dart';
import '../dao/model/message.dart';

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
    final bool isMe = message.senderId == 'currentUserId'; // TODO: 获取当前用户ID
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _buildMessageStatus(message.status),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus(int status) {
    switch (status) {
      case MessageStatus.SENDING:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      case MessageStatus.SENT:
        return const Icon(
          Icons.check,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.DELIVERED:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.READ:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue,
        );
      case MessageStatus.FAILED:
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red,
        );
      default:
        return const SizedBox.shrink();
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: 显示更多功能菜单
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
    );
  }
}

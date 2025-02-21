import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/ai_chat_controller.dart';
import '../service/user_service.dart';

class AiChatPage extends MvcView<AiChatController> {
  const AiChatPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          PopupMenuButton<String>(
            onSelected: controller.setModel,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'deepseek-r1:1.5b',
                child: Text('DeepSeek'),
              ),
              const PopupMenuItem<String>(
                value: 'llama3.1:8b',
                child: Text('llama'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(controller.selectedModel),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
      ),
    );
  }

  Widget _buildMessageItem(dynamic message) {
    final currentUser = UserService().currentUser;
    if (currentUser == null) return const SizedBox();

    final bool isMe = message.senderId == currentUser.id;
    final bool isAi = message.senderId == -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: isAi ? Colors.purple : Colors.grey,
              child: Icon(
                isAi ? Icons.smart_toy : Icons.person,
                color: Colors.white,
              ),
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
                      isAi ? 'AI Assistant' : 'You',
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
                  child: Text(
                    message.content ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
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
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              child: Icon(Icons.person),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              minLines: 1,
              maxLines: 5,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  controller.sendMessage(text);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = controller.textController.text;
              if (text.trim().isNotEmpty) {
                controller.sendMessage(text);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

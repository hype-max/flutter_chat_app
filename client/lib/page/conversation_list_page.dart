import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/conversation_list_controller.dart';
import '../dao/model/conversation.dart';

class ConversationListPage extends MvcView<ConversationListController> {
  const ConversationListPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: controller.isLoading && controller.conversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: controller.conversations.length,
              itemBuilder: (context, index) {
                return _buildConversationItem(controller.conversations[index]);
              },
            ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: conversation.conversationAvatar != null
            ? NetworkImage(conversation.conversationAvatar!)
            : null,
        child: conversation.conversationAvatar == null
            ? Icon(
                conversation.conversationType == ConversationType.GROUP
                    ? Icons.group
                    : conversation.conversationType == ConversationType.AI
                        ? Icons.smart_toy
                        : Icons.person,
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.conversationName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(conversation.lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          if (conversation.unreadCount! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount! > 99
                    ? '99+'
                    : conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: () => controller.openChat(conversation),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
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

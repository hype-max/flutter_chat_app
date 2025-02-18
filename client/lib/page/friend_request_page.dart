import 'package:chat_client/dao/model/friend.dart';
import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/friend_request_controller.dart';

class FriendRequestPage extends MvcView<FriendRequestController> {
  const FriendRequestPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: controller.isLoading && controller.requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: controller.requests.length,
              itemBuilder: (context, index) {
                return _buildRequestItem(controller.requests[index]);
              },
            ),
    );
  }

  Widget _buildRequestItem(Friend request) {
    return ListTile(
      leading: CircleAvatar(
        child: !controller.hasAvatar(request.friendId!)
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(controller.getUser(request.friendId!)?.nickname ?? ""),
      subtitle:
          Text(request.status == FriendStatus.PENDING ? '请求添加你为好友' : '等待对方通过'),
      trailing: request.status == FriendStatus.PENDING
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    controller.rejectRequest(request);
                  },
                  child: const Text('拒绝'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.acceptRequest(request);
                  },
                  child: const Text('接受'),
                ),
              ],
            )
          : const Text('等待中'),
    );
  }
}

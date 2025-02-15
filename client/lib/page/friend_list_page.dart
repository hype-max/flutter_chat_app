import 'package:chat_client/dao/model/friend.dart';
import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/friend_list_controller.dart';
import '../dao/model/user.dart';

class FriendListPage extends MvcView<FriendListController> {
  const FriendListPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                ),
              ),
              title: const Text('新的朋友'),
              onTap: controller.openFriendRequests,
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 0),
          ),
          if (controller.isLoading && controller.friends.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildFriendItem(controller.friends[index]);
                },
                childCount: controller.friends.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(Friend friend) {
    var user = controller.getUser(friend.friendId);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user?.avatar != null ? NetworkImage(user!.avatar!) : null,
        child: user?.avatar == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user?.nickname ?? ""),
      subtitle: user?.signature != null
          ? Text(
              user!.signature!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => controller.openChat(user!),
    );
  }
}

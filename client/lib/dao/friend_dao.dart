import 'package:sqflite/sqflite.dart';
import 'base/base_dao.dart';
import 'model/friend.dart';

class FriendDao extends BaseDao<Friend> {
  @override
  Friend createModel(Map<String, dynamic> map) {
    return Friend.fromMap(map);
  }

  @override
  Future<Friend> getInstance() async {
    return Friend(
      userId: '',
      friendId: '',
      status: 0,
      createdAt: 0,
      updatedAt: 0,
    );
  }

  Future<List<Friend>> getFriends() async {
    return findWhere(
      where: 'status = ?',
      whereArgs: [1], // 1 表示已经是好友
      orderBy: 'nickname ASC',
    );
  }

  Future<List<Friend>> getFriendRequests() async {
    return findWhere(
      where: 'status = ?',
      whereArgs: [0], // 0 表示待处理的好友请求
      orderBy: 'created_at DESC',
    );
  }

  Future<void> updateFriendStatus(String friendId, int status) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET status = ?, updated_at = ? WHERE friend_id = ?',
      [status, now, friendId],
    );
  }

  Future<bool> isFriend(String friendId) async {
    final count = await this.count(
      where: 'friend_id = ? AND status = ?',
      whereArgs: [friendId, 1],
    );
    return count > 0;
  }

  Future<void> updateFriendInfo(String friendId, {String? nickname, String? avatar}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = <String>[];
    final args = <dynamic>[];

    if (nickname != null) {
      updates.add('nickname = ?');
      args.add(nickname);
    }
    if (avatar != null) {
      updates.add('avatar = ?');
      args.add(avatar);
    }
    updates.add('updated_at = ?');
    args.add(now);
    args.add(friendId);

    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET ${updates.join(', ')} WHERE friend_id = ?',
      args,
    );
  }
}

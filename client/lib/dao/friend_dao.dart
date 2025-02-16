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
    return Friend();
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
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> updateFriendStatus(int requestId, int status) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET status = ?, updatedTime = ? WHERE id = ?',
      [status, now, requestId],
    );
  }

  Future<bool> isFriend(String friendId) async {
    final count = await this.count(
      where: 'friendId = ? AND status = ?',
      whereArgs: [friendId, 1],
    );
    return count > 0;
  }

  Future<void> updateFriendInfo(String friendId,
      {String? nickname, String? avatar}) async {
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
    updates.add('updatedTime = ?');
    args.add(now);
    args.add(friendId);

    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET ${updates.join(', ')} WHERE friendId = ?',
      args,
    );
  }
}

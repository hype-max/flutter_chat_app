import '../entity/user.dart';
import '../utils/mvc.dart';
import '../dao/model/friend.dart';
import '../service/chat_service.dart';

class FriendRequest {
  final User user;
  final Friend friendRecord;
  final bool isIncoming;

  FriendRequest({
    required this.user,
    required this.friendRecord,
    required this.isIncoming,
  });
}

class FriendRequestController extends MvcContextController {
  final _chatService = ChatService();
  List<Friend> requests = [];
  bool isLoading = false;

  @override
  void initState(context) {
    super.initState(context);
    _chatService.friendStream.listen((requests) {
      loadRequests();
    });
    loadRequests();
  }

  Future<void> onRefresh() async {
    await loadRequests();
  }

  Future<void> loadRequests() async {
    isLoading = true;
    refreshView();
    try {
      requests = await _chatService.getFriendRequest();
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  Future<void> acceptRequest(int requestId) async {
    await _chatService.handleFriendRequest(requestId, true);
    await loadRequests();
  }

  Future<void> rejectRequest(int requestId) async {
    await _chatService.handleFriendRequest(requestId, false);
    await loadRequests();
  }

  User? getUser(int friendId) {
    return null;
  }

  bool hasUser(int userId) {
    return false;
  }

  bool hasAvatar(int friendId) {
    return false;
  }
}

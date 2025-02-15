import '../utils/mvc.dart';
import '../dao/model/friend.dart';
import '../dao/model/user.dart';
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
    _chatService.friendRequestsStream.listen((requests) {
      this.requests = requests;
      refreshView();
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
      await _chatService.getFriendRequests();
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  Future<void> acceptRequest(String friendId) async {
    await _chatService.handleFriendRequest(friendId, true);
  }

  Future<void> rejectRequest(String friendId) async {
    await _chatService.handleFriendRequest(friendId, false);
  }

  User? getUser(String friendId) {
    return null;
  }
  bool hasUser(String userId){
    return false;
  }

  bool hasAvatar(String friendId) {
    return false;
  }
}

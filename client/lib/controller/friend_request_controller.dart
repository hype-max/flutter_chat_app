import '../entity/user.dart';
import '../utils/mvc.dart';
import '../dao/model/friend.dart';
import '../service/chat_service.dart';
import '../api/chat_api.dart';

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
  final _chatApi = ChatApi();
  List<Friend> requests = [];
  final Map<int, User> _userCache = {};
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
      // Load user information for each request
      for (var request in requests) {
        if (request.friendId != null && !_userCache.containsKey(request.friendId)) {
          try {
            final user = await _chatApi.getUser(request.friendId!);
            _userCache[request.friendId!] = user;
          } catch (e) {
            print('Failed to load user info for id ${request.friendId}: $e');
          }
        }
      }
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  Future<void> acceptRequest(Friend request) async {
    await _chatService.handleFriendRequest(request, true);
    await loadRequests();
  }

  Future<void> rejectRequest(Friend request) async {
    await _chatService.handleFriendRequest(request, false);
    await loadRequests();
  }

  User? getUser(int friendId) {
    return _userCache[friendId];
  }

  bool hasUser(int userId) {
    return _userCache.containsKey(userId);
  }

  bool hasAvatar(int friendId) {
    final user = _userCache[friendId];
    return user?.avatarUrl != null;
  }

  String? getAvatar(int friendId) {
    final user = _userCache[friendId];
    return user?.avatarUrl;
  }
}

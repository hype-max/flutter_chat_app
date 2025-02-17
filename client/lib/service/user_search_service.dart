import '../api/user_api.dart';
import '../entity/user.dart';

class UserSearchService {
  final _userApi = UserApi();
  static final UserSearchService _instance = UserSearchService._internal();

  factory UserSearchService() {
    return _instance;
  }

  UserSearchService._internal();

  Future<List<User>> searchUsers(String keyword, {int page = 1, int size = 20}) async {
    if (keyword.trim().isEmpty) {
      return [];
    }
    return _userApi.searchUsers(keyword, page: page, size: size);
  }
}

import 'package:dio/dio.dart';
import '../entity/user.dart';

class UserApi {
  final Dio _dio;
  static final UserApi _instance = UserApi._internal();

  factory UserApi() {
    return _instance;
  }

  UserApi._internal() : _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'));

  Future<List<User>> searchUsers(String keyword, {int page = 1, int size = 20}) async {
    try {
      final response = await _dio.get('/user/search', queryParameters: {
        'keyword': keyword,
        'page': page,
        'size': size,
      });
      
      if (response.data['code'] == 200) {
        final List<dynamic> userList = response.data['data'];
        return userList.map((json) => User.fromJson(json)).toList();
      }
      throw Exception(response.data['msg'] ?? 'Search failed');
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

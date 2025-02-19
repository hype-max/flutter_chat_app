import 'dart:io';

import 'package:dio/dio.dart';
import '../entity/user.dart';
import '../service/user_service.dart';
import 'package:path_provider/path_provider.dart';

class ChatApi {
  static final ChatApi _instance = ChatApi._internal();
  late final Dio _dio;

  factory ChatApi() {
    return _instance;
  }

  ChatApi._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api/chat',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = UserService().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // 获取好友列表
  Future<List<User>> getFriends() async {
    try {
      final response = await _dio.get('/friends');
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('获取好友列表失败: $e');
    }
  }

  // 获取消息历史
  Future<List<Map<String, dynamic>>> getMessages({
    int? receiverId,
    int? groupId,
  }) async {
    try {
      final response = await _dio.get('/messages', queryParameters: {
        if (receiverId != null) 'receiverId': receiverId,
        if (groupId != null) 'groupId': groupId,
      });
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('获取消息历史失败: $e');
    }
  }

  // 获取好友申请列表
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      final response = await _dio.get('/friend-requests');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('获取好友申请列表失败: $e');
    }
  }

  // 发送好友申请
  Future<Map<String, dynamic>> sendFriendRequest(int friendId) async {
    try {
      final response = await _dio.post('/friend-request', queryParameters: {
        'friendId': friendId,
      });
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      throw Exception('发送好友申请失败: $e');
    }
  }

  // 获取用户信息
  Future<User> getUser(int userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      return User.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  // 上传文件
  Future<Map<String, dynamic>> uploadFile(
    File file,
    int messageId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'messageId': messageId,
      });
      final response = await _dio.post('/upload', data: formData);
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      throw Exception('上传文件失败: $e');
    }
  }

  Future handleFriendRequest(int requestId, bool accept) async {
    try {
    await _dio.put('/friend-request/$requestId?accept=$accept');
    } catch (e) {
      throw Exception('更新好友请求申请失败: $e');
    }
  }

  // 下载文件
  Future<String> downloadFile(int fileId, String fileName) async {
    try {
      final tempDir = await getApplicationCacheDirectory();
      final savePath = '${tempDir.path}/$fileName';
      
      await _dio.download(
        '/file/download/$fileId',
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      
      return savePath;
    } catch (e) {
      throw Exception('下载文件失败: $e');
    }
  }
}

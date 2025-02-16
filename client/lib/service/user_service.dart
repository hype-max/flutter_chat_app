import 'dart:io';
import 'package:dio/dio.dart';
import '../entity/user.dart';
import 'message_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  late final Dio _dio;
  String? _token;
  User? _currentUser;

  factory UserService() {
    return _instance;
  }

  UserService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data is Map && response.data['code'] == 200) {
          response.data = response.data['data'];
          return handler.next(response);
        }
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data is Map
                ? response.data['message'] ?? '请求失败'
                : '请求失败',
          ),
        );
      },
      onError: (error, handler) {
        String message;
        if (error.response?.data is Map &&
            error.response!.data['message'] != null) {
          message = error.response!.data['message'].toString();
        } else if (error.type == DioExceptionType.connectionTimeout) {
          message = '连接超时';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          message = '响应超时';
        } else {
          message = '请求失败';
        }
        print('Error: $message');
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: message,
          ),
        );
      },
    ));
  }

  String? get token => _token;

  User? get currentUser => _currentUser;

  void _setToken(String token) {
    _token = token;
  }

  Future<User> register({
    required String username,
    required String password,
    String? nickname,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/user/register',
        data: {
          'username': username,
          'password': password,
          if (nickname != null) 'nickname': nickname,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '注册失败');
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/user/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['token'] == null) {
        throw Exception('登录失败：未获取到token');
      }
      _setToken(data['token'].toString());
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '登录失败');
    }
  }

  Future<void> logout() async {
    if (_token == null) return;

    try {
      await _dio.post('/user/logout');
    } finally {
      _token = null;
      _currentUser = null;
      MessageService().disconnect();
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/user/info');
      _currentUser = User.fromJson(response.data as Map<String, dynamic>);
      return _currentUser!;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取用户信息失败');
    }
  }

  Future<User> updateUserInfo({
    String? nickname,
    String? signature,
    String? address,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.put(
        '/user/info',
        data: {
          'id': currentUser?.id,
          if (nickname != null) 'nickname': nickname,
          if (signature != null) 'signature': signature,
          if (address != null) 'address': address,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      _currentUser = User.fromJson(response.data as Map<String, dynamic>);
      return _currentUser!;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '更新用户信息失败');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/user/password',
        queryParameters: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '修改密码失败');
    }
  }

  Future<String> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post(
        '/user/avatar',
        data: formData,
      );

      final avatarUrl = response.data.toString();
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
      }
      return avatarUrl;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '上传头像失败');
    }
  }
}

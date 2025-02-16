import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../service/user_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  WebSocket? _webSocket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  factory MessageService() {
    return _instance;
  }

  MessageService._internal();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect() async {
    final token = UserService().token;
    if (token == null) {
      throw Exception('未登录');
    }
    _webSocket = await WebSocket.connect('ws://localhost:8080/chat', headers: {
      'Authorization': 'Bearer $token',
    });
    print("connect success");
    _webSocket?.listen(
      (dynamic data) {
        if (data is String) {
          _messageController.add(jsonDecode(data));
        }
      },
      onError: (error) {
        print("error");
        _webSocket = null;
        reconnect();
      },
      onDone: () {
        _webSocket = null;
      },
    );
  }

  Future<void> reconnect() async {
    if (_webSocket == null) {
      return;
    }
    await Future.delayed(const Duration(seconds: 5));
    try {
      await connect();
    } catch (e) {
      print('Reconnection failed: $e');
      reconnect();
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_webSocket == null) {
      throw Exception('WebSocket未连接');
    }
    _webSocket?.add(jsonEncode(message));
  }

  void dispose() {
    _webSocket?.close();
    _messageController.close();
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }
}

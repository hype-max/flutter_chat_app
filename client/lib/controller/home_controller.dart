import 'package:flutter/material.dart';
import '../service/hello_service.dart';
import '../utils/mvc.dart';
import 'dart:io';

class HomeController extends MvcContextController {
  var helloService = HelloService();
  var hello = "";
  WebSocket? _webSocket;
  String _message = '';
  List<String> messages = [];

  String get message => _message;
  set message(String value) {
    _message = value;
    refreshView();
  }

  @override
  void initState(BuildContext context) {
    super.initState(context);
    connectWebSocket();
    fetchData();
  }

  Future<void> connectWebSocket() async {
    try {
      _webSocket = await WebSocket.connect('ws://localhost:8080/chat');
      _webSocket?.listen(
        (dynamic data) {
          messages.add(data.toString());
          refreshView();
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _webSocket = null;
          refreshView();
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
    }
  }

  void sendMessage(String message) {
    if (_webSocket != null && message.isNotEmpty) {
      _webSocket?.add(message);
      message = '';
      refreshView();
    }
  }

  @override
  void onWidgetDispose() {
    _webSocket?.close();
    super.onWidgetDispose();
  }

  Future fetchData() async {
    hello = (await helloService.hello()) ?? '';
    refreshView();
  }
}

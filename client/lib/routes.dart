import 'package:flutter/material.dart';
import 'controller/friend_request_controller.dart';
import 'page/friend_request_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/friend_requests': (context) => FriendRequestPage(
            controller: FriendRequestController(),
          ),
    };
  }
}

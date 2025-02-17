import 'package:chat_client/controller/user_search_controller.dart';
import 'package:chat_client/dao/model/conversation.dart';
import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/chat_controller.dart';
import '../controller/main_controller.dart';
import '../controller/user_controller.dart';
import '../page/avatar_edit_page.dart';
import '../page/edit_profile_page.dart';
import '../page/friend_requests_page.dart';
import '../page/login_page.dart';
import '../page/main_page.dart';
import '../page/register_page.dart';
import '../page/user_profile_page.dart';
import '../page/chat_page.dart';
import '../page/user_search_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String editAvatar = '/edit-avatar';
  static const String friendRequests = '/friend_requests';
  static const String chat = '/chat';
  static const String userSearch = '/user/search';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginPage(
            controller: AuthController(),
          ),
      register: (context) => RegisterPage(controller: AuthController()),
      main: (context) => MainPage(
            controller: MainController(),
          ),
      profile: (context) => UserProfilePage(controller: UserController()),
      editProfile: (context) => EditProfilePage(controller: UserController()),
      editAvatar: (context) => AvatarEditPage(controller: UserController()),
      friendRequests: (context) => const FriendRequestsPage(),
      userSearch: (context) => UserSearchPage(
            controller: UserSearchController(),
          ),
      chat: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Conversation) {
          return ChatPage(controller: ChatController(args));
        }
        // 如果没有传递正确的参数，显示错误提示
        return const Scaffold(
          body: Center(
            child: Text('Invalid chat parameters'),
          ),
        );
      },
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('页面不存在'),
        ),
      ),
    );
  }
}

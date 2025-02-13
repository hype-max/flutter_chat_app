import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/main_controller.dart';
import '../controller/user_controller.dart';
import '../page/avatar_edit_page.dart';
import '../page/edit_profile_page.dart';
import '../page/login_page.dart';
import '../page/main_page.dart';
import '../page/register_page.dart';
import '../page/user_profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String editAvatar = '/edit-avatar';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginPage(controller: AuthController()),
      register: (context) => RegisterPage(controller: AuthController()),
      main: (context) => MainPage(
            controller: MainController(),
          ),
      profile: (context) => UserProfilePage(controller: UserController()),
      editProfile: (context) => EditProfilePage(controller: UserController()),
      editAvatar: (context) => AvatarEditPage(controller: UserController()),
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

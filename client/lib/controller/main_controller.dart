import 'package:flutter/material.dart';
import 'user_controller.dart';

class MainController extends UserController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var userController = UserController();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  void logout() {
    // TODO: Implement logout logic
    Navigator.pushReplacementNamed(context, '/login');
  }
}

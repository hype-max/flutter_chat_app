import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import 'conversation_list_controller.dart';
import 'user_controller.dart';

class MainController extends UserController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController();
  int currentIndex = 0;

  var conversationListController = ConversationListController();

  void onPageChanged(int index) {
    currentIndex = index;
    refreshView();
  }

  void switchTab(int index) {
    currentIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    refreshView();
  }

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

  @override
  void onWidgetDispose() {
    pageController.dispose();
    super.onWidgetDispose();
  }
}

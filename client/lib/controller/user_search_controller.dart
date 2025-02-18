import 'package:chat_client/controller/user_info_controller.dart';
import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../entity/user.dart';
import '../service/user_search_service.dart';
import '../page/user_info_page.dart';

class UserSearchController extends MvcContextController {
  final _userSearchService = UserSearchService();
  final TextEditingController searchController = TextEditingController();
  List<User> searchResults = [];
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchUsers() async {
    final keyword = searchController.text.trim();
    if (keyword.isEmpty) {
      searchResults = [];
      error = null;
      refreshView();
      return;
    }

    isLoading = true;
    error = null;
    refreshView();

    try {
      searchResults = await _userSearchService.searchUsers(keyword);
      error = null;
    } catch (e) {
      error = e.toString();
      searchResults = [];
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void viewUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoPage(
          controller: UserInfoController(user: user),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../utils/mvc.dart';

class AuthController extends MvcContextController {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var nicknameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  @override
  void didUpdateWidget(covariant MvcView<AuthController> oldWidget) {
    super.didUpdateWidget(oldWidget);
    usernameController = oldWidget.controller.usernameController;
    passwordController = oldWidget.controller.passwordController;
    confirmPasswordController = oldWidget.controller.confirmPasswordController;
    nicknameController = oldWidget.controller.nicknameController;
    emailController = oldWidget.controller.emailController;
    phoneController = oldWidget.controller.phoneController;
    _errorMessage = oldWidget.controller.errorMessage;
    _isLoading = oldWidget.controller.isLoading;
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty) {
      _setErrorMessage('请输入用户名');
      return;
    }
    if (passwordController.text.isEmpty) {
      _setErrorMessage('请输入密码');
      return;
    }

    _setErrorMessage(null);
    _setLoading(true);

    try {
      await UserService().login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register() async {
    if (usernameController.text.isEmpty) {
      _setErrorMessage('请输入用户名');
      return;
    }
    if (passwordController.text.isEmpty) {
      _setErrorMessage('请输入密码');
      return;
    }
    if (confirmPasswordController.text != passwordController.text) {
      _setErrorMessage('两次输入的密码不一致');
      return;
    }
    if (nicknameController.text.isEmpty) {
      _setErrorMessage('请输入昵称');
      return;
    }

    _setErrorMessage(null);
    _setLoading(true);

    try {
      await UserService().register(
        username: usernameController.text.trim(),
        password: passwordController.text,
        nickname: nicknameController.text.trim(),
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );
      Navigator.pop(context);
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }
}

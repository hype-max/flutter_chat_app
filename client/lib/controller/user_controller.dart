import 'dart:io';
import 'package:chat_client/entity/user.dart';
import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../utils/mvc.dart';

class UserController extends MvcContextController {
  final _userService = UserService();
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // 个人信息编辑控制器
  final nicknameController = TextEditingController();
  final signatureController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // 密码修改控制器
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  User? get currentUser {
    if (_currentUser == null) return null;
    // 如果头像URL不是以http开头，添加baseUrl前缀
    final avatarUrl = _currentUser!.avatarUrl;
    if (avatarUrl != null && !avatarUrl.startsWith('http')) {
      return _currentUser!.copyWith(
        avatarUrl: 'http://localhost:8080/${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl',
      );
    }
    return _currentUser;
  }

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    try {
      final user = await _userService.getCurrentUser();
        _updateUser(user);
      _initControllers();
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void _initControllers() {
    if (_currentUser == null) return;

    nicknameController.text = _currentUser!.nickname ?? '';
    signatureController.text = _currentUser!.signature ?? '';
    addressController.text = _currentUser!.address ?? '';
    emailController.text = _currentUser!.email ?? '';
    phoneController.text = _currentUser!.phone ?? '';
  }

  Future<void> updateProfile() async {
    if (nicknameController.text.isEmpty) {
      _setErrorMessage('昵称不能为空');
      return;
    }

    _setErrorMessage(null);
    _setLoading(true);

    try {
      final user = await _userService.updateUserInfo(
        nickname: nicknameController.text.trim(),
        signature: signatureController.text.trim().isNotEmpty
            ? signatureController.text.trim()
            : null,
        address: addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );
      _updateUser(user);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('个人信息更新成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword() async {
    if (oldPasswordController.text.isEmpty) {
      _setErrorMessage('请输入原密码');
      return;
    }
    if (newPasswordController.text.isEmpty) {
      _setErrorMessage('请输入新密码');
      return;
    }
    if (confirmPasswordController.text != newPasswordController.text) {
      _setErrorMessage('两次输入的新密码不一致');
      return;
    }

    _setErrorMessage(null);
    _setLoading(true);

    try {
      await _userService.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码修改成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadAvatar(File file) async {
    _setErrorMessage(null);
    _setLoading(true);

    try {
      final avatarUrl = await _userService.uploadAvatar(file);
      // 确保返回的URL是完整的
      final fullUrl = avatarUrl.startsWith('http')
          ? avatarUrl
          : 'http://localhost:8080${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl';
      _updateUser(_currentUser!.copyWith(avatarUrl: fullUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUserInfo() async {
    _setErrorMessage(null);
    _setLoading(true);

    try {
      final user = await _userService.getCurrentUser();
      _updateUser(user);
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  @override
  void onWidgetDispose() {
    nicknameController.dispose();
    signatureController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onWidgetDispose();
  }
}

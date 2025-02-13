import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/user_controller.dart';
import '../utils/mvc.dart';

class AvatarEditPage extends MvcView<UserController> {
  const AvatarEditPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('修改头像'),
      ),
      body: Column(
        children: [
          if (controller.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                controller.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          Expanded(
            child: Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 100)
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => _pickImage(context,ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('从相册选择'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => _pickImage(context,ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context,ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await controller.uploadAvatar(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: ${e.toString()}')),
        );
      }
    }
  }
}

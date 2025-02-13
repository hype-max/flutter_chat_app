import 'package:flutter/material.dart';
import '../controller/user_controller.dart';
import '../utils/mvc.dart';

class EditProfilePage extends MvcView<UserController> {
  const EditProfilePage({super.key, required super.controller});

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
        title: const Text('编辑资料'),
        actions: [
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: controller.updateProfile,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
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
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nicknameController,
            decoration: const InputDecoration(
              labelText: '昵称',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            enabled: !controller.isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.signatureController,
            decoration: const InputDecoration(
              labelText: '个性签名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            enabled: !controller.isLoading,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          const Text(
            '联系方式',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.addressController,
            decoration: const InputDecoration(
              labelText: '地址',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            enabled: !controller.isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.emailController,
            decoration: const InputDecoration(
              labelText: '邮箱',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            enabled: !controller.isLoading,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            enabled: !controller.isLoading,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

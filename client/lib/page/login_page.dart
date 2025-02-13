import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../utils/mvc.dart';

class LoginPage extends MvcView<AuthController> {
  const LoginPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '欢迎登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
              TextField(
                controller: controller.usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !controller.isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !controller.isLoading,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.login(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.isLoading ? null : controller.login,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () => Navigator.pushNamed(context, '/register'),
                child: const Text('没有账号？立即注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

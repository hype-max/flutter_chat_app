import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'controller/main_controller.dart';
import 'page/main_page.dart';
import 'routes/app_routes.dart';
import 'service/message_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '聊天',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: MainPage(
        controller: MainController(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'page/home_view.dart';
import 'controller/home_controller.dart';

void main() {
  runApp(MaterialApp(
    home: HomeView(controller: HomeController()),
  ));
}

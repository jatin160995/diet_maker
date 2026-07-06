import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/Screens/dashboard.dart';
import 'package:diet_maker/Screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/dasboard';
  static const login = '/login';
  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const Dashboard(),
    splash: (_) => const SplashScreen(),
    login: (_) => const Login(),
  };
}

import 'package:diet_maker/Screens/splash_screen.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        iconTheme: IconThemeData(color: white),
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'poppins',
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColor),
      ),
    );
  }
}

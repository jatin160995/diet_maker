import 'package:diet_maker/Screens/splash_screen.dart';
import 'package:diet_maker/routes/app_routes.dart';
import 'package:diet_maker/services/notification_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Initialize notifications
  await NotificationService.initialize();

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
      navigatorKey: navigatorKey,
      //home: SplashScreen(),
      navigatorObservers: [routeObserver],
      routes: AppRoutes.routes,
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

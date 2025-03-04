import 'package:expense_tracker/core/constants/images/images.dart';
import 'package:expense_tracker/features/home/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/common/functions.dart';


Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // var androidSettings = AndroidInitializationSettings('app_icon');
  // var initializationSettings = InitializationSettings(
  //   android: androidSettings,
  // );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    initializeNotifications();
    scheduleDailyReminder();
  }
  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreenWidget(),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void showCustomSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 2),
    ),
  );
}
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> scheduleDailyReminder() async {
  var time = Time(19, 0, 0); // 7:00 PM
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'daily_expense_channel',
    'Daily Expense Reminder',
    channelDescription: 'Reminder to record your daily expenses',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.showDailyAtTime(
    0, // notification ID
    'Expense Tracker',
    'Don\'t forget to record your expenses for today!',
    time,
    notificationDetails,
  );
}

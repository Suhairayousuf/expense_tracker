import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isReminderEnabled = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadReminderState();
    _initializeNotifications();
  }

  // Load the reminder state from SharedPreferences
  _loadReminderState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? false;
    });
  }

  // Initialize notifications
  _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedule a daily reminder
  Future<void> _scheduleDailyReminder() async {
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

  // Cancel the daily reminder
  Future<void> _cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(0); // Use the same notification ID
  }

  // Save the reminder state in SharedPreferences
  _saveReminderState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isReminderEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Enable Daily Reminder'),
            value: _isReminderEnabled,
            onChanged: (bool value) {
              setState(() {
                _isReminderEnabled = value;
              });
              _saveReminderState(value);

              if (value) {
                _scheduleDailyReminder();
              } else {
                _cancelDailyReminder();
              }
            },
          ),
        ],
      ),
    );
  }
}

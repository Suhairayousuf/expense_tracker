import 'package:expense_tracker/features/home/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../main.dart';
import '../../core/globals/globals.dart';
import '../auth/sign_in.dart';
   // Import your home page

class RoutingPage extends StatefulWidget {
  @override
  _RoutingPageState createState() => _RoutingPageState();
}

class _RoutingPageState extends State<RoutingPage> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalUserId = prefs.getString('userId');  // Get the user ID from SharedPreferences
    userName = prefs.getString('userName');  // Get the user ID from SharedPreferences

    if (globalUserId == null) {
      // If no user ID exists, navigate to the SignInPage
      _navigateToSignIn();
    } else {
      // If user ID exists, navigate to the Home Page
      _navigateToHome();
    }
  }

  void _navigateToSignIn() {
    // Navigate to the SignInPage if user is signing in for the first time
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()), // Replace with your actual sign-in page widget
    );
  }

  void _navigateToHome() {
    // Navigate to the Home Page if user is already signed in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NavigationBarPage()), // Replace with your actual home page widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()), // Show loading indicator while checking
    );
  }
}

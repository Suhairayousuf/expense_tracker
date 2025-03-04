import 'package:expense_tracker/core/pallette/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/globals/globals.dart';
import '../home/navigation_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    /// Start animation when the page is loaded
    _controller.forward();
  }

  /// Method to store phone number in SharedPreferences and globalUserId
  Future<void> _storeUserId(String phoneNumber,String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', phoneNumber); // Store phone number as userId
    await prefs.setString('name', name); // Store phone number as userId
    setState(() {
      globalUserId = phoneNumber; // Store globally
      userName = name; // Store globally
    });
  }

  /// Confirm Phone Number and name to navigate
  void _confirmPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text;
      String name = _name.text;

      // Save phone number in SharedPreferences and globalUserId
      await _storeUserId(phoneNumber,name);

      // Show confirmation SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number $phoneNumber confirmed!')),
      );

      /// Navigate to the Home page after confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationBarPage()), // Navigate to Home Page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text('Sign In',style: TextStyle(color: Colors.white),),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          // Background Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: -150 * _controller.value,
                left: -150 * _controller.value,
                child: Opacity(
                  opacity: 0.2 + 0.8 * _controller.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),

          // Main Form
          SlideTransition(
            position: _animation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Enter Your Detailes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'User Name',
                              // prefixText: '+1 ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              filled: true,
                              fillColor: Colors.purple.shade100,
                              contentPadding: EdgeInsets.all(15),
                            ),

                          ),
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              // prefixText: '+1 ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              filled: true,
                              fillColor: Colors.purple.shade100,
                              contentPadding: EdgeInsets.all(15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _confirmPhoneNumber,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            child: Text(
                              'Confirm',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

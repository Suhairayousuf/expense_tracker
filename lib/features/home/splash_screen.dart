import 'dart:async';

import 'package:expense_tracker/core/constants/images/images.dart';
import 'package:expense_tracker/features/home/routing_page.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/variables.dart';
import '../../core/pallette/pallete.dart';

class SplashScreenWidget extends StatefulWidget {

  const SplashScreenWidget({Key? key}) : super(key: key);

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {

@override
//   void didChangeDependencies() {
//     // TODO: implement didChangeDependencies
//     super.didChangeDependencies();
//     checkDate();
//     setState(() {
//
//     });
//
// }


  void initState() {
    
    super.initState();

    // Timer to move to the next screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => RoutingPage())
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,

      body: Center(

         child: Image.asset(ImageConstants.splashIcon,height: width*0.5,width: width*0.5,color: Colors.white,), // Splash logo
      ),
    );
  }
}

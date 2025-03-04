import 'package:expense_tracker/core/constants/images/images.dart';
import 'package:expense_tracker/core/globals/globals.dart';
import 'package:expense_tracker/features/expense/expense_history_screen.dart';
import 'package:expense_tracker/features/profile/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/variables.dart';

import '../../home/navigation_page.dart';





class ProfileWidget extends StatefulWidget {
  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    // var width= MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationBarPage(initialIndex: 0,),
          ),
              (route) => false,
        );
        return false; // Returning false ensures the current page will not pop.
      },
      child: Scaffold(

        body: Column(
          children: [
            SizedBox(height: 10,),
            _buildProfileHeader(),






            _buildMenuItem(Icons.receipt, "Expense Summary",1),
            SizedBox(height: 10,),


            _buildMenuItem(Icons.settings, "Settings",3, showRedDot: true,),
            SizedBox(height: 10,),
            // _buildMenuItem(Icons.delete, "Delete Account",7, showRedDot: true,),
            // SizedBox(height: 10,),

            // _buildUserId(width:width),
            SizedBox(height: 15,),

          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        // height: 130,
        width: width,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),top: Radius.circular(20) ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 30,
              child: Image.asset(ImageConstants.profilePic), // Replace with actual profile image
            ),
            SizedBox(width: 12),
            Container(
              // width: width*0.3,
              child: Text(userName==null?"No Username":userName.toString(),
                  style: TextStyle(color: Colors.white, fontSize: width*0.04, )),
            ),
            Text(globalUserId.toString(), style: TextStyle(color: Colors.white70, fontSize: width*0.04,fontWeight: FontWeight.w600)),

          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title,int type, {String? trailingText, bool showRedDot = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple,size: 30,),
      title: InkWell(onTap: (){
         if(type==1){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpenseHistoryScreen()));
         }else{
           Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage()));

         }
      },

          child: Text(title, style: GoogleFonts.poppins(fontSize: 19))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: GoogleFonts.poppins(color: Colors.green)),
          // if (showRedDot)
          //   Padding(
          //     padding: const EdgeInsets.only(left: 8),
          //     child: Icon(Icons.circle, color: Colors.red, size: 8),
          //   ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }


  // Widget for profile stats

}

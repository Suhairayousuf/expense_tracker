import 'package:expense_tracker/features/expense/expense_view.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../core/constants/variables.dart';
import '../../core/pallette/pallete.dart';
import '../expense/expense_history_screen.dart';
import '../expense/expense_list.dart';
import '../profile/screens/profile_screen.dart';

class NavigationBarPage extends StatefulWidget {
  final int initialIndex;

  const NavigationBarPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ExpenseScreen(),
    ExpenseListScreen(),
    ProfileWidget(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
          gap: 8,
          activeColor: Colors.white,
          color: Colors.grey.shade800,
          backgroundColor: Colors.white,
          tabBackgroundColor: primaryColor,
          padding: EdgeInsets.all(16),
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.list, text: 'List'),
            GButton(icon: Icons.person, text: 'profile'),
          ],
        ),
      ),
    );
  }
}

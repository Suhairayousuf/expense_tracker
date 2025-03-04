import 'package:expense_tracker/core/pallette/pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/db_helper.dart';
import '../../core/constants/variables.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';
import 'package:intl/intl.dart'; // Import intl package

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  double _totalExpense = 0;

  int _selectedIndex = 1;
  List<Map<String, dynamic>> _expenses = [];

  // Method to get expenses from the database
  Future<void> fetchExpenses() async {
    try {
      // Fetch expenses from the database
      final expenses = await DatabaseHelper.instance.getAllExpenses();

      // Convert the query result to a list that is mutable
      List<Map<String, dynamic>> mutableExpenses = List.from(expenses);

      // Sort expenses by date (most recent first)
      mutableExpenses.sort((a, b) {
        // Parse the date from the database fields
        DateTime dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
        DateTime dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);

        // Sort by date, descending (latest first)
        return dateB.compareTo(dateA);
      });

      // Update the total expense
      _totalExpense = mutableExpenses.fold(0, (sum, expense) => sum + (expense['amount'] ?? 0.0));

      // Only keep the most recent 7 expenses
      setState(() {
        _expenses = mutableExpenses.take(7).toList();
      });
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchExpenses(); // Fetch expenses initially
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) =>
              AlertDialog(
                title:  Text('Are you sure?',style: TextStyle(color: primaryColor)),
                content:  Text('Do you really want to Exit?',style: TextStyle()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No',style: TextStyle(color: primaryColor)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child:  Text('Yes',style: TextStyle(color: primaryColor),),
                  ),
                ],
              ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(
            "Home",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
           elevation: 0,
          // leading: Icon(Icons.menu, color: Colors.black),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: CircleAvatar(
          //       backgroundImage: AssetImage('assets/avatar.png'),
          //     ),
          //   )
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
      
      
              SizedBox(height: 10),
      
              // Centered Expense Total with Gradient
              Center(
                child: Container(
                  width: width,
                  height: width * 0.3,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Total Expense",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          "\$${_totalExpense.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(),
              SizedBox(height: 20),
              Text(
                'Recent Expenses',
                style: TextStyle(color: Colors.grey[600]),
              ),
              // List of Expenses
              Expanded(
                child: _expenses.isEmpty
                    ? Center(child: Text('No expenses added.'))
                    : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return expenseCard(
                      expense['date'],
                      expense['category'],
                      expense['description'],
                      expense['amount'],
                      expense['paymentType'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // When the new expense is added, navigate to the add screen
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpensePage()),
            );
            // After adding, fetch expenses again to update the UI
            fetchExpenses();
          },
          backgroundColor: primaryColor,
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  // Expense Card Widget
  Widget expenseCard(String date, String category, String description, double amount, String paymentType) {
    IconData categoryIcon;
    switch (category.toLowerCase()) {
      case 'shopping':
        categoryIcon = Icons.shopping_cart;
        break;
      case 'entertainment':
        categoryIcon = Icons.games;
        break;
      case 'transport':
        categoryIcon = Icons.directions_car;
        break;
      case 'food':
        categoryIcon = Icons.food_bank_outlined;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OpenContainer(
        closedColor: Colors.white,
        closedElevation: 5,
        openBuilder: (context, action) => ExpenseHistoryScreen(),
            // Scaffold(body: Center(child: Text("Details"))),
        closedBuilder: (context, action) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(categoryIcon, color: primaryColor, size: 28),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd MMM yyyy hh:mm a').format(DateTime.parse(date)), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 5),
                      Text(
                        category,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$$amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amount < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    paymentType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey
                    ),
                  ),
                  // Icon(
                  //   amount < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  //   color: amount < 0 ? Colors.red : Colors.green,
                  //   size: 20,
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

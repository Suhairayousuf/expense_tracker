import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/db_helper.dart';
import '../../core/pallette/pallete.dart';
import '../home/navigation_page.dart';
import 'expense_history_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Map<String, dynamic>> _expenses = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  // Fetch expenses from the database
  Future<void> fetchExpenses() async {
    try {
      final expenses = await DatabaseHelper.instance.getAllExpenses();
      List<Map<String, dynamic>> mutableExpenses = List.from(expenses);

      // Ensure the _endDate and _startDate are not null and are used in filtering
      if (_startDate != null && _endDate != null) {
        mutableExpenses = mutableExpenses.where((expense) {
          DateTime expenseDate = DateTime.parse(expense['date']);

          // Check if the expense date is within the selected date range
          return expenseDate.isAfter(_startDate!) && expenseDate.isBefore(_endDate!.add(Duration(days: 1)));
        }).toList();
      }

      // Sort expenses by date (most recent first)
      mutableExpenses.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
        DateTime dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _expenses = mutableExpenses;
      });
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  // Delete expense from the database
  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    fetchExpenses(); // Refresh list
  }

  // Edit expense details
  Future<void> editExpense(Map<String, dynamic> expense) async {
    TextEditingController amountController = TextEditingController(text: expense['amount'].toString());
    TextEditingController descriptionController = TextEditingController(text: expense['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double updatedAmount = double.tryParse(amountController.text) ?? expense['amount'];
                String updatedDescription = descriptionController.text;

                await DatabaseHelper.instance.updateExpense(
                    expense['id'], // First argument: ID
                    {
                      'amount': updatedAmount, // Second argument: Map with updated values
                      'description': updatedDescription,
                    }
                );

                fetchExpenses(); // Refresh list
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Show date picker for start date
  Future<void> _selectStartDate() async {
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedStart != null) {
      setState(() {
        _startDate = pickedStart;
      });
      fetchExpenses(); // Refresh list based on the selected start date
    }
  }

  // Show date picker for end date
  // Show date picker for end date
  Future<void> _selectEndDate() async {
    // Ensure the end date is selected after the start date
    final DateTime? pickedEnd = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000), // Ensure end date is after start date
      lastDate: DateTime(2101),
    );

    if (pickedEnd != null) {
      setState(() {
        // _endDate = pickedEnd.add(Duration(days: 1)); // Include the end date
        _endDate = pickedEnd; // Include the end date
      });
      fetchExpenses(); // Refresh list based on the selected end date
    }
  }


  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Expense List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: primaryColor,
          elevation: 0,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpenseHistoryScreen()));
                // Handle the button press (e.g., navigate to a summary screen)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Smaller padding for reduced size
              ),
              child: Text(
                'Summary',
                style: TextStyle(
                  fontSize: 12.0, // Smaller text size
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Text color
                ),
              ),
            ),
            SizedBox(width: 10,)

          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Start Date Button
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 ElevatedButton(
                   onPressed: _selectStartDate,
                   child: Text(_startDate == null
                       ? "Select Start Date"
                       : "${DateFormat('dd MMM yyyy').format(_startDate!)}"),
                 ),
                 SizedBox(width: 10),
                 // End Date Button
                 ElevatedButton(
                   onPressed: _selectEndDate,
                   child: Text(_endDate == null
                       ? "Select End Date"
                       : "${DateFormat('dd MMM yyyy').format(_endDate!)}"),
                 ),
               ],
             ),
              SizedBox(height: 10),
              Expanded(
                child: _expenses.isEmpty
                    ? Center(child: Text('No expenses added.'))
                    : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return expenseCard(expense);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Expense Card Widget
  Widget expenseCard(Map<String, dynamic> expense) {
    String date = expense['date'];
    String category = expense['category'];
    String description = expense['description'];
    double amount = expense['amount'];
    String paymentType = expense['paymentType'];
    int expenseId = expense['id'];

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
      child: Container(
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
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editExpense(expense),
                    ),
                    // Delete Button
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete Expense"),
                            content: Text("Are you sure you want to delete this expense?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteExpense(expenseId);
                                  Navigator.pop(context);
                                },
                                child: Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

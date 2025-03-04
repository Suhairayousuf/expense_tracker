import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/db_helper.dart';
import 'package:expense_tracker/core/constants/variables.dart';
import 'package:intl/intl.dart';
import '../../core/pallette/pallete.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  List<Map<String, dynamic>> _expenses = [];
  String _selectedPeriod = 'Monthly'; // Can be Weekly or Monthly
  String _selectedCategory = 'All'; // All or specific category
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now()); // Default to current month
  double _totalExpense = 0;

  // Method to fetch all expenses and categorize them
  Future<void> fetchExpenses() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    setState(() {
      _expenses = expenses;
      _totalExpense = _expenses.fold(0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    });
  }

  // Method to filter expenses by period (weekly/monthly)
  List<Map<String, dynamic>> getFilteredExpenses() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredExpenses = _expenses;

    if (_selectedPeriod == 'Weekly') {
      filteredExpenses = filteredExpenses.where((expense) {
        DateTime expenseDate = DateTime.parse(expense['date']);
        return expenseDate.isAfter(now.subtract(Duration(days: 7)));
      }).toList();
    } else if (_selectedPeriod == 'Monthly') {
      int selectedMonthIndex = DateFormat('MMMM').parse(_selectedMonth).month;
      filteredExpenses = filteredExpenses.where((expense) {
        DateTime expenseDate = DateTime.parse(expense['date']);
        return expenseDate.month == selectedMonthIndex && expenseDate.year == now.year;
      }).toList();
    }

    if (_selectedCategory != 'All') {
      filteredExpenses = filteredExpenses.where((expense) {
        return expense['category'] == _selectedCategory;
      }).toList();
    }

    return filteredExpenses;
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses(); // Fetch expenses when screen loads
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredExpenses = getFilteredExpenses();

    // Categorized summary data
    Map<String, double> categoryTotals = {};
    filteredExpenses.forEach((expense) {
      String category = expense['category'];
      double amount = expense['amount'] ?? 0.0;
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Expense History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor, // Use your app's primary color
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: 30),
            onPressed: () {
              // Filter options, can expand this if you need a custom filter dialog
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selection (Weekly/Monthly)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                  items: ['Weekly', 'Monthly'].map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),
                if (_selectedPeriod == 'Monthly')
                  DropdownButton<String>(
                    value: _selectedMonth,
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                    items: DateFormat('MMMM').dateSymbols.MONTHS.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month, style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  items: ['All', 'Food', 'Shopping', 'Transport', 'Entertainment', 'Other']
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),

              ],
            ),
            SizedBox(height: 20),
            // Total Expense and Categorized Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Total Expense: \$${_totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Reset filters
                      _selectedPeriod = 'Monthly';
                      _selectedCategory = 'All';
                      _selectedMonth = DateFormat('MMMM').format(DateTime.now());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Reset Filters',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Categorized summary list
            Expanded(
              child: ListView.builder(
                itemCount: categoryTotals.length,
                itemBuilder: (context, index) {
                  String category = categoryTotals.keys.elementAt(index);
                  double total = categoryTotals[category] ?? 0.0;
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
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(
                        categoryIcon,
                        color: primaryColor,
                        size: 30,
                      ),
                      title: Text(
                        category,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      trailing: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

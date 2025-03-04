import 'package:expense_tracker/core/pallette/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/common/functions.dart';
import '../../core/constants/db_helper.dart';
import '../../core/globals/globals.dart';
import '../../model/expense_model.dart';


class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String _amount = "";
  String _selectedPayment = "Cash";
  String _selectedCategory = "Shopping";
  String _description = "";
  TextEditingController descriptionController=TextEditingController();
  TextEditingController dateController=TextEditingController();

  final List<String> _paymentMethods = ["Cash", "Credit Card", "Debit Card"];
  final List<String> _categories = ["Shopping", "Food", "Transport", "Entertainment",'other'];

  void _onKeyPressed(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _amount += value;
    });
  }

  void _onDelete() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
      }
    });
  }
// Function to show confirmation popup
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Add Expense'),
          content: Text('Are you sure you want to add this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveExpense(); // Call the _addExpense function if confirmed
                Navigator.of(context).pop(); // Close the dialog after confirming
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveExpense() async {
    if (_amount.isNotEmpty) {
      // Get current date
      String currentDate = DateTime.now().toIso8601String();
      String formattedDate = (_selectedDate ?? DateTime.now()).toIso8601String();


      // Get the global userId (assuming globalUserId is a String)
      String? userId = globalUserId;  // Make sure globalUserId is defined somewhere

      // Create an ExpenseModel with the userId
      ExpenseModel newExpense = ExpenseModel(
        amount: double.parse(_amount),
        paymentType: _selectedPayment,
        description: _description,
        category: _selectedCategory,
        date: formattedDate,
        userId: userId.toString(),  // Pass the userId here
      );

      // Insert the expense into the database
      int id = await DatabaseHelper.instance.insertExpense(newExpense);
      print("Expense added with id: $id");

      // Optionally, clear the fields after saving
      setState(() {
        _amount = "";
        descriptionController.text = "";
        _selectedDate = null;
      });

      // Show a success message
      showCustomSnackbar(context, "Expense added successfully");
      Navigator.pop(context);
    }
  }
  DateTime? _selectedDate;
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Add Expense", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, Colors.indigo]),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Method & Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDropdown("Payment", _selectedPayment, _paymentMethods, (value) {
                            setState(() {
                              _selectedPayment = value;
                            });
                          }),
                          _buildDropdown("Category", _selectedCategory, _categories, (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Amount Display
                      Center(
                        child: Text(
                          "\$${_amount.isEmpty ? '0' : _amount}",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Description Field
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: "Add description...",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _description = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today, color: Colors.grey),
                                onPressed: () => _pickDate()
                            ),
                            hintText: "Select Date",
                            border: InputBorder.none,
                          ),

                          onChanged: (value) {
                            _description = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      Center(
                        child: GestureDetector(
                          onTap: (){
                            if(_amount.isNotEmpty && _description!="" ){
                              _showConfirmationDialog();
                            }else{
                              _amount.isEmpty?showCustomSnackbar(context,"Enter Amount"):
                              showCustomSnackbar(context,"Enter Description");
                            }

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Number Pad
          _buildNumberPad(),
        ],
      ),
    );
  }

  // Dropdown Builder
  Widget _buildDropdown(String label, String selected, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (value) => onChanged(value!),
            ),
          ),
        ),
      ],
    );
  }

  // Modern Number Pad
  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.6,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (index == 9) {
            return IconButton(
              icon: Icon(Icons.attach_money, color: Colors.green, size: 28),
              onPressed: () {},
            );
          } else if (index == 10) {
            return _buildNumberButton("0");
          } else if (index == 11) {
            return IconButton(
              icon: Icon(Icons.backspace, color: Colors.red, size: 28),
              onPressed: _onDelete,
            );
          } else {
            return _buildNumberButton("${index + 1}");
          }
        },
      ),
    );
  }

  // Rounded Number Button
  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onKeyPressed(number),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 5)],
        ),
        alignment: Alignment.center,
        margin: EdgeInsets.all(8),
        child: Text(
          number,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

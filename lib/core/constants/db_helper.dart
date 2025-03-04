import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../model/expense_model.dart';

class DatabaseHelper {
  // Private constructor
  DatabaseHelper._privateConstructor();

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenses.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the expenses table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        paymentType TEXT,
        category TEXT,
        description TEXT,
        date TEXT,
        userId TEXT

      )
    ''');
  }
  // Fetch all expenses
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await instance.database;
    return await db.query('expenses');
  }
  // Insert an expense
  Future<int> insertExpense(ExpenseModel expense) async {
    Database db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }
  // Method to delete an expense by ID
  Future<int> deleteExpense(int id) async {
    final db = await instance.database; // Get the database instance
    return await db.delete(
      'expenses', // Name of the table
      where: 'id = ?', // Condition to match the expense by ID
      whereArgs: [id], // Arguments for the condition (the ID)
    );
  }
  Future<int> updateExpense(int id, Map<String, dynamic> expense) async {
    final db = await instance.database;

    // Update the database table with the given values
    return await db.update(
      'expenses', // The name of the table
      expense, // The map containing the expense data to update
      where: 'id = ?', // The condition to match the expense by ID
      whereArgs: [id], // Arguments for the condition
    );
  }

}


// Other database operations (update, delete, etc.) can go here...


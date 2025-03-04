class ExpenseModel {
  final int? id;
  final double amount;
  final String paymentType;
  final String description;
  final String category;
  final String date;
  final String userId;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.paymentType,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
  });

  // Convert an ExpenseModel into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'paymentType': paymentType,
      'description': description,
      'category': category,
      'date': date,
      'userId': userId,
    };
  }

  // Convert a Map into an ExpenseModel.
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      amount: map['amount'],
      paymentType: map['paymentType'],
      description: map['description'],
      category: map['category'],
      date: map['date'],
      userId: map['userId'],
    );
  }

  // Copy an instance of ExpenseModel and allow modification of some fields
  ExpenseModel copyWith({
    int? id,
    double? amount,
    String? paymentType,
    String? description,
    String? category,
    String? date,
    String? userId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentType: paymentType ?? this.paymentType,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

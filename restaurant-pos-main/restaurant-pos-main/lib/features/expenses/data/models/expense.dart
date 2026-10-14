class Expense {
  final String id;
  final String category; // 'إيجار', 'كهرباء', 'غاز', 'رواتب', 'صيانة', 'وقود', 'أخرى'
  final double amount;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: (map['note'] as String?) ?? '',
    );
  }
}

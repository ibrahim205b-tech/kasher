import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    state = maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('expenses', expense.toMap());
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await loadExpenses();
  }
}

final expensesNotifierProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/employee.dart';
import '../../../expenses/data/models/expense.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';

class EmployeesNotifier extends StateNotifier<List<Employee>> {
  static const uuid = Uuid();
  final Ref ref;

  EmployeesNotifier(this.ref) : super([]) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('employees', orderBy: 'name ASC');
    state = maps.map((m) => Employee.fromMap(m)).toList();
  }

  Future<void> addEmployee(Employee employee) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('employees', employee.toMap());
    await loadEmployees();
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
    await loadEmployees();
  }

  Future<void> deleteEmployee(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
    await loadEmployees();
  }

  Future<void> paySalary(Employee employee) async {
    final now = DateTime.now();
    final updatedEmployee = employee.copyWith(lastPaidAt: now);
    await updateEmployee(updatedEmployee);

    // Automatically record an expense for the salary payment
    final salaryExpense = Expense(
      id: uuid.v4(),
      category: 'رواتب',
      amount: employee.salary,
      date: now,
      note: 'تسديد راتب الموظف: ${employee.name} (${employee.role})',
    );

    await ref.read(expensesNotifierProvider.notifier).addExpense(salaryExpense);
  }
}

final employeesNotifierProvider =
    StateNotifierProvider<EmployeesNotifier, List<Employee>>((ref) {
  return EmployeesNotifier(ref);
});

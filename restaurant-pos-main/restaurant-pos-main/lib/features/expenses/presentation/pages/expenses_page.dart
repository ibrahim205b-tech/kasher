import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/expense.dart';
import '../providers/expenses_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class ExpensesPage extends ConsumerWidget {
  static const uuid = Uuid();

  const ExpensesPage({super.key});

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'إيجار';
    final categories = ['إيجار', 'كهرباء', 'غاز', 'رواتب', 'صيانة', 'وقود', 'أخرى'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تسجيل مصروف جديد'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'فئة المصروف',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => category = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'المبلغ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات / البيان',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.trim().isEmpty) return;
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  final expense = Expense(
                    id: uuid.v4(),
                    category: category,
                    amount: amount,
                    date: DateTime.now(),
                    note: noteController.text.trim(),
                  );
                  await ref.read(expensesNotifierProvider.notifier).addExpense(expense);
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                },
                child: const Text('حفظ المصروف'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesNotifierProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    final totalExpensesAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('إدارة المصروفات التشغيلية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Total Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إجمالي المصروفات المسجلة:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                  Text(
                    CurrencyFormatter.format(totalExpensesAmount, currency: restaurantInfo.currency),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.error),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expenses List
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text('لا توجد مصروفات مسجلة حالياً'))
                  : ListView.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final exp = expenses[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: const Icon(Icons.outbox_rounded, color: AppColors.error),
                            ),
                            title: Text(
                              '${exp.category} ${exp.note.isNotEmpty ? "- ${exp.note}" : ""}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('التاريخ: ${DateFormatter.formatDateTime(exp.date)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyFormatter.format(exp.amount, currency: restaurantInfo.currency),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () async {
                                    await ref
                                        .read(expensesNotifierProvider.notifier)
                                        .deleteExpense(exp.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة مصروف جديد'),
        onPressed: () => _showAddExpenseDialog(context, ref),
      ),
    );
  }
}

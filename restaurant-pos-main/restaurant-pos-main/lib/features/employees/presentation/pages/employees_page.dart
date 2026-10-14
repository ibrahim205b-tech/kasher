import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/employee.dart';
import '../providers/employees_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';
import '../../../settings/services/printer_service.dart';

class EmployeesPage extends ConsumerWidget {
  static const uuid = Uuid();

  const EmployeesPage({super.key});

  void _showEmployeeFormDialog(BuildContext context, WidgetRef ref, {Employee? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final roleCtrl = TextEditingController(text: existing?.role ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final salaryCtrl = TextEditingController(text: existing != null ? '${existing.salary}' : '');
    PayType payType = existing?.payType ?? PayType.monthly;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'إضافة موظف جديد' : 'تعديل بيانات الموظف'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(labelText: 'الوظيفة / المسمى الوظيفي', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: salaryCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الراتب', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PayType>(
                    value: payType,
                    decoration: const InputDecoration(labelText: 'نوع الراتب', border: OutlineInputBorder()),
                    items: PayType.values.map((pt) {
                      return DropdownMenuItem(value: pt, child: Text(pt.nameArabic));
                    }).toList(),
                    onChanged: (val) => setState(() => payType = val!),
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
                  if (nameCtrl.text.trim().isEmpty || salaryCtrl.text.trim().isEmpty) return;
                  final salary = double.tryParse(salaryCtrl.text.trim()) ?? 0.0;

                  final emp = Employee(
                    id: existing?.id ?? uuid.v4(),
                    name: nameCtrl.text.trim(),
                    role: roleCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    salary: salary,
                    payType: payType,
                    lastPaidAt: existing?.lastPaidAt,
                  );

                  if (existing == null) {
                    await ref.read(employeesNotifierProvider.notifier).addEmployee(emp);
                  } else {
                    await ref.read(employeesNotifierProvider.notifier).updateEmployee(emp);
                  }

                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                },
                child: const Text('حفظ البيانات'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handlePaySalary(BuildContext context, WidgetRef ref, Employee employee) async {
    final restaurantInfo = ref.read(restaurantInfoProvider);

    await ref.read(employeesNotifierProvider.notifier).paySalary(employee);

    // Trigger printing salary slip thermal receipt
    final printed = await PrinterService.instance.printSalarySlip(
      employee: employee,
      info: restaurantInfo,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(printed
              ? 'تم تسديد الراتب وطباعة كشف الراتب بنجاح للموظف ${employee.name}'
              : 'تم تسديد الراتب (لم تتم الطباعة)'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesNotifierProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('إدارة الموظفين والرواتب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: employees.isEmpty
            ? const Center(child: Text('لا يوجد موظفين مسجلين حالياً'))
            : ListView.separated(
                itemCount: employees.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: themeState.accentColor.lightBackground,
                            child: Icon(Icons.person_rounded, color: primaryColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${emp.role} | هاتف: ${emp.phone}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الراتب: ${CurrencyFormatter.format(emp.salary, currency: restaurantInfo.currency)} (${emp.payType.nameArabic})',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                                if (emp.lastPaidAt != null)
                                  Text(
                                    'آخر صرف: ${DateFormatter.formatDate(emp.lastPaidAt!)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.success),
                                  ),
                              ],
                            ),
                          ),

                          // Pay Salary Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.payments_outlined, size: 18),
                            label: const Text('تسديد وطباعة كشف الراتب'),
                            onPressed: () => _handlePaySalary(context, ref, emp),
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEmployeeFormDialog(context, ref, existing: emp),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () async {
                              await ref
                                  .read(employeesNotifierProvider.notifier)
                                  .deleteEmployee(emp.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('إضافة موظف جديد'),
        onPressed: () => _showEmployeeFormDialog(context, ref),
      ),
    );
  }
}

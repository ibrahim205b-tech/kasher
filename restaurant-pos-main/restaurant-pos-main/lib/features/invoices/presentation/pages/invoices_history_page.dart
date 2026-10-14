import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/invoice.dart';
import '../providers/invoices_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';
import '../../../settings/services/printer_service.dart';

class InvoicesHistoryPage extends ConsumerWidget {
  const InvoicesHistoryPage({super.key});

  void _showCancelDialog(BuildContext context, WidgetRef ref, Invoice invoice) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إلغاء الفاتورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت أخصائي بتأكيد إلغاء الفاتورة ${invoice.invoiceNumber}؟'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإلغاء (مطلوب)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء الأمر'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              await ref
                  .read(invoicesNotifierProvider.notifier)
                  .cancelInvoice(invoice.id, reasonController.text.trim());
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, WidgetRef ref, Invoice invoice) {
    final restaurantInfo = ref.read(restaurantInfoProvider);
    final themeState = ref.read(themeSettingsProvider);
    final primaryColor = themeState.accentColor.color;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('تفاصيل الفاتورة ${invoice.invoiceNumber}'),
            Chip(
              label: Text(
                invoice.isPaid ? 'مدفوعة' : 'ملغاة',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: invoice.isPaid ? AppColors.success : AppColors.error,
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('التاريخ: ${DateFormatter.formatDateTime(invoice.createdAt)}'),
              if (invoice.cancelReason != null)
                Text(
                  'سبب الإلغاء: ${invoice.cancelReason}',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              SizedBox(
                height: 220,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invoice.items.length,
                  itemBuilder: (ctx, index) {
                    final item = invoice.items[index];
                    return ListTile(
                      dense: true,
                      title: Text('${item.itemName} x${item.quantity}'),
                      subtitle: item.extrasText != null ? Text(item.extrasText!) : null,
                      trailing: Text(
                        CurrencyFormatter.format(item.lineTotal, currency: restaurantInfo.currency),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    CurrencyFormatter.format(invoice.grandTotal, currency: restaurantInfo.currency),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            icon: const Icon(Icons.print_rounded, color: Colors.white),
            label: const Text('إعادة الطباعة الحرارية', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final printed = await PrinterService.instance.printInvoice(
                invoice: invoice,
                info: restaurantInfo,
              );
              if (dialogCtx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(printed ? 'تم إعادة الطباعة' : 'فشلت الطباعة (تأكد من البلوتوث)'),
                    backgroundColor: printed ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesState = ref.watch(invoicesNotifierProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('أرشيف الفواتير والمبيعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(invoicesNotifierProvider.notifier).loadInvoices();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search & Filters Header
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      ref.read(invoicesNotifierProvider.notifier).updateSearch(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث برقم الفاتورة (مثال: INV-0001)...',
                      prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                  label: const Text('تصفية بالتاريخ', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (range != null) {
                      ref
                          .read(invoicesNotifierProvider.notifier)
                          .setDateRange(range.start, range.end);
                    }
                  },
                ),
                if (invoicesState.startDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.error),
                    onPressed: () {
                      ref.read(invoicesNotifierProvider.notifier).clearDateRange();
                    },
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Invoices Table
            Expanded(
              child: invoicesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : invoicesState.invoices.isEmpty
                      ? const Center(child: Text('لا توجد فواتير مطابقة'))
                      : ListView.separated(
                          itemCount: invoicesState.invoices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final inv = invoicesState.invoices[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.borderLight),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: inv.isPaid
                                      ? themeState.accentColor.lightBackground
                                      : Colors.red.shade50,
                                  child: Icon(
                                    inv.isPaid
                                        ? Icons.receipt_rounded
                                        : Icons.cancel_outlined,
                                    color: inv.isPaid ? primaryColor : AppColors.error,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      inv.invoiceNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Chip(
                                      label: Text(
                                        inv.isPaid ? 'مدفوعة' : 'ملغاة',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: inv.isPaid ? Colors.green.shade800 : Colors.red.shade800,
                                        ),
                                      ),
                                      backgroundColor: inv.isPaid ? Colors.green.shade50 : Colors.red.shade50,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'تاريخ: ${DateFormatter.formatDateTime(inv.createdAt)} | الأصناف: ${inv.items.length}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(inv.grandTotal, currency: restaurantInfo.currency),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye_outlined),
                                      onPressed: () => _showInvoiceDetails(context, ref, inv),
                                    ),
                                    if (inv.isPaid)
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                        onPressed: () => _showCancelDialog(context, ref, inv),
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
    );
  }
}

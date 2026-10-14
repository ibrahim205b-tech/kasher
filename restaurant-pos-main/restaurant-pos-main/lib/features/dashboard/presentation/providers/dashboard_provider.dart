import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../invoices/presentation/providers/invoices_provider.dart';
import '../../../invoices/data/models/invoice.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';

enum DashboardTimePeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension DashboardTimePeriodExtension on DashboardTimePeriod {
  String get nameArabic {
    switch (this) {
      case DashboardTimePeriod.today:
        return 'اليوم';
      case DashboardTimePeriod.thisWeek:
        return 'هذا الأسبوع';
      case DashboardTimePeriod.thisMonth:
        return 'هذا الشهر';
      case DashboardTimePeriod.thisYear:
        return 'هذه السنة';
      case DashboardTimePeriod.custom:
        return 'فترة مخصصة';
    }
  }
}

class DashboardMetrics {
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final int totalInvoices;
  final double averageInvoiceValue;
  final Map<String, int> topSellingItems; // Item Name -> Qty Sold

  DashboardMetrics({
    required this.totalSales,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalInvoices,
    required this.averageInvoiceValue,
    required this.topSellingItems,
  });
}

final dashboardPeriodProvider =
    StateProvider<DashboardTimePeriod>((ref) => DashboardTimePeriod.today);

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final invoicesState = ref.watch(invoicesNotifierProvider);
  final expenses = ref.watch(expensesNotifierProvider);
  final period = ref.watch(dashboardPeriodProvider);

  final now = DateTime.now();
  DateTime start;
  DateTime end = now;

  switch (period) {
    case DashboardTimePeriod.today:
      start = DateTime(now.year, now.month, now.day);
      break;
    case DashboardTimePeriod.thisWeek:
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
      break;
    case DashboardTimePeriod.thisMonth:
      start = DateTime(now.year, now.month, 1);
      break;
    case DashboardTimePeriod.thisYear:
      start = DateTime(now.year, 1, 1);
      break;
    case DashboardTimePeriod.custom:
      start = invoicesState.startDate ?? DateTime(now.year, now.month, 1);
      end = invoicesState.endDate ?? now;
      break;
  }

  // Filter Paid Invoices in period
  final filteredInvoices = invoicesState.invoices.where((inv) {
    return inv.isPaid &&
        inv.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
        inv.createdAt.isBefore(end.add(const Duration(days: 1)));
  }).toList();

  // Filter Expenses in period
  final filteredExpenses = expenses.where((exp) {
    return exp.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        exp.date.isBefore(end.add(const Duration(days: 1)));
  }).toList();

  final double totalSales =
      filteredInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

  final double totalExpenses =
      filteredExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

  final double netProfit = totalSales - totalExpenses;
  final int totalInvoices = filteredInvoices.length;
  final double averageInvoiceValue =
      totalInvoices > 0 ? (totalSales / totalInvoices) : 0.0;

  // Top Selling Items
  final Map<String, int> topItemsMap = {};
  for (final inv in filteredInvoices) {
    for (final item in inv.items) {
      topItemsMap[item.itemName] =
          (topItemsMap[item.itemName] ?? 0) + item.quantity;
    }
  }

  return DashboardMetrics(
    totalSales: totalSales,
    totalExpenses: totalExpenses,
    netProfit: netProfit,
    totalInvoices: totalInvoices,
    averageInvoiceValue: averageInvoiceValue,
    topSellingItems: topItemsMap,
  );
});

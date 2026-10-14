import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final period = ref.watch(dashboardPeriodProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('لوحة التحكم والتحليلات المالية'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Chips
            Row(
              children: DashboardTimePeriod.values.map((p) {
                final isSelected = period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.nameArabic),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) {
                        ref.read(dashboardPeriodProvider.notifier).state = p;
                      }
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Stat Cards Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard(
                  title: 'إجمالي المبيعات',
                  value: CurrencyFormatter.format(metrics.totalSales, currency: restaurantInfo.currency),
                  icon: Icons.payments_rounded,
                  color: primaryColor,
                  bgColor: themeState.accentColor.lightBackground,
                ),
                _buildStatCard(
                  title: 'المصروفات والرواتب',
                  value: CurrencyFormatter.format(metrics.totalExpenses, currency: restaurantInfo.currency),
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.error,
                  bgColor: Colors.red.shade50,
                ),
                _buildStatCard(
                  title: 'صافي الربح',
                  value: CurrencyFormatter.format(metrics.netProfit, currency: restaurantInfo.currency),
                  icon: Icons.trending_up_rounded,
                  color: metrics.netProfit >= 0 ? AppColors.success : AppColors.error,
                  bgColor: metrics.netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                ),
                _buildStatCard(
                  title: 'عدد الفواتير المكتملة',
                  value: '${metrics.totalInvoices} فاتورة',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.textDark,
                  bgColor: AppColors.backgroundLight,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Top Sellers Chart
            const Text(
              'أعلى الأصناف مبيعاً في هذه الفترة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            metrics.topSellingItems.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('لا توجد مبيعات مسجلة في هذه الفترة')),
                    ),
                  )
                : Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: metrics.topSellingItems.entries.toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final itemEntry = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: itemEntry.value.toDouble(),
                                    color: primaryColor,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    final entries = metrics.topSellingItems.entries.toList();
                                    if (idx >= 0 && idx < entries.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          entries[idx].key,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

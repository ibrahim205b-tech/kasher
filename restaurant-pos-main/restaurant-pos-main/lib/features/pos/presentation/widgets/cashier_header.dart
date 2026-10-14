import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class CashierHeader extends ConsumerWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenInvoices;
  final VoidCallback onOpenMenuManagement;
  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenEmployees;
  final VoidCallback onOpenSettings;

  const CashierHeader({
    super.key,
    required this.onSearchChanged,
    required this.onOpenDashboard,
    required this.onOpenInvoices,
    required this.onOpenMenuManagement,
    required this.onOpenExpenses,
    required this.onOpenEmployees,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final primaryColor = themeState.accentColor.color;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Restaurant Name & Brand Icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeState.accentColor.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    restaurantInfo.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'شاشة الكاشير والمبيعات السريعة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 32),

          // Instant Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'ابحث عن صنف بالاسم...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Navigation Action Buttons
          Row(
            children: [
              _buildHeaderIconButton(
                icon: Icons.dashboard_outlined,
                label: 'لوحة التحكم',
                color: primaryColor,
                onTap: onOpenDashboard,
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.receipt_long_outlined,
                label: 'الفواتير',
                color: primaryColor,
                onTap: onOpenInvoices,
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.restaurant_menu_outlined,
                label: 'إدارة المنيو',
                color: primaryColor,
                onTap: onOpenMenuManagement,
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'المصروفات',
                color: primaryColor,
                onTap: onOpenExpenses,
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.badge_outlined,
                label: 'الموظفين',
                color: primaryColor,
                onTap: onOpenEmployees,
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.settings_outlined,
                label: 'الإعدادات',
                color: primaryColor,
                onTap: onOpenSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

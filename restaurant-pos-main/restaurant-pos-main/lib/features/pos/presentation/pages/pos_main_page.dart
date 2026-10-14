import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/item.dart';
import '../providers/menu_provider.dart';
import '../providers/pos_cart_provider.dart';
import '../widgets/cashier_header.dart';
import '../widgets/category_tabs.dart';
import '../widgets/item_card.dart';
import '../widgets/item_options_bottom_sheet.dart';
import '../widgets/order_receipt_panel.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../invoices/presentation/pages/invoices_history_page.dart';
import '../../../menu_management/presentation/pages/menu_management_page.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../employees/presentation/pages/employees_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class PosMainPage extends ConsumerWidget {
  const PosMainPage({super.key});

  void _handleItemTap(BuildContext context, WidgetRef ref, Item item) {
    if (item.hasOptions) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ItemOptionsBottomSheet(
          item: item,
          onAddToCart: ({
            required selectedSize,
            required selectedFlavor,
            required selectedExtras,
          }) {
            ref.read(posCartNotifierProvider.notifier).addItem(
                  item: item,
                  selectedSize: selectedSize,
                  selectedFlavor: selectedFlavor,
                  selectedExtras: selectedExtras,
                );
          },
        ),
      );
    } else {
      // Direct add to cart if no options needed
      ref.read(posCartNotifierProvider.notifier).addItem(item: item);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            CashierHeader(
              onSearchChanged: (query) {
                ref.read(menuNotifierProvider.notifier).updateSearchQuery(query);
              },
              onOpenDashboard: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              onOpenInvoices: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvoicesHistoryPage()),
                );
              },
              onOpenMenuManagement: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuManagementPage()),
                );
              },
              onOpenExpenses: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpensesPage()),
                );
              },
              onOpenEmployees: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeesPage()),
                );
              },
              onOpenSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            // Main Content Area (Tablet Split Layout)
            Expanded(
              child: Row(
                children: [
                  // Left Side Panel (~70% Width): Menu Grid & Category Tabs
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Category Tabs
                        CategoryTabs(
                          categories: menuState.categories,
                          selectedCategoryId: menuState.selectedCategoryId,
                          onCategorySelected: (catId) {
                            ref
                                .read(menuNotifierProvider.notifier)
                                .selectCategory(catId);
                          },
                        ),

                        const SizedBox(height: 12),

                        // Items Grid
                        Expanded(
                          child: menuState.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : menuState.items.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 56,
                                            color: AppColors.textLight.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'لا توجد أصناف مطابقة للبحث أو الفئة المختارة',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.95,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: menuState.items.length,
                                      itemBuilder: (context, index) {
                                        final item = menuState.items[index];
                                        return ItemCard(
                                          item: item,
                                          onTap: () =>
                                              _handleItemTap(context, ref, item),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),

                  // Right Side Panel (~30% Width): Current Receipt & Print
                  const Expanded(
                    flex: 3,
                    child: OrderReceiptPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

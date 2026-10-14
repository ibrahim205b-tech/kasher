import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/services/printer_service.dart';
import '../providers/pos_cart_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class OrderReceiptPanel extends ConsumerWidget {
  const OrderReceiptPanel({super.key});

  void _handlePrintAndCheckout(BuildContext context, WidgetRef ref) async {
    final cartState = ref.read(posCartNotifierProvider);
    if (cartState.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سلة الطلب فارغة، أضف أصناف أولاً'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final invoice = await ref
        .read(posCartNotifierProvider.notifier)
        .checkoutAndCreateInvoice();

    if (invoice != null && context.mounted) {
      final restaurantInfo = ref.read(restaurantInfoProvider);

      // Trigger thermal bluetooth printer directly without extra confirmation steps!
      final printed = await PrinterService.instance.printInvoice(
        invoice: invoice,
        info: restaurantInfo,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(printed
                ? 'تم إصدار وطباعة الفاتورة بنجاح: ${invoice.invoiceNumber}'
                : 'تم حفظ الفاتورة بنجاح (الطابعة غير متصلة)'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(posCartNotifierProvider);
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          right: BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Receipt Panel Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: themeState.accentColor.lightBackground,
              border: const Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'الطلب الحالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cartState.totalItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                if (cartState.cartItems.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('إلغاء الكل', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      ref.read(posCartNotifierProvider.notifier).clearCart();
                    },
                  ),
              ],
            ),
          ),

          // Receipt Items List
          Expanded(
            child: cartState.cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'السلة فارغة حالياً',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'اضغط على أي صنف لإضافته مباشرة للطلب',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartState.cartItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = cartState.cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity Controls
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(posCartNotifierProvider.notifier)
                                        .incrementQuantity(item.cartItemId);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: themeState.accentColor.lightBackground,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(Icons.add_rounded, size: 16, color: primaryColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(posCartNotifierProvider.notifier)
                                        .decrementQuantity(item.cartItemId);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 12),

                            // Item Description & Line Options
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (item.extrasFormattedText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        item.extrasFormattedText,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(item.unitPrice, currency: restaurantInfo.currency),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Total Price & Remove Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(item.totalPrice, currency: restaurantInfo.currency),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                  onPressed: () {
                                    ref
                                        .read(posCartNotifierProvider.notifier)
                                        .removeItem(item.cartItemId);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Summary & Big Fixed PRINT Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              border: const Border(
                top: BorderSide(color: AppColors.borderLight, width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع الفرعي:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    Text(
                      CurrencyFormatter.format(cartState.subtotal, currency: restaurantInfo.currency),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (cartState.discountAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الخصم:',
                        style: TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                      Text(
                        '-${CurrencyFormatter.format(cartState.discountAmount, currency: restaurantInfo.currency)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع النهائي:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(cartState.grandTotal, currency: restaurantInfo.currency),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // BIG FIXED PRINT INVOICE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: cartState.isProcessingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.print_rounded, size: 26),
                    label: Text(
                      cartState.isProcessingOrder ? 'جاري الإصدار والطباعة...' : 'طباعة الفاتورة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: cartState.isProcessingOrder
                        ? null
                        : () => _handlePrintAndCheckout(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

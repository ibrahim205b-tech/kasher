import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/item.dart';
import '../../data/models/item_option.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class ItemOptionsBottomSheet extends ConsumerStatefulWidget {
  final Item item;
  final Function({
    required ItemOption? selectedSize,
    required ItemOption? selectedFlavor,
    required List<ItemOption> selectedExtras,
  }) onAddToCart;

  const ItemOptionsBottomSheet({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  ConsumerState<ItemOptionsBottomSheet> createState() =>
      _ItemOptionsBottomSheetState();
}

class _ItemOptionsBottomSheetState
    extends ConsumerState<ItemOptionsBottomSheet> {
  ItemOption? selectedSize;
  ItemOption? selectedFlavor;
  final List<ItemOption> selectedExtras = [];

  @override
  void initState() {
    super.initState();
    // Default size selection
    final sizes = widget.item.sizes;
    if (sizes.isNotEmpty) {
      selectedSize = sizes.firstWhere(
        (s) => s.isDefault,
        orElse: () => sizes.first,
      );
    }
    // Default flavor selection
    final flavors = widget.item.flavors;
    if (flavors.isNotEmpty) {
      selectedFlavor = flavors.firstWhere(
        (f) => f.isDefault,
        orElse: () => flavors.first,
      );
    }
  }

  double calculateTotalPrice() {
    double total = widget.item.basePrice;
    if (selectedSize != null) {
      total += selectedSize!.priceModifier;
    }
    if (selectedFlavor != null) {
      total += selectedFlavor!.priceModifier;
    }
    for (final extra in selectedExtras) {
      total += extra.priceModifier;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;
    final totalPrice = calculateTotalPrice();

    final sizes = widget.item.sizes;
    final flavors = widget.item.flavors;
    final extras = widget.item.extras;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'قم بتخصيص الحجم والنكهة والإضافات المفضلة',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Size Selection
                  if (sizes.isNotEmpty) ...[
                    _buildSectionTitle('اختر الحجم'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: sizes.map((size) {
                        final isSelected = selectedSize?.id == size.id;
                        return ChoiceChip(
                          label: Text(
                            size.priceModifier > 0
                                ? '${size.optionName} (+${CurrencyFormatter.format(size.priceModifier, currency: restaurantInfo.currency)})'
                                : size.optionName,
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: AppColors.backgroundLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => selectedSize = size);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 2. Flavor Selection
                  if (flavors.isNotEmpty) ...[
                    _buildSectionTitle('اختر النكهة'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: flavors.map((flavor) {
                        final isSelected = selectedFlavor?.id == flavor.id;
                        return ChoiceChip(
                          label: Text(
                            flavor.priceModifier > 0
                                ? '${flavor.optionName} (+${CurrencyFormatter.format(flavor.priceModifier, currency: restaurantInfo.currency)})'
                                : flavor.optionName,
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: AppColors.backgroundLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => selectedFlavor = flavor);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 3. Extras Selection
                  if (extras.isNotEmpty) ...[
                    _buildSectionTitle('الإضافات الخاصة'),
                    const SizedBox(height: 10),
                    Column(
                      children: extras.map((extra) {
                        final isSelected =
                            selectedExtras.any((e) => e.id == extra.id);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: primaryColor,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            extra.optionName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            '+${CurrencyFormatter.format(extra.priceModifier, currency: restaurantInfo.currency)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                selectedExtras.add(extra);
                              } else {
                                selectedExtras
                                    .removeWhere((e) => e.id == extra.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),

          // Total Price & Confirm Add Button
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإجمالي النهائي:',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    CurrencyFormatter.format(totalPrice, currency: restaurantInfo.currency),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text(
                      'إضافة إلى سلة الطلب',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      widget.onAddToCart(
                        selectedSize: selectedSize,
                        selectedFlavor: selectedFlavor,
                        selectedExtras: selectedExtras,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}

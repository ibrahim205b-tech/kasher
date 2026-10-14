import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/category.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

class CategoryTabs extends ConsumerWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'lunch_dining':
        return Icons.lunch_dining_rounded;
      case 'local_pizza':
        return Icons.local_pizza_rounded;
      case 'local_bar':
        return Icons.local_bar_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeSettingsProvider);
    final primaryColor = themeState.accentColor.color;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All Category Tab
          _buildTabChip(
            label: 'الكل',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategoryId == null,
            primaryColor: primaryColor,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),

          ...categories.map((cat) {
            final isSelected = selectedCategoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTabChip(
                label: cat.name,
                icon: _getCategoryIcon(cat.iconName),
                isSelected: isSelected,
                primaryColor: primaryColor,
                onTap: () => onCategorySelected(cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

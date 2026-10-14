import 'item.dart';
import 'item_option.dart';

class CartItem {
  final String cartItemId;
  final Item item;
  final ItemOption? selectedSize;
  final ItemOption? selectedFlavor;
  final List<ItemOption> selectedExtras;
  int quantity;

  CartItem({
    required this.cartItemId,
    required this.item,
    this.selectedSize,
    this.selectedFlavor,
    this.selectedExtras = const [],
    this.quantity = 1,
  });

  double get unitPrice {
    double total = item.basePrice;
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

  double get totalPrice => unitPrice * quantity;

  String get extrasFormattedText {
    final list = <String>[];
    if (selectedSize != null) {
      list.add('الحجم: ${selectedSize!.optionName}');
    }
    if (selectedFlavor != null) {
      list.add('النكهة: ${selectedFlavor!.optionName}');
    }
    if (selectedExtras.isNotEmpty) {
      list.add('الإضافات: ${selectedExtras.map((e) => e.optionName).join(', ')}');
    }
    return list.join(' | ');
  }

  CartItem copyWith({
    String? cartItemId,
    Item? item,
    ItemOption? selectedSize,
    ItemOption? selectedFlavor,
    List<ItemOption>? selectedExtras,
    int? quantity,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      item: item ?? this.item,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedFlavor: selectedFlavor ?? this.selectedFlavor,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      quantity: quantity ?? this.quantity,
    );
  }
}

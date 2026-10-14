import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/item.dart';
import '../../data/models/item_option.dart';
import '../../../invoices/data/models/invoice.dart';
import '../../../invoices/data/models/invoice_item.dart';
import '../../../invoices/presentation/providers/invoices_provider.dart';

class PosCartState {
  final List<CartItem> cartItems;
  final double discountAmount;
  final bool isProcessingOrder;

  PosCartState({
    this.cartItems = const [],
    this.discountAmount = 0.0,
    this.isProcessingOrder = false,
  });

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get grandTotal => (subtotal - discountAmount) < 0
      ? 0.0
      : (subtotal - discountAmount);

  int get totalItemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  PosCartState copyWith({
    List<CartItem>? cartItems,
    double? discountAmount,
    bool? isProcessingOrder,
  }) {
    return PosCartState(
      cartItems: cartItems ?? this.cartItems,
      discountAmount: discountAmount ?? this.discountAmount,
      isProcessingOrder: isProcessingOrder ?? this.isProcessingOrder,
    );
  }
}

class PosCartNotifier extends StateNotifier<PosCartState> {
  static const uuid = Uuid();
  final Ref ref;

  PosCartNotifier(this.ref) : super(PosCartState());

  void addItem({
    required Item item,
    ItemOption? selectedSize,
    ItemOption? selectedFlavor,
    List<ItemOption> selectedExtras = const [],
  }) {
    final cartItemId = uuid.v4();
    final newCartItem = CartItem(
      cartItemId: cartItemId,
      item: item,
      selectedSize: selectedSize,
      selectedFlavor: selectedFlavor,
      selectedExtras: selectedExtras,
      quantity: 1,
    );

    // Check if an identical cart item already exists
    final existingIndex = state.cartItems.indexWhere((ci) =>
        ci.item.id == item.id &&
        ci.selectedSize?.id == selectedSize?.id &&
        ci.selectedFlavor?.id == selectedFlavor?.id &&
        _areExtrasEqual(ci.selectedExtras, selectedExtras));

    if (existingIndex != -1) {
      final updatedList = List<CartItem>.from(state.cartItems);
      updatedList[existingIndex].quantity += 1;
      state = state.copyWith(cartItems: updatedList);
    } else {
      state = state.copyWith(cartItems: [...state.cartItems, newCartItem]);
    }
  }

  bool _areExtrasEqual(List<ItemOption> list1, List<ItemOption> list2) {
    if (list1.length != list2.length) return false;
    final ids1 = list1.map((e) => e.id).toSet();
    final ids2 = list2.map((e) => e.id).toSet();
    return ids1.containsAll(ids2);
  }

  void incrementQuantity(String cartItemId) {
    final updatedList = state.cartItems.map((ci) {
      if (ci.cartItemId == cartItemId) {
        return ci.copyWith(quantity: ci.quantity + 1);
      }
      return ci;
    }).toList();
    state = state.copyWith(cartItems: updatedList);
  }

  void decrementQuantity(String cartItemId) {
    final updatedList = <CartItem>[];
    for (final ci in state.cartItems) {
      if (ci.cartItemId == cartItemId) {
        if (ci.quantity > 1) {
          updatedList.add(ci.copyWith(quantity: ci.quantity - 1));
        }
      } else {
        updatedList.add(ci);
      }
    }
    state = state.copyWith(cartItems: updatedList);
  }

  void removeItem(String cartItemId) {
    final updatedList =
        state.cartItems.where((ci) => ci.cartItemId != cartItemId).toList();
    state = state.copyWith(cartItems: updatedList);
  }

  void clearCart() {
    state = PosCartState();
  }

  void setDiscount(double discount) {
    state = state.copyWith(discountAmount: discount);
  }

  Future<Invoice?> checkoutAndCreateInvoice() async {
    if (state.cartItems.isEmpty) return null;
    state = state.copyWith(isProcessingOrder: true);

    try {
      final invoicesRepo = ref.read(invoicesRepositoryProvider);
      final nextNumber = await invoicesRepo.getNextInvoiceNumber();

      final invoiceId = uuid.v4();
      final invoiceItems = state.cartItems.map((ci) {
        return InvoiceItem(
          id: uuid.v4(),
          invoiceId: invoiceId,
          itemId: ci.item.id,
          itemName: ci.item.name,
          sizeName: ci.selectedSize?.optionName,
          flavorName: ci.selectedFlavor?.optionName,
          extrasText: ci.selectedExtras.isNotEmpty
              ? ci.selectedExtras.map((e) => e.optionName).join(', ')
              : null,
          quantity: ci.quantity,
          unitPrice: ci.unitPrice,
          lineTotal: ci.totalPrice,
        );
      }).toList();

      final newInvoice = Invoice(
        id: invoiceId,
        invoiceNumber: nextNumber,
        createdAt: DateTime.now(),
        subtotal: state.subtotal,
        discount: state.discountAmount,
        grandTotal: state.grandTotal,
        status: InvoiceStatus.paid,
        items: invoiceItems,
      );

      await ref.read(invoicesNotifierProvider.notifier).createInvoice(newInvoice);

      clearCart();
      return newInvoice;
    } finally {
      state = state.copyWith(isProcessingOrder: false);
    }
  }
}

final posCartNotifierProvider =
    StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier(ref);
});

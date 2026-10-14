class InvoiceItem {
  final String id;
  final String invoiceId;
  final String itemId;
  final String itemName;
  final String? sizeName;
  final String? flavorName;
  final String? extrasText;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemId,
    required this.itemName,
    this.sizeName,
    this.flavorName,
    this.extrasText,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'item_name': itemName,
      'size_name': sizeName,
      'flavor_name': flavorName,
      'extras_text': extrasText,
      'quantity': quantity,
      'unit_price': unitPrice,
      'line_total': lineTotal,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as String,
      invoiceId: map['invoice_id'] as String,
      itemId: map['item_id'] as String,
      itemName: map['item_name'] as String,
      sizeName: map['size_name'] as String?,
      flavorName: map['flavor_name'] as String?,
      extrasText: map['extras_text'] as String?,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      lineTotal: (map['line_total'] as num).toDouble(),
    );
  }
}

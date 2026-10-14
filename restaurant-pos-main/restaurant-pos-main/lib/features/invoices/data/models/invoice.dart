import 'invoice_item.dart';

enum InvoiceStatus {
  paid,
  cancelled,
}

class Invoice {
  final String id;
  final String invoiceNumber; // e.g. INV-0001
  final DateTime createdAt;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final InvoiceStatus status;
  final String? cancelReason;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.subtotal,
    this.discount = 0.0,
    required this.grandTotal,
    this.status = InvoiceStatus.paid,
    this.cancelReason,
    this.items = const [],
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isCancelled => status == InvoiceStatus.cancelled;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'created_at': createdAt.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'grand_total': grandTotal,
      'status': status.name,
      'cancel_reason': cancelReason,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, {List<InvoiceItem> items = const []}) {
    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      grandTotal: (map['grand_total'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InvoiceStatus.paid,
      ),
      cancelReason: map['cancel_reason'] as String?,
      items: items,
    );
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? createdAt,
    double? subtotal,
    double? discount,
    double? grandTotal,
    InvoiceStatus? status,
    String? cancelReason,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      items: items ?? this.items,
    );
  }
}

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceRepository {
  final DatabaseHelper dbHelper;

  InvoiceRepository({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<String> getNextInvoiceNumber() async {
    final db = await dbHelper.database;
    final infoResult = await db.query('restaurant_info', where: 'id = ?', whereArgs: ['main_info']);
    String prefix = 'INV-';
    if (infoResult.isNotEmpty) {
      prefix = (infoResult.first['invoice_prefix'] as String?) ?? 'INV-';
    }

    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM invoices');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    final nextSeq = (count + 1).toString().padLeft(4, '0');
    return '$prefix$nextSeq';
  }

  Future<void> createInvoice(Invoice invoice) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('invoices', invoice.toMap());
      for (final item in invoice.items) {
        await txn.insert('invoice_items', item.toMap());
      }
    });
  }

  Future<List<Invoice>> getInvoices({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'invoice_number LIKE ?';
      whereArgs.add('%${searchQuery.trim()}%');
    }

    if (startDate != null && endDate != null) {
      final startStr = startDate.toIso8601String();
      final endStr = endDate.toIso8601String();
      if (whereClause.isNotEmpty) {
        whereClause += ' AND created_at BETWEEN ? AND ?';
      } else {
        whereClause = 'created_at BETWEEN ? AND ?';
      }
      whereArgs.add(startStr);
      whereArgs.add(endStr);
    }

    final invoiceMaps = await db.query(
      'invoices',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
    );

    final List<Invoice> invoices = [];
    for (final map in invoiceMaps) {
      final invoiceId = map['id'] as String;
      final itemMaps = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      final items = itemMaps.map((im) => InvoiceItem.fromMap(im)).toList();
      invoices.add(Invoice.fromMap(map, items: items));
    }
    return invoices;
  }

  Future<void> cancelInvoice(String invoiceId, String reason) async {
    final db = await dbHelper.database;
    await db.update(
      'invoices',
      {
        'status': 'cancelled',
        'cancel_reason': reason,
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }
}

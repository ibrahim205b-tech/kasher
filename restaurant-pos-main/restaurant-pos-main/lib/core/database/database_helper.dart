import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'demo_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurant_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL DEFAULT 0';
    const doubleType = 'REAL NOT NULL DEFAULT 0.0';

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon_name $textType,
        sort_order $intType,
        is_active $intType
      )
    ''');

    // Items Table
    await db.execute('''
      CREATE TABLE items (
        id $idType,
        category_id $textType,
        name $textType,
        base_price $doubleType,
        image_path $textNullable,
        is_active $intType,
        is_top_seller $intType,
        sort_order $intType,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Item Options Table (Sizes, Flavors, Extras)
    await db.execute('''
      CREATE TABLE item_options (
        id $idType,
        item_id $textType,
        group_name $textType,
        option_name $textType,
        price_modifier $doubleType,
        is_default $intType,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // Invoices Table
    await db.execute('''
      CREATE TABLE invoices (
        id $idType,
        invoice_number $textType,
        created_at $textType,
        subtotal $doubleType,
        discount $doubleType,
        grand_total $doubleType,
        status $textType,
        cancel_reason $textNullable
      )
    ''');

    // Invoice Items Table
    await db.execute('''
      CREATE TABLE invoice_items (
        id $idType,
        invoice_id $textType,
        item_id $textType,
        item_name $textType,
        size_name $textNullable,
        flavor_name $textNullable,
        extras_text $textNullable,
        quantity $intType,
        unit_price $doubleType,
        line_total $doubleType,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        category $textType,
        amount $doubleType,
        date $textType,
        note $textNullable
      )
    ''');

    // Employees Table
    await db.execute('''
      CREATE TABLE employees (
        id $idType,
        name $textType,
        role $textType,
        phone $textType,
        salary $doubleType,
        pay_type $textType,
        last_paid_at $textNullable
      )
    ''');

    // Restaurant Info Table
    await db.execute('''
      CREATE TABLE restaurant_info (
        id TEXT PRIMARY KEY,
        name $textType,
        address $textType,
        phone $textType,
        logo_path $textNullable,
        currency $textType,
        invoice_footer $textType,
        paper_width $textType,
        show_logo $intType,
        show_address $intType,
        show_phone $intType,
        show_footer $intType,
        invoice_prefix $textType
      )
    ''');

    // Seed Initial Restaurant Info & Demo Menu Data
    await DemoData.seedInitialData(db);
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('invoice_items');
    await db.delete('invoices');
    await db.delete('item_options');
    await db.delete('items');
    await db.delete('categories');
    await db.delete('expenses');
    await db.delete('employees');
  }

  Future<void> reloadDemoData() async {
    final db = await instance.database;
    await clearAllData();
    await DemoData.seedInitialData(db);
  }
}

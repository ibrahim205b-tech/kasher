import '../../../../core/database/database_helper.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_option.dart';

class MenuRepository {
  final DatabaseHelper dbHelper;

  MenuRepository({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Category>> getCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'categories',
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> addCategory(Category category) async {
    final db = await dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    final db = await dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<List<Item>> getItems({String? categoryId, String? searchQuery}) async {
    final db = await dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId.isNotEmpty) {
      whereClause = 'category_id = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND name LIKE ?';
      } else {
        whereClause = 'name LIKE ?';
      }
      whereArgs.add('%${searchQuery.trim()}%');
    }

    final itemMaps = await db.query(
      'items',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'sort_order ASC',
    );

    final List<Item> items = [];
    for (final map in itemMaps) {
      final itemId = map['id'] as String;
      final optionMaps = await db.query(
        'item_options',
        where: 'item_id = ?',
        whereArgs: [itemId],
      );
      final options = optionMaps.map((om) => ItemOption.fromMap(om)).toList();
      items.add(Item.fromMap(map, options: options));
    }
    return items;
  }

  Future<void> addItem(Item item) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('items', item.toMap());
      for (final option in item.options) {
        await txn.insert('item_options', option.toMap());
      }
    });
  }

  Future<void> updateItem(Item item) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      await txn.delete(
        'item_options',
        where: 'item_id = ?',
        whereArgs: [item.id],
      );
      for (final option in item.options) {
        await txn.insert('item_options', option.toMap());
      }
    });
  }

  Future<void> toggleItemActive(String itemId, bool isActive) async {
    final db = await dbHelper.database;
    await db.update(
      'items',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> deleteItem(String itemId) async {
    final db = await dbHelper.database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }
}

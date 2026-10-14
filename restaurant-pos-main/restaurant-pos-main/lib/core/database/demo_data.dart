import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DemoData {
  static const uuid = Uuid();

  static Future<void> seedInitialData(Database db) async {
    // 1. Seed Restaurant Info
    await db.insert('restaurant_info', {
      'id': 'main_info',
      'name': 'مطعم الفخامة والتذوق',
      'address': 'بغداد - الكرادة - الشارع العام',
      'phone': '07700000000',
      'logo_path': null,
      'currency': 'د.ع',
      'invoice_footer': 'شكراً لزيارتكم! نرجو رؤيتكم مجدداً',
      'paper_width': '58mm',
      'show_logo': 1,
      'show_address': 1,
      'show_phone': 1,
      'show_footer': 1,
      'invoice_prefix': 'INV-',
    });

    // 2. Categories
    final catShawarmaId = uuid.v4();
    final catBurgerId = uuid.v4();
    final catPizzaId = uuid.v4();
    final catDrinksId = uuid.v4();
    final catSweetsId = uuid.v4();

    await db.insert('categories', {'id': catShawarmaId, 'name': 'شاورما', 'icon_name': 'fastfood', 'sort_order': 1, 'is_active': 1});
    await db.insert('categories', {'id': catBurgerId, 'name': 'برجر', 'icon_name': 'lunch_dining', 'sort_order': 2, 'is_active': 1});
    await db.insert('categories', {'id': catPizzaId, 'name': 'بيتزا', 'icon_name': 'local_pizza', 'sort_order': 3, 'is_active': 1});
    await db.insert('categories', {'id': catDrinksId, 'name': 'مشروبات', 'icon_name': 'local_bar', 'sort_order': 4, 'is_active': 1});
    await db.insert('categories', {'id': catSweetsId, 'name': 'حلويات', 'icon_name': 'icecream', 'sort_order': 5, 'is_active': 1});

    // 3. Items & Item Options
    // --- Shawarma ---
    final itemShawarmaClassicId = uuid.v4();
    await db.insert('items', {
      'id': itemShawarmaClassicId,
      'category_id': catShawarmaId,
      'name': 'شاورما عربية فاخرة',
      'base_price': 5000.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 1,
      'sort_order': 1,
    });
    // Sizes
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'size', 'option_name': 'صغير', 'price_modifier': 0.0, 'is_default': 1});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'size', 'option_name': 'وسط', 'price_modifier': 2000.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'size', 'option_name': 'كبير', 'price_modifier': 4000.0, 'is_default': 0});
    // Flavors
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'flavor', 'option_name': 'دجاج', 'price_modifier': 0.0, 'is_default': 1});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'flavor', 'option_name': 'لحم', 'price_modifier': 1500.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'flavor', 'option_name': 'مشكل (دجاج ولحم)', 'price_modifier': 2000.0, 'is_default': 0});
    // Extras
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'extra', 'option_name': 'جبن موزاريلا', 'price_modifier': 1000.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'extra', 'option_name': 'بطاطا مقلية', 'price_modifier': 500.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'extra', 'option_name': 'صوص ثوم إضافي', 'price_modifier': 500.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemShawarmaClassicId, 'group_name': 'extra', 'option_name': 'مخلل حار', 'price_modifier': 250.0, 'is_default': 0});

    // --- Burger ---
    final itemBurgerDoubleId = uuid.v4();
    await db.insert('items', {
      'id': itemBurgerDoubleId,
      'category_id': catBurgerId,
      'name': 'برجر دبل تشيز فاخر',
      'base_price': 7000.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 1,
      'sort_order': 2,
    });
    // Sizes
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'size', 'option_name': 'مفرد (Single)', 'price_modifier': 0.0, 'is_default': 1});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'size', 'option_name': 'مزدوج (Double)', 'price_modifier': 2500.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'size', 'option_name': 'عملاق (Triple)', 'price_modifier': 4500.0, 'is_default': 0});
    // Flavors
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'flavor', 'option_name': 'لحم أنغوس مشوي', 'price_modifier': 0.0, 'is_default': 1});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'flavor', 'option_name': 'دجاج مقرمش (Zinger)', 'price_modifier': 0.0, 'is_default': 0});
    // Extras
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'extra', 'option_name': 'شريحة بيقون بقر', 'price_modifier': 1500.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemBurgerDoubleId, 'group_name': 'extra', 'option_name': 'حلقات بصل مقرمشة', 'price_modifier': 1000.0, 'is_default': 0});

    // --- Pizza ---
    final itemPizzaPepperoniId = uuid.v4();
    await db.insert('items', {
      'id': itemPizzaPepperoniId,
      'category_id': catPizzaId,
      'name': 'بيتزا ببروني بالجبن الإيطالي',
      'base_price': 9000.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 1,
      'sort_order': 3,
    });
    // Sizes
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemPizzaPepperoniId, 'group_name': 'size', 'option_name': 'صغير (20cm)', 'price_modifier': 0.0, 'is_default': 1});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemPizzaPepperoniId, 'group_name': 'size', 'option_name': 'وسط (30cm)', 'price_modifier': 4000.0, 'is_default': 0});
    await db.insert('item_options', {'id': uuid.v4(), 'item_id': itemPizzaPepperoniId, 'group_name': 'size', 'option_name': 'عائلي (40cm)', 'price_modifier': 8000.0, 'is_default': 0});

    // --- Drinks ---
    final itemColaId = uuid.v4();
    await db.insert('items', {
      'id': itemColaId,
      'category_id': catDrinksId,
      'name': 'بيبسي بارد 330مل',
      'base_price': 1000.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 0,
      'sort_order': 4,
    });

    final itemJuiceId = uuid.v4();
    await db.insert('items', {
      'id': itemJuiceId,
      'category_id': catDrinksId,
      'name': 'عصير برتقال طبيعي',
      'base_price': 2500.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 0,
      'sort_order': 5,
    });

    // --- Sweets ---
    final itemKnafehId = uuid.v4();
    await db.insert('items', {
      'id': itemKnafehId,
      'category_id': catSweetsId,
      'name': 'كنافة نابلسية بالقشطة والجبن',
      'base_price': 4000.0,
      'image_path': null,
      'is_active': 1,
      'is_top_seller': 0,
      'sort_order': 6,
    });

    // 4. Employees
    await db.insert('employees', {
      'id': uuid.v4(),
      'name': 'محمد علي العراقي',
      'role': 'شيف رئيسي (Head Chef)',
      'phone': '07712345678',
      'salary': 900000.0,
      'pay_type': 'monthly',
      'last_paid_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    });

    await db.insert('employees', {
      'id': uuid.v4(),
      'name': 'أحمد حسن',
      'role': 'كاشير (Cashier)',
      'phone': '07801122334',
      'salary': 600000.0,
      'pay_type': 'monthly',
      'last_paid_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    });

    // 5. Sample Expenses
    await db.insert('expenses', {
      'id': uuid.v4(),
      'category': 'إيجار',
      'amount': 500000.0,
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'note': 'إيجار محل الشهر الحالى',
    });

    await db.insert('expenses', {
      'id': uuid.v4(),
      'category': 'كهرباء',
      'amount': 150000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'note': 'فاتورة المولد والكهرباء',
    });

    // 6. Initial Sample Invoices
    final invoice1Id = uuid.v4();
    await db.insert('invoices', {
      'id': invoice1Id,
      'invoice_number': 'INV-0001',
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'subtotal': 12000.0,
      'discount': 0.0,
      'grand_total': 12000.0,
      'status': 'paid',
      'cancel_reason': null,
    });

    await db.insert('invoice_items', {
      'id': uuid.v4(),
      'invoice_id': invoice1Id,
      'item_id': itemShawarmaClassicId,
      'item_name': 'شاورما عربية فاخرة',
      'size_name': 'وسط',
      'flavor_name': 'دجاج',
      'extras_text': 'الإضافات: جبن موزاريلا',
      'quantity': 1,
      'unit_price': 8000.0,
      'line_total': 8000.0,
    });

    await db.insert('invoice_items', {
      'id': uuid.v4(),
      'invoice_id': invoice1Id,
      'item_id': itemKnafehId,
      'item_name': 'كنافة نابلسية بالقشطة والجبن',
      'size_name': null,
      'flavor_name': null,
      'extras_text': null,
      'quantity': 1,
      'unit_price': 4000.0,
      'line_total': 4000.0,
    });
  }
}

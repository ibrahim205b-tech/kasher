import 'item_option.dart';

class Item {
  final String id;
  final String categoryId;
  final String name;
  final double basePrice;
  final String? imagePath;
  final bool isActive;
  final bool isTopSeller;
  final int sortOrder;
  final List<ItemOption> options;

  Item({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.basePrice,
    this.imagePath,
    this.isActive = true,
    this.isTopSeller = false,
    this.sortOrder = 0,
    this.options = const [],
  });

  bool get hasOptions => options.isNotEmpty;

  List<ItemOption> get sizes =>
      options.where((o) => o.groupName == 'size').toList();

  List<ItemOption> get flavors =>
      options.where((o) => o.groupName == 'flavor').toList();

  List<ItemOption> get extras =>
      options.where((o) => o.groupName == 'extra').toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'base_price': basePrice,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
      'is_top_seller': isTopSeller ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map, {List<ItemOption> options = const []}) {
    return Item(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      basePrice: (map['base_price'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      isTopSeller: (map['is_top_seller'] as int?) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      options: options,
    );
  }

  Item copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? basePrice,
    String? imagePath,
    bool? isActive,
    bool? isTopSeller,
    int? sortOrder,
    List<ItemOption>? options,
  }) {
    return Item(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      isTopSeller: isTopSeller ?? this.isTopSeller,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
    );
  }
}

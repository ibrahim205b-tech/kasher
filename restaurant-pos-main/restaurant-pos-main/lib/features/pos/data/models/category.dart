class Category {
  final String id;
  final String name;
  final String iconName;
  final int sortOrder;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.iconName = 'restaurant',
    this.sortOrder = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'sort_order': sortOrder,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: (map['icon_name'] as String?) ?? 'restaurant',
      sortOrder: (map['sort_order'] as int?) ?? 0,
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}

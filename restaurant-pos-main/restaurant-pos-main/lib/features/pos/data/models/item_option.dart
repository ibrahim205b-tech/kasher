class ItemOption {
  final String id;
  final String itemId;
  final String groupName; // 'size', 'flavor', 'extra'
  final String optionName; // e.g. 'صغير', 'دجاج', 'جبن إضافي'
  final double priceModifier;
  final bool isDefault;

  ItemOption({
    required this.id,
    required this.itemId,
    required this.groupName,
    required this.optionName,
    this.priceModifier = 0.0,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'group_name': groupName,
      'option_name': optionName,
      'price_modifier': priceModifier,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory ItemOption.fromMap(Map<String, dynamic> map) {
    return ItemOption(
      id: map['id'] as String,
      itemId: map['item_id'] as String,
      groupName: map['group_name'] as String,
      optionName: map['option_name'] as String,
      priceModifier: (map['price_modifier'] as num).toDouble(),
      isDefault: (map['is_default'] as int?) == 1,
    );
  }

  ItemOption copyWith({
    String? id,
    String? itemId,
    String? groupName,
    String? optionName,
    double? priceModifier,
    bool? isDefault,
  }) {
    return ItemOption(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      groupName: groupName ?? this.groupName,
      optionName: optionName ?? this.optionName,
      priceModifier: priceModifier ?? this.priceModifier,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

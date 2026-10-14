import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/restaurant_info.dart';

class RestaurantInfoNotifier extends StateNotifier<RestaurantInfo> {
  RestaurantInfoNotifier() : super(RestaurantInfo()) {
    loadInfo();
  }

  Future<void> loadInfo() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('restaurant_info', where: 'id = ?', whereArgs: ['main_info']);
    if (maps.isNotEmpty) {
      state = RestaurantInfo.fromMap(maps.first);
    }
  }

  Future<void> updateInfo(RestaurantInfo newInfo) async {
    state = newInfo;
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'restaurant_info',
      newInfo.toMap(),
      where: 'id = ?',
      whereArgs: ['main_info'],
    );
  }
}

final restaurantInfoProvider =
    StateNotifierProvider<RestaurantInfoNotifier, RestaurantInfo>((ref) {
  return RestaurantInfoNotifier();
});

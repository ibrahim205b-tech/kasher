import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../data/models/item.dart';
import '../../data/repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuState {
  final List<Category> categories;
  final List<Item> items;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;

  MenuState({
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
  });

  MenuState copyWith({
    List<Category>? categories,
    List<Item>? items,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository repository;

  MenuNotifier(this.repository) : super(MenuState()) {
    loadMenu();
  }

  Future<void> loadMenu() async {
    state = state.copyWith(isLoading: true);
    final categories = await repository.getCategories();
    final items = await repository.getItems(
      categoryId: state.selectedCategoryId,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(
      categories: categories,
      items: items,
      isLoading: false,
    );
  }

  void selectCategory(String? categoryId) {
    if (state.selectedCategoryId == categoryId) return;
    if (categoryId == null) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
    loadMenu();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadMenu();
  }

  Future<void> addItem(Item item) async {
    await repository.addItem(item);
    await loadMenu();
  }

  Future<void> updateItem(Item item) async {
    await repository.updateItem(item);
    await loadMenu();
  }

  Future<void> toggleItemActive(String itemId, bool isActive) async {
    await repository.toggleItemActive(itemId, isActive);
    await loadMenu();
  }

  Future<void> deleteItem(String itemId) async {
    await repository.deleteItem(itemId);
    await loadMenu();
  }

  Future<void> addCategory(Category category) async {
    await repository.addCategory(category);
    await loadMenu();
  }

  Future<void> updateCategory(Category category) async {
    await repository.updateCategory(category);
    await loadMenu();
  }

  Future<void> deleteCategory(String categoryId) async {
    await repository.deleteCategory(categoryId);
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearSelectedCategory: true);
    }
    await loadMenu();
  }
}

final menuNotifierProvider =
    StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return MenuNotifier(repository);
});

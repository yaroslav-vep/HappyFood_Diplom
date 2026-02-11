import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

class ProductsViewModel extends StateNotifier<List<ProductModel>> {
  ProductsViewModel() : super([]);

  void addProduct(String name) {
    if (name.isNotEmpty &&
        !state.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      state = [...state, ProductModel(name: name)];
    }
  }

  void removeProduct(String name) {
    state = state.where((p) => p.name != name).toList();
  }
}

final productsViewModelProvider =
    StateNotifierProvider<ProductsViewModel, List<ProductModel>>((ref) {
      return ProductsViewModel();
    });

import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';

/// Shopping cart shared by the Catalog and Cart screens via `provider`.
class CartProvider extends ChangeNotifier {
  // Keyed by product id; a LinkedHashMap keeps the order items were added.
  final Map<String, Product> _items = {};

  List<Product> get items => List.unmodifiable(_items.values);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  double get total => _items.values.fold(0, (sum, p) => sum + p.price);

  bool contains(Product p) => _items.containsKey(p.id);

  void toggle(Product p) {
    if (_items.remove(p.id) == null) _items[p.id] = p;
    notifyListeners();
  }

  void remove(Product p) {
    if (_items.remove(p.id) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

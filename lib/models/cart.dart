import 'product.dart';
import 'dart:convert';

class CartStorageKeys {
  static const cartItems = 'cartItems';
}

class CartItem {
  final Product product;
  int quantity;
  final String size;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.size,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
        'size': size,
      };

  static CartItem? fromJson(Map<String, dynamic> json) {
    final id = json['productId'];
    if (id == null) return null;
    final product = demoProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => Product(
        id: -1,
        name: 'Unknown',
        price: 0,
        imageUrl: '',
        sizes: const [''],
      ),
    );
    if (product.id == -1) return null;
    return CartItem(
      product: product,
      quantity: (json['quantity'] ?? 1) as int,
      size: json['size'] ?? '',
    );
  }
}

class Cart {
  List<CartItem> items = [];

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Product product, String size, {int quantity = 1}) {
    final existingIndex = items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(product: product, size: size, quantity: quantity));
    }
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void updateQuantity(int index, int quantity) {
    items[index].quantity = quantity;
  }

  void clear() {
    items.clear();
  }

  List<Map<String, dynamic>> toJson() =>
      items.map((e) => e.toJson()).toList(growable: false);

  void loadFromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        items = decoded
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .whereType<CartItem>()
            .toList();
      }
    } catch (_) {}
  }

  String dump() => jsonEncode(toJson());
}
import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart extends ChangeNotifier {
  Map<String, CartItem>? _items = {};

  Map<String, CartItem>? get cartItems {
    return {...?_items};
  }

  void deleteUserData() {
    _items = {};
  }

  int get itemCount {
    int count = 0;
    _items!.forEach(
      (key, cartItem) {
        count += cartItem.quantity;
      },
    );
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items!.forEach(
      (key, cartItem) {
        total += cartItem.price * cartItem.quantity;
      },
    );
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items!.containsKey(productId)) {
      _items!.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items!.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                quantity: 1,
                price: price,
              ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items!.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items!.containsKey(productId)) {
      return;
    }

    if (_items![productId]!.quantity > 1) {
      _items!.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            price: existingCartItem.price,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity - 1),
      );
    } else {
      _items!.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _items!.containsKey(productId);
  }

  int productQuantity(String productId) {
    try {
      return _items![productId]!.quantity;
    } catch (e) {
      return 0;
    }
  }
}

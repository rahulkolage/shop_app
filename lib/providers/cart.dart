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

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  // get items that are in cart
  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    // returns amount of products
    // return _items == null ? 0 : _items.length; // no length initially, dart throws error
    // initialized _items = {}
    return _items.length;
  }

  double get totalAmount {
    double total=0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;      
      // print('End Total: ${total.toStringAsFixed(2)}');
    });
    return total;
  }

  // add item
  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // change quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // add new item
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}

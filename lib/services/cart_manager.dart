import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartManager {
  static final ValueNotifier<List<CartItem>> items =
      ValueNotifier<List<CartItem>>(<CartItem>[]);

  static void addProduct(String id, Map<String, dynamic> product) {
    final current = List<CartItem>.from(items.value);
    final index = current.indexWhere((item) => item.id == id);
    final rawPrice = product['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice.toString()) ?? 0.0);

    if (index >= 0) {
      current[index].quantity++;
    } else {
      current.add(
        CartItem(
          id: id,
          name: product['name'] ?? 'Produs TechStore',
          price: parsedPrice,
          imageUrl: product['imageUrl'] ?? '',
        ),
      );
    }
    items.value = current;
  }

  static void updateQuantity(String id, int delta) {
    final current = List<CartItem>.from(items.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index >= 0) {
      current[index].quantity += delta;
      if (current[index].quantity <= 0) {
        current.removeAt(index);
      }
      items.value = current;
    }
  }

  static void clear() {
    items.value = <CartItem>[];
  }

  static double get total =>
      items.value.fold(0.0, (acc, item) => acc + (item.price * item.quantity));

  static int get totalCount =>
      items.value.fold(0, (acc, item) => acc + item.quantity);
}

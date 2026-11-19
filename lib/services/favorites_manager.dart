import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1. MANAGER FAVORITE (SINCRONIZAT CU FIRESTORE)
class FavoritesManager {
  static final ValueNotifier<Set<String>> favorites =
      ValueNotifier<Set<String>>(<String>{});

  static String get _userId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'user_test';

  static Future<void> loadFavorites() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_userId)
          .get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('favoriteProductIds')) {
        final List<dynamic> ids = doc.get('favoriteProductIds');
        favorites.value = Set<String>.from(ids.cast<String>());
      } else {
        favorites.value = <String>{};
      }
    } catch (e) {
      debugPrint('Eroare la incarcarea favoritelor: $e');
    }
  }

  static Future<void> toggle(String productId) async {
    final updated = Set<String>.from(favorites.value);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    favorites.value = updated;

    try {
      await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_userId)
          .set({
        'favoriteProductIds': updated.toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Eroare la salvarea favoritelor: $e');
    }
  }
}

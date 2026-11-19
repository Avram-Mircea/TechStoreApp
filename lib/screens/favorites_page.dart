import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../services/cart_manager.dart';
import '../services/favorites_manager.dart';

// PAGINA FAVORITE
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produse favorite')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavoritesManager.favorites,
        builder: (context, favorites, child) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Nu ai produse adăugate la favorite momentan.'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data!.docs
                  .where((doc) => favorites.contains(doc.id))
                  .toList();

              if (products.isEmpty) {
                return const Center(
                  child: Text('Produsele favorite nu au fost găsite.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final doc = products[index];
                  final product = doc.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        product['imageUrl'] ?? '',
                        width: 55,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.devices_rounded, color: kNavy),
                      ),
                      title: Text(
                        product['name'] ?? 'Produs',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: kNavy),
                      ),
                      subtitle: Text(
                        '${product['price']} lei',
                        style: const TextStyle(
                            color: kOrange, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart_rounded,
                                color: kNavy),
                            onPressed: () {
                              CartManager.addProduct(doc.id, product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: kNavy,
                                  content: Text(
                                      '${product['name']} adăugat în coș!'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent),
                            onPressed: () => FavoritesManager.toggle(doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

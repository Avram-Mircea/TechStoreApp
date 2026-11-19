import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/cart_manager.dart';
import '../services/favorites_manager.dart';
import 'account/reviews_page.dart';

// PAGINA DETALII PRODUS
class ProductDetailPage extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> product;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final String productName = product['name'] ?? 'Produs TechStore';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(productName),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritesManager.favorites,
            builder: (context, favs, child) {
              final isFav = favs.contains(productId);
              return IconButton(
                onPressed: () => FavoritesManager.toggle(productId),
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: kOrange,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kBorderColor),
              ),
              child: Image.network(
                product['imageUrl'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.devices_other_rounded,
                  size: 90,
                  color: kNavy,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kOrangeSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'În stoc • Livrare rapidă & Garanție 24 luni',
                style: TextStyle(
                  color: kOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              productName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${product['price']} lei',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: kOrange,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined,
                          color: kNavy, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Garanție 24 luni emisă automat în cont la achiziție',
                          style: TextStyle(fontSize: 13, color: kNavy),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 18),
                  Row(
                    children: [
                      Icon(Icons.assignment_return_outlined,
                          color: kOrange, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Drept de retur simplu în 30 de zile direct din aplicație',
                          style: TextStyle(fontSize: 13, color: kNavy),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Review-uri produs',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: kNavy),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsPage(
                          initialProductName: productName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review_outlined, color: kOrange),
                  label: const Text(
                    'Scrie un review',
                    style: TextStyle(color: kOrange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                CartManager.addProduct(productId, product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: kNavy,
                    content: Text('$productName a fost adăugat în coș!'),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Adaugă în coș',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

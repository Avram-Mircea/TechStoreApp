import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../services/cart_manager.dart';
import '../services/favorites_manager.dart';
import '../services/user_profile_manager.dart';
import 'product_detail_page.dart';
import 'account/notifications_page.dart';

// PAGINA ACASA (CAUTARE, BANNER, FILTRU CATEGORII, GRID PRODUSE)
class HomePage extends StatefulWidget {
  final String? initialCategory;
  final VoidCallback? onClearCategory;

  const HomePage({
    super.key,
    this.initialCategory,
    this.onClearCategory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: kNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: kOrange, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'TechStore',
              style: TextStyle(
                color: kNavy,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              '.',
              style: TextStyle(
                color: kOrange,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: UserProfileManager.profile,
            builder: (context, profileData, child) {
              final List<dynamic> notifs = profileData['notifications'] ?? [];
              final unread = notifs.where((n) => n['read'] == false).length;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()),
                    );
                  },
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    backgroundColor: kOrange,
                    label: Text('$unread'),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: kNavy, size: 26),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARA DE CAUTARE CU UMBRA FINA SI CONTUR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A142B4A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Caută telefoane, laptopuri, accesorii...',
                  hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                  prefixIcon: const Icon(Icons.search_rounded, color: kNavy),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: kNavy),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BANNER PROMOTIONAL PERSONALIZAT TECHSTORE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, kNavyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33142B4A),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NOUA GENERAȚIE TECH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Performanță în fiecare detaliu.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Garanție digitală 24 luni și livrare rapidă în locker.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(
                      Icons.devices_other_rounded,
                      color: kOrange,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // CHIP FILTRU CATEGORIE DACA ESTE SELECTAT
            if (widget.initialCategory != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kOrangeSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kOrange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtru: ${widget.initialCategory}',
                            style: const TextStyle(
                              color: kOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: widget.onClearCategory,
                            child: const Icon(Icons.close,
                                size: 16, color: kOrange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produse recomandate',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // GRID PRODUSE DIN FIRESTORE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Eroare Firebase: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final category =
                      (data['category'] ?? '').toString().toLowerCase();

                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase());
                  final matchesCategory = widget.initialCategory == null ||
                      category.contains(
                          widget.initialCategory!.toLowerCase()) ||
                      name.contains(widget.initialCategory!
                          .substring(0, 4)
                          .toLowerCase());

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Nu am găsit produse pentru criteriul selectat.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final product = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              productId: doc.id,
                              product: product,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorderColor),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A142B4A),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Image.network(
                                        product['imageUrl'] ?? '',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.devices_other_rounded,
                                          size: 52,
                                          color: kNavy,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: ValueListenableBuilder<Set<String>>(
                                      valueListenable:
                                          FavoritesManager.favorites,
                                      builder: (context, favorites, child) {
                                        final isFavorite =
                                            favorites.contains(doc.id);
                                        return InkWell(
                                          onTap: () =>
                                              FavoritesManager.toggle(doc.id),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isFavorite
                                                  ? kOrangeSoft
                                                  : kBgLight,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isFavorite
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                      .favorite_border_rounded,
                                              color: kOrange,
                                              size: 19,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product['name'] ?? 'Produs',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: kNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${product['price']} lei',
                              style: const TextStyle(
                                color: kOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kNavy,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                onPressed: () {
                                  CartManager.addProduct(doc.id, product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: kNavy,
                                      content: Text(
                                        '${product['name']} a fost adăugat în coș!',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 15),
                                label: const Text(
                                  'În coș',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

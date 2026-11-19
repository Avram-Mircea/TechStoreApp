import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_manager.dart';
import '../services/favorites_manager.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'account_page.dart';

// NAVIGATIA PRINCIPALA
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  String? selectedCategoryFilter;

  void _openCategoryInHome(String category) {
    setState(() {
      selectedCategoryFilter = category;
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        initialCategory: selectedCategoryFilter,
        onClearCategory: () {
          setState(() => selectedCategoryFilter = null);
        },
      ),
      CategoriesPage(onSelectCategory: _openCategoryInHome),
      const FavoritesPage(),
      const CartPage(),
      const AccountPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorderColor, width: 1)),
        ),
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: FavoritesManager.favorites,
          builder: (context, favs, child) {
            return ValueListenableBuilder<List<CartItem>>(
              valueListenable: CartManager.items,
              builder: (context, cartItems, innerChild) {
                final cartCount = CartManager.totalCount;
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  currentIndex: selectedIndex,
                  selectedItemColor: kOrange,
                  unselectedItemColor: Colors.blueGrey.shade400,
                  selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12),
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Acasă',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined),
                      activeIcon: Icon(Icons.grid_view_rounded),
                      label: 'Categorii',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildBadgeIcon(Icons.favorite_border, favs.length),
                      activeIcon: _buildBadgeIcon(Icons.favorite, favs.length),
                      label: 'Favorite',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildBadgeIcon(
                          Icons.shopping_bag_outlined, cartCount),
                      activeIcon:
                          _buildBadgeIcon(Icons.shopping_bag, cartCount),
                      label: 'Coș',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person_rounded),
                      label: 'Cont',
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count) {
    if (count <= 0) return Icon(icon);
    return Badge(
      backgroundColor: kOrange,
      label: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      child: Icon(icon),
    );
  }
}

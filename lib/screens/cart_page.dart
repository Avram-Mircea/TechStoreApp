import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_manager.dart';
import '../services/user_profile_manager.dart';
import 'account/cards_page.dart';

// PAGINA COS DE CUMPARATURI & PLATA COMANDA
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _deliveryMethod = 'Locker';

  Future<void> _checkout() async {
    final items = CartManager.items.value;
    if (items.isEmpty) return;

    final profileData =
        Map<String, dynamic>.from(UserProfileManager.profile.value);
    final List<dynamic> cards = profileData['cards'] ?? [];
    final String selectedCard =
        cards.isNotEmpty ? cards.first['number'] : 'Plata cu cardul';

    final double finalTotal = CartManager.total;
    final String orderId =
        'TS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final String today =
        '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';

    final newOrder = <String, dynamic>{
      'id': orderId,
      'date': today,
      'total': finalTotal,
      'status': 'În curs de livrare',
      'paymentMethod': selectedCard,
      'deliveryPoint': _deliveryMethod == 'Locker'
          ? (profileData['favoriteLocker'] ?? 'Locker Electroputere Mall')
          : (profileData['address'] ?? 'Livrare prin curier la adresă'),
      'items': items
          .map((e) => <String, dynamic>{
                'name': e.name,
                'price': e.price,
                'quantity': e.quantity,
              })
          .toList(),
    };

    final List<dynamic> orders =
        List<dynamic>.from(profileData['orders'] ?? []);
    orders.insert(0, newOrder);
    profileData['orders'] = orders;

    final List<dynamic> warranties =
        List<dynamic>.from(profileData['warranties'] ?? []);
    for (final item in items) {
      warranties.insert(0, <String, dynamic>{
        'productName': item.name,
        'orderId': orderId,
        'validUntil':
            '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year + 2}',
        'serial': 'SN-${DateTime.now().millisecondsSinceEpoch % 999999}',
        'status': 'Activă (24 luni)',
      });
    }
    profileData['warranties'] = warranties;

    await UserProfileManager.saveProfile(profileData);
    await UserProfileManager.addNotification(
      'Comanda $orderId a fost plasată!',
      'Valoare: ${finalTotal.toStringAsFixed(2)} lei. Certificatele de garanție au fost salvate în cont.',
    );

    CartManager.clear();

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Comandă confirmată!')),
            ],
          ),
          content: Text(
            'Comanda $orderId în valoare de ${finalTotal.toStringAsFixed(2)} lei a fost înregistrată.\n\n'
            'Poți vedea comanda și garanția produselor în secțiunea Cont.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coș de cumpărături')),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartManager.items,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 72, color: Colors.blueGrey),
                  SizedBox(height: 12),
                  Text(
                    'Coșul tău este gol',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kNavy),
                  ),
                  SizedBox(height: 4),
                  Text('Adaugă produse din catalog pentru a plasa o comandă.'),
                ],
              ),
            );
          }

          final total = CartManager.total;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: ListTile(
                          leading: Image.network(
                            item.imageUrl,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.devices_rounded, color: kNavy),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: kNavy),
                          ),
                          subtitle: Text(
                            '${item.price} lei',
                            style: const TextStyle(
                                color: kOrange, fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: kNavy),
                                onPressed: () =>
                                    CartManager.updateQuantity(item.id, -1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: kOrange),
                                onPressed: () =>
                                    CartManager.updateQuantity(item.id, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: UserProfileManager.profile,
                      builder: (context, profile, innerChild) {
                        final locker = profile['favoriteLocker'] ??
                            'Locker Electroputere Mall Craiova';
                        final address =
                            profile['address'] ?? 'Bulevardul Decebal nr. 107';
                        final List<dynamic> cards = profile['cards'] ?? [];
                        final cardText = cards.isNotEmpty
                            ? '${cards.first['type']} (${cards.first['number']})'
                            : 'Card bancar salvat';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metodă de livrare',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kNavy),
                            ),
                            const SizedBox(height: 8),
                            _buildSelectOption(
                              selected: _deliveryMethod == 'Locker',
                              title: 'Ridicare din Punct de Livrare Favorit',
                              subtitle: locker,
                              icon: Icons.inventory_2_outlined,
                              onTap: () =>
                                  setState(() => _deliveryMethod = 'Locker'),
                            ),
                            const SizedBox(height: 8),
                            _buildSelectOption(
                              selected: _deliveryMethod == 'Curier',
                              title: 'Livrare prin Curier la Adresă',
                              subtitle: address,
                              icon: Icons.local_shipping_outlined,
                              onTap: () =>
                                  setState(() => _deliveryMethod = 'Curier'),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorderColor),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.credit_card_rounded,
                                    color: kNavy),
                                title: const Text(
                                  'Plata cu cardul salvat',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(cardText),
                                trailing: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CardsPage()),
                                    );
                                  },
                                  child: const Text('Modifică'),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: kBorderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total comandă:',
                            style: TextStyle(color: Colors.blueGrey)),
                        Text(
                          '${total.toStringAsFixed(2)} lei',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: kNavy,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _checkout,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text(
                        'Plătește comanda',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectOption({
    required bool selected,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? kOrangeSoft : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kOrange : kBorderColor,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? kOrange : kNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kNavy,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? kOrange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

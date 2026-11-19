import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 4. COMENZILE MELE
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comenzile mele')),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> orders = profile['orders'] ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('Nu ai plasat nicio comandă încă.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comanda ${order['id']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kNavy),
                        ),
                        Text(
                          '${order['total']} lei',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Data: ${order['date']} • ${order['deliveryPoint']}'),
                    const SizedBox(height: 4),
                    Text(
                      order['status'] ?? 'Înregistrată',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = Map<String, dynamic>.from(profile);
                          final List<dynamic> returns =
                              List<dynamic>.from(updated['returns'] ?? []);
                          returns.insert(0, <String, dynamic>{
                            'orderId': order['id'],
                            'amount': order['total'],
                            'status': 'Cerere aprobată • Rambursare pe card',
                          });
                          updated['returns'] = returns;
                          await UserProfileManager.saveProfile(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: kNavy,
                                  content:
                                      Text('Solicitarea de retur a fost creată!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.assignment_return_outlined,
                            size: 18),
                        label: const Text('Returnează comanda'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

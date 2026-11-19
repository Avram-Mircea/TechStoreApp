import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 5. RETURURILE MELE
class ReturnsPage extends StatelessWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retururile mele')),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> returns = profile['returns'] ?? [];
          if (returns.isEmpty) {
            return const Center(
                child: Text('Nu ai nicio cerere de retur activă.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final r = returns[index] as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                child: ListTile(
                  leading:
                      const Icon(Icons.assignment_return_rounded, color: kOrange),
                  title: Text('Retur comanda ${r['orderId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(r['status'] ?? ''),
                  trailing: Text(
                    '${r['amount']} lei',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

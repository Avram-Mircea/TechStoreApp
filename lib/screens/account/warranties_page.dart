import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 6. GARANTIILE MELE
class WarrantiesPage extends StatelessWidget {
  const WarrantiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garanții & Service')),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> warranties = profile['warranties'] ?? [];
          if (warranties.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Certificatele de garanție se emit automat la plasarea unei comenzi.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: warranties.length,
            itemBuilder: (context, index) {
              final w = warranties[index] as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                      const Icon(Icons.verified_user_rounded, color: kNavy),
                  title: Text(w['productName'] ?? 'Produs',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Serie: ${w['serial']} • Expiră la: ${w['validUntil']}\nStatus: ${w['status']}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

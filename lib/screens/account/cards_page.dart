import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 2. CARDURILE MELE
class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  void _showAddCardDialog() {
    final numberCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adaugă card bancar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Ultimele 4 cifre (ex: 5120)'),
            ),
            TextField(
              controller: holderCtrl,
              decoration: const InputDecoration(labelText: 'Nume titular'),
            ),
            TextField(
              controller: expiryCtrl,
              decoration:
                  const InputDecoration(labelText: 'Data expirării (LL/AA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Anulează')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kNavy, foregroundColor: Colors.white),
            onPressed: () async {
              final digits = numberCtrl.text.trim().isEmpty
                  ? '5120'
                  : numberCtrl.text.trim();
              final updated =
                  Map<String, dynamic>.from(UserProfileManager.profile.value);
              final List<dynamic> cards =
                  List<dynamic>.from(updated['cards'] ?? []);
              cards.insert(0, <String, dynamic>{
                'number': '**** **** **** $digits',
                'holder': holderCtrl.text.trim().isEmpty
                    ? 'TITULAR CARD'
                    : holderCtrl.text.trim().toUpperCase(),
                'expiry': expiryCtrl.text.trim().isEmpty
                    ? '12/29'
                    : expiryCtrl.text.trim(),
                'type': 'Mastercard TechStore',
              });
              updated['cards'] = cards;
              await UserProfileManager.saveProfile(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardurile mele')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        onPressed: _showAddCardDialog,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Adaugă card'),
      ),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> cards = profile['cards'] ?? [];

          if (cards.isEmpty) {
            return const Center(child: Text('Nu ai niciun card salvat.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (context, idx) {
              final card = cards[idx] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: idx.isEven
                        ? [kNavy, kNavyLight]
                        : [kNavy, kOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26142B4A),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card['type'] ?? 'Visa Debit',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () async {
                            final updated =
                                Map<String, dynamic>.from(profile);
                            final list =
                                List<dynamic>.from(updated['cards'] ?? []);
                            list.removeAt(idx);
                            updated['cards'] = list;
                            await UserProfileManager.saveProfile(updated);
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card['number'] ?? '**** **** **** 4829',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card['holder'] ?? 'TITULAR',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'EXP: ${card['expiry'] ?? '09/29'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
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

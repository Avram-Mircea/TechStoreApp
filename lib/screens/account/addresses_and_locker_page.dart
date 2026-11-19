import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 3. ADRESA & PUNCT DE LIVRARE FAVORIT
class AddressesAndLockerPage extends StatefulWidget {
  const AddressesAndLockerPage({super.key});

  @override
  State<AddressesAndLockerPage> createState() => _AddressesAndLockerPageState();
}

class _AddressesAndLockerPageState extends State<AddressesAndLockerPage> {
  final List<String> lockers = const [
    'Locker Electroputere Mall Craiova',
    'Locker Universitatea din Craiova (Centru)',
    'Locker Mercur Center Craiova',
    'Locker Promenada Mall Craiova',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adresă & Punct de livrare')),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final currentLocker = profile['favoriteLocker'] ??
              'Locker Electroputere Mall Craiova';
          final currentAddress =
              profile['address'] ?? 'Bulevardul Decebal nr. 107, Craiova';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Adresă livrare prin curier',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kNavy),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderColor),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.home_work_outlined, color: kOrange),
                  title: const Text('Adresa principală',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(currentAddress),
                  trailing: TextButton(
                    onPressed: () {
                      final ctrl =
                          TextEditingController(text: currentAddress);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Modifică adresa'),
                          content: TextField(
                            controller: ctrl,
                            decoration: const InputDecoration(
                                labelText: 'Stradă, număr, bloc, oraș'),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                final updated =
                                    Map<String, dynamic>.from(profile);
                                updated['address'] = ctrl.text.trim();
                                await UserProfileManager.saveProfile(updated);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Salvează'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Editează'),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Alege Punctul de Livrare Favorit (Locker)',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kNavy),
              ),
              const SizedBox(height: 8),
              ...lockers.map((locker) {
                final isSelected = locker == currentLocker;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? kOrangeSoft : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? kOrange : kBorderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.inventory_2_outlined,
                      color: isSelected ? kOrange : kNavy,
                    ),
                    title: Text(
                      locker,
                      style: TextStyle(
                        color: kNavy,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: kOrange)
                        : null,
                    onTap: () async {
                      final updated = Map<String, dynamic>.from(profile);
                      updated['favoriteLocker'] = locker;
                      await UserProfileManager.saveProfile(updated);
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

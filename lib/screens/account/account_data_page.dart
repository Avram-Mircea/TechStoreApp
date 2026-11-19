import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// SUB-PAGINI PENTRU CONTUL MEU

// 1. DATELE CONTULUI
class AccountDataPage extends StatefulWidget {
  const AccountDataPage({super.key});

  @override
  State<AccountDataPage> createState() => _AccountDataPageState();
}

class _AccountDataPageState extends State<AccountDataPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    final data = UserProfileManager.profile.value;
    _nameCtrl = TextEditingController(text: data['name'] ?? '');
    _phoneCtrl = TextEditingController(text: data['phone'] ?? '');
    _cityCtrl = TextEditingController(text: data['city'] ?? 'Craiova, Dolj');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = Map<String, dynamic>.from(UserProfileManager.profile.value);
    updated['name'] = _nameCtrl.text.trim();
    updated['phone'] = _phoneCtrl.text.trim();
    updated['city'] = _cityCtrl.text.trim();
    await UserProfileManager.saveProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: kNavy,
            content: Text('Datele contului au fost salvate!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'client@techstore.ro';
    return Scaffold(
      appBar: AppBar(title: const Text('Datele contului')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nume și Prenume',
              prefixIcon: Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Număr de telefon',
              prefixIcon: Icon(Icons.phone_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(
              labelText: 'Oraș / Județ',
              prefixIcon: Icon(Icons.location_city_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email ($email)',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvează modificările'),
            ),
          ),
        ],
      ),
    );
  }
}

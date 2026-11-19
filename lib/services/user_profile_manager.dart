import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 3. MANAGER PROFIL UTILIZATOR (SINCRONIZAT CU FIRESTORE)
class UserProfileManager {
  static final ValueNotifier<Map<String, dynamic>> profile =
      ValueNotifier<Map<String, dynamic>>(<String, dynamic>{});

  static String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'user_test';

  static Map<String, dynamic> _defaultProfile() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'client@techstore.ro';
    final defaultName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : email.split('@').first;

    return <String, dynamic>{
      'name': defaultName,
      'phone': '0740 123 456',
      'city': 'Craiova, Dolj',
      'address': 'Bulevardul Decebal nr. 107, Craiova',
      'favoriteLocker': 'Locker Electroputere Mall Craiova',
      'avatarUrl': 'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
      'cards': <Map<String, dynamic>>[
        <String, dynamic>{
          'number': '**** **** **** 4829',
          'holder': defaultName.toUpperCase(),
          'expiry': '09/29',
          'type': 'Visa Debit',
        }
      ],
      'orders': <Map<String, dynamic>>[],
      'returns': <Map<String, dynamic>>[],
      'warranties': <Map<String, dynamic>>[],
      'reviews': <Map<String, dynamic>>[],
      'notifications': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Bine ai venit pe TechStore!',
          'body':
              'Contul tău este activ. Poți salva adrese, carduri și urmări comenzile tale.',
          'date': 'Astăzi',
          'read': false,
        },
      ],
    };
  }

  static Future<void> loadProfile() async {
    final base = _defaultProfile();
    if (FirebaseAuth.instance.currentUser == null) {
      profile.value = base;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        profile.value = <String, dynamic>{...base, ...data};
      } else {
        profile.value = base;
        await saveProfile(base);
      }
    } catch (e) {
      profile.value = base;
      debugPrint('Profil incarcat local: $e');
    }
  }

  static Future<void> saveProfile(Map<String, dynamic> updated) async {
    profile.value = Map<String, dynamic>.from(updated);
    if (FirebaseAuth.instance.currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(uid)
          .set(updated, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Eroare la salvarea profilului: $e');
    }
  }

  static Future<void> addNotification(String title, String body) async {
    final current = Map<String, dynamic>.from(profile.value);
    final List<dynamic> notifs =
        List<dynamic>.from(current['notifications'] ?? <dynamic>[]);
    notifs.insert(0, <String, dynamic>{
      'title': title,
      'body': body,
      'date': 'Acum',
      'read': false,
    });
    current['notifications'] = notifs;
    await saveProfile(current);
  }
}

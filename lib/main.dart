import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/favorites_manager.dart';
import 'services/user_profile_manager.dart';
export 'app.dart';

// Compatibilitate automată cu test/widget_test.dart
typedef MyApp = TechStoreApp;

// PUNCTUL DE INTRARE IN APLICATIE
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FavoritesManager.loadFavorites();
  await UserProfileManager.loadProfile();

  runApp(const TechStoreApp());
}

import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/main_navigation.dart';

class TechStoreApp extends StatelessWidget {
  const TechStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechStore',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kNavy,
          primary: kNavy,
          secondary: kOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kNavy,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kNavy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

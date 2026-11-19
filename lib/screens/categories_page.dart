import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// PAGINA CATEGORII
class CategoriesPage extends StatelessWidget {
  final ValueChanged<String>? onSelectCategory;

  const CategoriesPage({super.key, this.onSelectCategory});

  final List<String> categories = const [
    'Telefoane',
    'Laptopuri',
    'Tablete',
    'Casti si audio',
    'Smartwatch-uri',
    'Accesorii',
  ];

  final List<IconData> icons = const [
    Icons.smartphone_rounded,
    Icons.laptop_mac_rounded,
    Icons.tablet_mac_rounded,
    Icons.headphones_rounded,
    Icons.watch_rounded,
    Icons.cable_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorii produse')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08142B4A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kOrangeSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icons[index], color: kOrange, size: 24),
              ),
              title: Text(
                categories[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text('Explorează produsele disponibile'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: kNavy),
              onTap: () {
                if (onSelectCategory != null) {
                  onSelectCategory!(categories[index]);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

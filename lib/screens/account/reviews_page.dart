import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 7. REVIEW-URILE MELE
class ReviewsPage extends StatefulWidget {
  final String? initialProductName;
  const ReviewsPage({super.key, this.initialProductName});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  void _showAddReviewDialog() {
    final prodCtrl =
        TextEditingController(text: widget.initialProductName ?? '');
    final commentCtrl = TextEditingController();
    int stars = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Adaugă un review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: prodCtrl,
                decoration:
                    const InputDecoration(labelText: 'Numele produsului'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setDialogState(() => stars = i + 1),
                    icon: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: kOrange,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: commentCtrl,
                decoration:
                    const InputDecoration(labelText: 'Comentariul tău'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy, foregroundColor: Colors.white),
              onPressed: () async {
                final updated =
                    Map<String, dynamic>.from(UserProfileManager.profile.value);
                final list = List<dynamic>.from(updated['reviews'] ?? []);
                list.insert(0, <String, dynamic>{
                  'product': prodCtrl.text.trim().isEmpty
                      ? 'Produs TechStore'
                      : prodCtrl.text.trim(),
                  'stars': stars,
                  'comment': commentCtrl.text.trim(),
                });
                updated['reviews'] = list;
                await UserProfileManager.saveProfile(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Publică'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review-urile mele')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        onPressed: _showAddReviewDialog,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Adaugă review'),
      ),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> reviews = profile['reviews'] ?? [];
          if (reviews.isEmpty) {
            return const Center(
                child: Text('Nu ai adăugat niciun review încă.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final rev = reviews[index] as Map<String, dynamic>;
              final int stars = (rev['stars'] ?? 5) as int;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(rev['product'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(rev['comment'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      stars,
                      (i) => const Icon(Icons.star_rounded,
                          color: kOrange, size: 18),
                    ),
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

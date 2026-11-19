import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/user_profile_manager.dart';

// 8. NOTIFICARI
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificări'),
        actions: [
          TextButton(
            onPressed: () async {
              final updated =
                  Map<String, dynamic>.from(UserProfileManager.profile.value);
              final List<dynamic> notifs =
                  List<dynamic>.from(updated['notifications'] ?? []);
              for (final n in notifs) {
                n['read'] = true;
              }
              updated['notifications'] = notifs;
              await UserProfileManager.saveProfile(updated);
            },
            child: const Text('Marchează citite'),
          ),
        ],
      ),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: UserProfileManager.profile,
        builder: (context, profile, child) {
          final List<dynamic> notifs = profile['notifications'] ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final n = notifs[index] as Map<String, dynamic>;
              final isUnread = n['read'] == false;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isUnread ? kOrangeSoft : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isUnread ? kOrange : kBorderColor),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: isUnread ? kOrange : Colors.blueGrey,
                  ),
                  title: Text(
                    n['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kNavy),
                  ),
                  subtitle: Text(n['body'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

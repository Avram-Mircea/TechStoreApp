import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/favorites_manager.dart';
import '../services/user_profile_manager.dart';
import 'account/account_data_page.dart';
import 'account/cards_page.dart';
import 'account/addresses_and_locker_page.dart';
import 'account/orders_page.dart';
import 'account/returns_page.dart';
import 'account/warranties_page.dart';
import 'account/reviews_page.dart';
import 'account/notifications_page.dart';

// PAGINA CONTUL MEU (DESIGN UNIC TECHSTORE LIGHT + NAVY + ORANGE)
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completează emailul și parola!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FavoritesManager.loadFavorites();
      await UserProfileManager.loadProfile();
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la autentificare: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Introdu un email valid și o parolă de minim 6 caractere!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FavoritesManager.loadFavorites();
      await UserProfileManager.loadProfile();
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la înregistrare: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAvatarPickerDialog(Map<String, dynamic> profileData) {
    final List<String> presetAvatars = [
      'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140061.png',
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    ];
    final urlCtrl =
        TextEditingController(text: profileData['avatarUrl'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alege poza de profil',
              style: TextStyle(
                color: kNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: presetAvatars.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  return GestureDetector(
                    onTap: () async {
                      final updated = Map<String, dynamic>.from(profileData);
                      updated['avatarUrl'] = presetAvatars[idx];
                      await UserProfileManager.saveProfile(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: kBgLight,
                      backgroundImage: NetworkImage(presetAvatars[idx]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(
                labelText: 'Sau introdu URL-ul unei imagini',
                filled: true,
                fillColor: kBgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (urlCtrl.text.trim().isNotEmpty) {
                    final updated = Map<String, dynamic>.from(profileData);
                    updated['avatarUrl'] = urlCtrl.text.trim();
                    await UserProfileManager.saveProfile(updated);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salvează poza'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          return _buildAuthForm();
        }

        return ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: UserProfileManager.profile,
          builder: (context, profileData, child) {
            final String displayName =
                profileData['name'] ?? user.email ?? 'Utilizator';
            final String avatarUrl = profileData['avatarUrl'] ??
                'https://cdn-icons-png.flaticon.com/512/4140/4140048.png';
            final List<dynamic> orders = profileData['orders'] ?? [];
            final List<dynamic> cards = profileData['cards'] ?? [];
            final List<dynamic> warranties = profileData['warranties'] ?? [];
            final List<dynamic> notifs = profileData['notifications'] ?? [];
            final int unreadNotifs =
                notifs.where((n) => n['read'] == false).length;

            return Scaffold(
              backgroundColor: kBgLight,
              appBar: AppBar(
                title: const Text('Contul meu'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsPage()),
                        );
                      },
                      icon: Badge(
                        isLabelVisible: unreadNotifs > 0,
                        backgroundColor: kOrange,
                        label: Text('$unreadNotifs'),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: kNavy, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CARD PROFIL CU GRADIENT NAVY SI ACCENTE PORTOCALII
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kNavy, kNavyLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2E142B4A),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showAvatarPickerDialog(profileData),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: kOrange, width: 2.5),
                                  ),
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: NetworkImage(avatarUrl),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: kOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountDataPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0x26FFFFFF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            color: kOrange, size: 14),
                                        SizedBox(width: 5),
                                        Text(
                                          'Editează profilul',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. CELE 3 CARDURI STATISTICE RAPIDE
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            icon: Icons.shopping_bag_outlined,
                            count: '${orders.length}',
                            label: 'Comenzi',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const OrdersPage()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickStatCard(
                            icon: Icons.credit_card_rounded,
                            count: '${cards.length}',
                            label: 'Carduri',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CardsPage()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickStatCard(
                            icon: Icons.verified_user_outlined,
                            count: '${warranties.length}',
                            label: 'Garanții',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WarrantiesPage()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // 3. SECTIUNEA ACTIVITATE SI COMENZI
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Activitatea mea',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kNavy,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08142B4A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.receipt_long_rounded,
                            title: 'Comenzile mele',
                            subtitle: 'Istoric achiziții și status livrare',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const OrdersPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.verified_outlined,
                            title: 'Garanții & Service',
                            subtitle: 'Certificate digitale de garanție 24 luni',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WarrantiesPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.assignment_return_outlined,
                            title: 'Retururile mele',
                            subtitle: 'Produse returnate și rambursări',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReturnsPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.rate_review_outlined,
                            title: 'Review-urile mele',
                            subtitle: 'Recenziile adăugate produselor',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewsPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 4. SECTIUNEA DATE CONT, PLATI SI LIVRARE
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Setări cont & livrare',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kNavy,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08142B4A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Datele contului',
                            subtitle: 'Nume, număr de telefon, oraș',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountDataPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.credit_card_rounded,
                            title: 'Cardurile mele',
                            subtitle: 'Gestionează cardurile salvate pentru plăți',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CardsPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.location_on_outlined,
                            title: 'Adresă & Punct de livrare favorit',
                            subtitle: profileData['favoriteLocker'] ??
                                'Locker Electroputere Mall Craiova',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddressesAndLockerPage()),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildMenuTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notificări',
                            subtitle: 'Mesaje și alerte despre comenzile tale',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // BUTON DECONECTARE
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kOrange,
                          side: const BorderSide(color: kOrange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          await FavoritesManager.loadFavorites();
                          await UserProfileManager.loadProfile();
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Deconectare din cont',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08142B4A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kOrangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kOrange, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kNavy,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: kBgLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kNavy, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: kNavy,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12.5, color: Colors.blueGrey),
      ),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.blueGrey),
    );
  }

  Widget _buildAuthForm() {
    return Scaffold(
      appBar: AppBar(title: const Text('Contul meu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D142B4A),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kOrangeSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 52, color: kOrange),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bine ai venit la TechStore!',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: kNavy),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conectează-te pentru a gestiona comenzile și garanțiile tale.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: kBgLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Parolă',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: kBgLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _signIn,
                      child: const Text('Autentificare',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kOrange,
                        side: const BorderSide(color: kOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _register,
                      child: const Text('Creează cont nou',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

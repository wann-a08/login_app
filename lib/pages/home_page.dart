
import 'package:flutter/material.dart';
import '../core/app_session.dart';

// Class untuk halaman Home dan dashboard admin.
class HomePage extends StatelessWidget {
  final AppSession session;
  const HomePage({super.key, required this.session});

  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F6FA);

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message belum tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HomePage.navy,
          foregroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.school_outlined),
              SizedBox(width: 10),
              Text('Admin Dashboard'),
            ],
          ),
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang, Admin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih menu untuk mengelola informasi sekolah.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // Grid tombol menyesuaikan lebar layar.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final int columns =
                    constraints.maxWidth >= 750
                        ? 3
                        : constraints.maxWidth >= 450
                        ? 2
                        : 1;

                    const double spacing = 16;
                    final double cardWidth =
                        (constraints.maxWidth -
                            (spacing * (columns - 1))) /
                            columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _MenuCard(
                          width: cardWidth,
                          title: 'Lihat Data',
                          description: 'Lihat dan cari data sekolah',
                          icon: Icons.search,
                          color: const Color(0xFF2563EB),
                          onTap: () => _navigate(context, '/data'),
                        ),
                        _MenuCard(
                          width: cardWidth,
                          title: 'Input Data',
                          description: 'Tambahkan data baru',
                          icon: Icons.add_box_outlined,
                          color: const Color(0xFF059669),
                          onTap: () => _navigate(context, '/inputdata'),
                        ),
                        _MenuCard(
                          width: cardWidth,
                          title: 'Profiles',
                          description: 'Informasi profil pengguna',
                          icon: Icons.person_outline,
                          color: const Color(0xFF7C3AED),
                          onTap: () => _showMessage(context, '/profiles'),
                        ),
                        _MenuCard(
                          width: cardWidth,
                          title: 'Settings',
                          description: 'Pengaturan aplikasi',
                          icon: Icons.settings_outlined,
                          color: const Color(0xFFD97706),
                          onTap: () => _showMessage(context, '/settings'),
                        ),
                        _MenuCard(
                          width: cardWidth,
                          title: 'Logout',
                          description: 'Keluar dari dashboard admin',
                          icon: Icons.logout,
                          color: const Color(0xFFDC2626),
                          onTap: () async {
                            await session.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Sistem Informasi Sekolah',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Class untuk membuat tombol menu berbentuk card.
class _MenuCard extends StatelessWidget {
  final double width;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.width,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomePage.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

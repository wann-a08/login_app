import 'package:flutter/material.dart';

// Class untuk halaman pilihan input data.
class HomeInputPage extends StatelessWidget {
  const HomeInputPage({super.key});

  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Input Data'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pilih Jenis Input',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih data yang ingin ditambahkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol untuk menuju halaman input user.
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/input-user');
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Input User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol untuk menuju halaman input account.
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/input-account');
                  },
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Input Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

import 'package:flutter/material.dart';
import '../services/user_service.dart';

// Class untuk halaman Lihat Data user dari REST API.
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final UserService _userService = UserService();

  // Warna utama halaman.
  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F6FA);

  // Variabel untuk menyimpan data user dan status halaman.
  List<Map<String, dynamic>> users = [];

  bool isLoading = false;
  String? errorMessage;

  // Variabel pagination.
  int currentPage = 1;
  final int limit = 10;
  int total = 0;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // Mengambil data user beserta metadata pagination dari API.
  Future<void> loadUsers({int page = 1}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _userService.getUsers(
        page: page,
        limit: limit,
      );

      if (!mounted) return;

      setState(() {
        users = result['data'] as List<Map<String, dynamic>>;
        currentPage = result['page'] as int;
        total = result['total'] as int;
        totalPages = result['totalPages'] as int;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Mengambil inisial dari nama user untuk avatar.
  String getInitials(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return '?';

    final words = trimmedName.split(RegExp(r'\s+'));

    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }

    return '${words.first.characters.first}'
            '${words.last.characters.first}'
        .toUpperCase();
  }

  // Membuat warna avatar berdasarkan ID user.
  Color getAvatarColor(dynamic id) {
    const colors = [
      Color(0xFFDBEAFE),
      Color(0xFFD1FAE5),
      Color(0xFFF3E8FF),
      Color(0xFFFFEDD5),
      Color(0xFFFFE4E6),
    ];

    final index = (int.tryParse('$id') ?? 0).abs() % colors.length;
    return colors[index];
  }

  // Membuat warna teks avatar berdasarkan ID user.
  Color getAvatarTextColor(dynamic id) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF059669),
      Color(0xFF9333EA),
      Color(0xFFEA580C),
      Color(0xFFE11D48),
    ];

    final index = (int.tryParse('$id') ?? 0).abs() % colors.length;
    return colors[index];
  }

  // Widget satu card user berisi avatar, nama, dan email.
  Widget userCard(Map<String, dynamic> user) {
    final name = (user['name'] ?? 'Tanpa Nama').toString();
    final email = (user['email'] ?? 'Email tidak tersedia').toString();
    final id = user['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        children: [
          // Avatar lingkaran dengan inisial nama.
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getAvatarColor(id),
              shape: BoxShape.circle,
            ),
            child: Text(
              getInitials(name),
              style: TextStyle(
                color: getAvatarTextColor(id),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Nama dan email user.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Informasi ID user.
          Text(
            '#$id',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Membuat tombol navigasi pagination.
  Widget pageButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: navy,
        backgroundColor: Colors.white,
        disabledForegroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = total == 0
        ? 0
        : (currentPage - 1) * limit + 1;

    final lastItem = total == 0
        ? 0
        : ((currentPage * limit) < total
            ? currentPage * limit
            : total);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lihat Data',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: isLoading
                ? null
                : () => loadUsers(page: currentPage),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar User',
                style: TextStyle(
                  color: navy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lihat pengguna yang tersimpan di database.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Kartu informasi total pengguna.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_alt_outlined,
                        color: blue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pengguna',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total',
                            style: const TextStyle(
                              color: navy,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.storage_outlined,
                      color: blue,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Area daftar user dan pagination.
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul daftar user.
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 2,
                          right: 2,
                          bottom: 14,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Data Pengguna',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '$total data',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menampilkan loading, error, data, atau kondisi kosong.
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (isLoading && users.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: blue,
                                ),
                              );
                            }

                            if (errorMessage != null && users.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        errorMessage!,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () =>
                                            loadUsers(page: currentPage),
                                        child: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (users.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Belum ada data pengguna.',
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                // Daftar card yang bisa di-scroll.
                                ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    return userCard(users[index]);
                                  },
                                ),

                                // Indikator saat memuat halaman berikutnya.
                                if (isLoading)
                                  const Align(
                                    alignment: Alignment.topCenter,
                                    child: LinearProgressIndicator(
                                      color: blue,
                                      minHeight: 3,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Kontrol pagination tetap dipertahankan.
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Text(
                              'Menampilkan $firstItem–$lastItem dari $total',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                pageButton(
                                  icon: Icons.chevron_left,
                                  onPressed: currentPage > 1
                                      ? () => loadUsers(
                                            page: currentPage - 1,
                                          )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$currentPage / $totalPages',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                pageButton(
                                  icon: Icons.chevron_right,
                                  onPressed: currentPage < totalPages
                                      ? () => loadUsers(
                                            page: currentPage + 1,
                                          )
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/siswa.dart';
import 'siswa_form_page.dart';

// Halaman detail satu data siswa.
class SiswaDetailPage extends StatelessWidget {
  final Siswa siswa;
  const SiswaDetailPage({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    final values = <String, String>{
      'ID': '${siswa.id}',
      'NIPD': siswa.nipd,
      'Nama lengkap': siswa.namaLengkap,
      'Jenis kelamin': siswa.jenisKelamin == 'L' ? 'Laki-laki (L)' : 'Perempuan (P)',
      'Kelas': siswa.kelas,
      'Jurusan': siswa.jurusan,
      'Alamat': siswa.alamat?.isNotEmpty == true ? siswa.alamat! : 'Belum diisi',
      'Dibuat': siswa.createdAt?.toString() ?? '-',
      'Diperbarui': siswa.updatedAt?.toString() ?? '-',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Siswa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: values.entries.map((entry) => ListTile(
                      title: Text(entry.key, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      subtitle: Text(entry.value, style: const TextStyle(fontSize: 16)),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SiswaFormPage(siswa: siswa)));
                  if (context.mounted && changed == true) Navigator.pop(context, true);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Siswa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

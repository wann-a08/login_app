import 'dart:async';

import 'package:flutter/material.dart';

import '../models/siswa.dart';
import '../services/api_client.dart';
import '../services/siswa_service.dart';
import 'siswa_detail_page.dart';
import 'siswa_form_page.dart';

// Halaman daftar siswa dengan pagination, pencarian, filter, dan CRUD.
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final SiswaService _service = SiswaService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  static const Color navy = Color(0xFF172B4D);
  static const Color background = Color(0xFFF4F6FA);

  List<Siswa> _siswa = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  final int _limit = 10;
  int _total = 0;
  int _totalPages = 1;
  String? _kelas;
  String? _jurusan;
  String? _jenisKelamin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.getSiswa(
        page: page,
        limit: _limit,
        search: _searchController.text,
        kelas: _kelas,
        jurusan: _jurusan,
        jenisKelamin: _jenisKelamin,
      );
      if (!mounted) return;
      setState(() {
        _siswa = result.data;
        _page = result.meta.page;
        _total = result.meta.total;
        _totalPages = result.meta.totalPages < 1 ? 1 : result.meta.totalPages;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Gagal memuat data siswa.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load());
  }

  Future<void> _openForm({Siswa? siswa}) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SiswaFormPage(siswa: siswa)));
    if (mounted && changed == true) _load(page: _page);
  }

  Future<void> _openDetail(Siswa siswa) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SiswaDetailPage(siswa: siswa)));
    if (mounted && changed == true) _load(page: _page);
  }

  Future<void> _delete(Siswa siswa) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus siswa?'),
        content: Text('Data ${siswa.namaLengkap} (${siswa.nipd}) akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.delete(siswa.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data siswa berhasil dihapus.')));
      _load(page: _page);
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _resetFilters() {
    setState(() { _kelas = null; _jurusan = null; _jenisKelamin = null; });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Data Siswa'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        actions: [IconButton(tooltip: 'Muat ulang', onPressed: _loading ? null : () => _load(page: _page), icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah Siswa'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _searchChanged,
                      decoration: InputDecoration(
                        labelText: 'Cari nama atau NIPD',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _searchChanged(''); }),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                      Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _filter<String>(
                'Kelas',
                _kelas,
                ['10', '11', '12']
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                (value) {
                  setState(() => _kelas = value);
                  _load();
                },
              ),
              _filter<String>(
                'Jurusan',
                _jurusan,
                ['RPL', 'DKV', 'BIDI', 'TKJ', 'AK']
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                (value) {
                  setState(() => _jurusan = value);
                  _load();
                },
              ),
              _filter<String>(
                'Jenis kelamin',
                _jenisKelamin,
                const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                (value) {
                  setState(() => _jenisKelamin = value);
                  _load();
                },
              ),
          OutlinedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Reset filter'),
          ),
        ],
      ),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerLeft, child: Text('Total siswa: $_total')),
                  ],
                ),
              ),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: const TextStyle(color: Colors.red))),
              Expanded(
                child: _loading && _siswa.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _siswa.isEmpty
                        ? const Center(child: Text('Data siswa tidak ditemukan.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _siswa.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final siswa = _siswa[index];
                              return Card(
                                child: ListTile(
                                  onTap: () => _openDetail(siswa),
                                  leading: CircleAvatar(backgroundColor: const Color(0xFFDBEAFE), child: Text(siswa.namaLengkap.isEmpty ? '?' : siswa.namaLengkap.characters.first.toUpperCase())),
                                  title: Text(siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('NIPD: ${siswa.nipd} • Kelas ${siswa.kelas} ${siswa.jurusan}\n${siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'}'),
                                  isThreeLine: true,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) { if (value == 'edit') _openForm(siswa: siswa); if (value == 'delete') _delete(siswa); },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: !_loading || _page > 1 ? () => _load(page: _page - 1) : null, icon: const Icon(Icons.chevron_left)),
                    Text('Halaman $_page dari $_totalPages'),
                    IconButton(onPressed: !_loading && _page < _totalPages ? () => _load(page: _page + 1) : null, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _filter<T>(
  String label,
  T? value,
  List<DropdownMenuItem<T>> items,
  ValueChanged<T?> onChanged,
) {
  return SizedBox(
    width: 180,
    child: DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text(
            'Semua $label',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...items,
      ],
      onChanged: onChanged,
    ),
  );
}
}

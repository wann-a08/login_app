import 'package:flutter/material.dart';

import '../models/siswa.dart';
import '../services/api_client.dart';
import '../services/siswa_service.dart';

// Form tambah dan edit siswa; hanya mengirim field yang berubah saat edit.
class SiswaFormPage extends StatefulWidget {
  final Siswa? siswa;
  const SiswaFormPage({super.key, this.siswa});

  @override
  State<SiswaFormPage> createState() => _SiswaFormPageState();
}

class _SiswaFormPageState extends State<SiswaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nipd = TextEditingController();
  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  final _service = SiswaService();
  String? _jenisKelamin;
  String? _kelas;
  String? _jurusan;
  bool _loading = false;
  final Map<String, String> _fieldErrors = {};

  bool get _isEdit => widget.siswa != null;

  @override
  void initState() {
    super.initState();
    final siswa = widget.siswa;
    if (siswa != null) {
      _nipd.text = siswa.nipd;
      _nama.text = siswa.namaLengkap;
      _alamat.text = siswa.alamat ?? '';
      _jenisKelamin = siswa.jenisKelamin;
      _kelas = siswa.kelas;
      _jurusan = siswa.jurusan;
    }
  }

  @override
  void dispose() {
    _nipd.dispose();
    _nama.dispose();
    _alamat.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    if (value.trim().length > 50) return '$label maksimal 50 karakter.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _fieldErrors.clear();
    });
    final allValues = <String, dynamic>{
      'nipd': _nipd.text.trim(),
      'nama_lengkap': _nama.text.trim(),
      'jenis_kelamin': _jenisKelamin,
      'kelas': _kelas,
      'jurusan': _jurusan,
      'alamat': _alamat.text.trim().isEmpty ? null : _alamat.text.trim(),
    };
    final payload = <String, dynamic>{};
    if (!_isEdit) {
      payload.addAll(allValues);
    } else {
      final old = widget.siswa!;
      if (allValues['nipd'] != old.nipd) payload['nipd'] = allValues['nipd'];
      if (allValues['nama_lengkap'] != old.namaLengkap) payload['nama_lengkap'] = allValues['nama_lengkap'];
      if (allValues['jenis_kelamin'] != old.jenisKelamin) payload['jenis_kelamin'] = allValues['jenis_kelamin'];
      if (allValues['kelas'] != old.kelas) payload['kelas'] = allValues['kelas'];
      if (allValues['jurusan'] != old.jurusan) payload['jurusan'] = allValues['jurusan'];
      if (allValues['alamat'] != old.alamat) payload['alamat'] = allValues['alamat'];
      if (payload.isEmpty) {
        Navigator.pop(context, true);
        return;
      }
    }

    try {
      if (_isEdit) {
        await _service.update(widget.siswa!.id, payload);
      } else {
        await _service.create(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _fieldErrors.addAll(error.fieldErrors));
      final message = error.statusCode == 409
          ? 'NIPD sudah terdaftar. Gunakan NIPD lain.'
          : error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat menyimpan data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, String key) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: _fieldErrors[key],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Siswa' : 'Input Siswa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _nipd,
                  maxLength: 50,
                  decoration: _decoration('NIPD', 'nipd'),
                  validator: (v) => _requiredText(v, 'NIPD'),
                  onChanged: (_) => setState(() => _fieldErrors.remove('nipd')),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nama,
                  maxLength: 50,
                  decoration: _decoration('Nama lengkap', 'nama_lengkap'),
                  validator: (v) => _requiredText(v, 'Nama lengkap'),
                  onChanged: (_) => setState(() => _fieldErrors.remove('nama_lengkap')),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _jenisKelamin,
                  decoration: _decoration('Jenis kelamin', 'jenis_kelamin'),
                  items: SiswaOptions.jenisKelamin.map((v) => DropdownMenuItem(value: v, child: Text(v == 'L' ? 'Laki-laki (L)' : 'Perempuan (P)'))).toList(),
                  validator: (v) => v == null ? 'Jenis kelamin wajib dipilih.' : null,
                  onChanged: (v) => setState(() { _jenisKelamin = v; _fieldErrors.remove('jenis_kelamin'); }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _kelas,
                  decoration: _decoration('Kelas', 'kelas'),
                  items: SiswaOptions.kelas.map((v) => DropdownMenuItem(value: v, child: Text('Kelas $v'))).toList(),
                  validator: (v) => v == null ? 'Kelas wajib dipilih.' : null,
                  onChanged: (v) => setState(() { _kelas = v; _fieldErrors.remove('kelas'); }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _jurusan,
                  decoration: _decoration('Jurusan', 'jurusan'),
                  items: SiswaOptions.jurusan.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  validator: (v) => v == null ? 'Jurusan wajib dipilih.' : null,
                  onChanged: (v) => setState(() { _jurusan = v; _fieldErrors.remove('jurusan'); }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alamat,
                  maxLength: 50,
                  maxLines: 3,
                  decoration: _decoration('Alamat (opsional)', 'alamat'),
                  validator: (v) => v != null && v.length > 50 ? 'Alamat maksimal 50 karakter.' : null,
                  onChanged: (_) => setState(() => _fieldErrors.remove('alamat')),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _save,
                  icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                  label: Text(_loading ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

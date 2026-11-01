// Nilai yang diterima API untuk field dropdown siswa.
class SiswaOptions {
  static const List<String> jenisKelamin = ['L', 'P'];
  static const List<String> kelas = ['10', '11', '12'];
  static const List<String> jurusan = ['RPL', 'DKV', 'BIDI', 'TKJ', 'AK'];
}

// Model data siswa sesuai kontrak REST API.
class Siswa {
  final int id;
  final String nipd;
  final String namaLengkap;
  final String jenisKelamin;
  final String? alamat;
  final String kelas;
  final String jurusan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Siswa({
    required this.id,
    required this.nipd,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.alamat,
    required this.kelas,
    required this.jurusan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) => Siswa(
        id: (json['id'] as num).toInt(),
        nipd: json['nipd']?.toString() ?? '',
        namaLengkap: json['nama_lengkap']?.toString() ?? '',
        jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
        alamat: json['alamat']?.toString(),
        kelas: json['kelas']?.toString() ?? '',
        jurusan: json['jurusan']?.toString() ?? '',
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'nipd': nipd,
        'nama_lengkap': namaLengkap,
        'jenis_kelamin': jenisKelamin,
        'alamat': alamat,
        'kelas': kelas,
        'jurusan': jurusan,
      };

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value.toString()).toLocal();
}

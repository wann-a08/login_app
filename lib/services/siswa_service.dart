import '../models/paginated_result.dart';
import '../models/siswa.dart';
import 'api_client.dart';

// Class untuk semua operasi CRUD siswa melalui REST API.
class SiswaService {
  final ApiClient _api = ApiClient.instance;

  Future<PaginatedResult<Siswa>> getSiswa({
    int page = 1,
    int limit = 10,
    String search = '',
    String? kelas,
    String? jurusan,
    String? jenisKelamin,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (kelas != null && kelas.isNotEmpty) 'kelas': kelas,
      if (jurusan != null && jurusan.isNotEmpty) 'jurusan': jurusan,
      if (jenisKelamin != null && jenisKelamin.isNotEmpty) 'jenis_kelamin': jenisKelamin,
    };
    final result = await _api.get('/siswa', query: query);
    if (result is! Map<String, dynamic> || result['data'] is! List || result['meta'] is! Map) {
      throw const ApiException(message: 'Format daftar siswa dari server tidak valid.');
    }
    final rows = (result['data'] as List)
        .map((item) => Siswa.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final meta = PaginationMeta.fromJson(Map<String, dynamic>.from(result['meta'] as Map));
    return PaginatedResult<Siswa>(data: rows, meta: meta);
  }

  Future<Siswa> getById(int id) async => _siswaFromResult(await _api.get('/siswa/$id'));

  Future<Siswa> create(Map<String, dynamic> payload) async =>
      _siswaFromResult(await _api.post('/siswa', body: payload));

  Future<Siswa> update(int id, Map<String, dynamic> payload) async =>
      _siswaFromResult(await _api.put('/siswa/$id', body: payload));

  Future<void> delete(int id) async {
    await _api.delete('/siswa/$id');
  }

  Siswa _siswaFromResult(dynamic result) {
    if (result is! Map<String, dynamic> || result['data'] is! Map) {
      throw const ApiException(message: 'Format data siswa dari server tidak valid.');
    }
    return Siswa.fromJson(Map<String, dynamic>.from(result['data'] as Map));
  }
}

// Metadata pagination sesuai respons endpoint GET /siswa.
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      PaginationMeta(
        page: (json['page'] as num).toInt(),
        limit: (json['limit'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
      );
}

class PaginatedResult<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResult({required this.data, required this.meta});
}

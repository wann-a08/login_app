// Model untuk data admin yang dikembalikan API autentikasi.
class AuthUser {
  final int id;
  final String username;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthUser({
    required this.id,
    required this.username,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] as num).toInt(),
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString(),
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value.toString()).toLocal();
}

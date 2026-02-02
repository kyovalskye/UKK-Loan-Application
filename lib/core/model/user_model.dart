class UserModel {
  final String userId;
  final String nama;
  final String email;
  final String role;
  final String? nomorHp;
  final String? alamat;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.nama,
    required this.email,
    required this.role,
    this.nomorHp,
    this.alamat,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'],
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'peminjam',
      nomorHp: map['nomor_hp'],
      alamat: map['alamat'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

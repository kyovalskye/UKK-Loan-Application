class PeminjamanModel {
  final int id;
  final String kode;
  final String namaUser;
  final String emailUser;
  final String userId;
  final String namaAlat;
  final String kategori;
  final int idAlat;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalKembali;
  final String? tanggalKembaliActual;
  final String status;
  final String keperluan;
  final String? catatanAdmin;

  PeminjamanModel({
    required this.id,
    required this.kode,
    required this.namaUser,
    required this.emailUser,
    required this.userId,
    required this.namaAlat,
    required this.kategori,
    required this.idAlat,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    this.tanggalKembaliActual,
    required this.status,
    required this.keperluan,
    this.catatanAdmin,
  });

  factory PeminjamanModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] as Map<String, dynamic>?;
    final alat = map['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;

    return PeminjamanModel(
      id: map['id_peminjaman'],
      kode: map['kode_peminjaman'] ?? '-', // typo peminjman
      namaUser: user?['nama'] ?? 'Unknown',
      emailUser: user?['email'] ?? '-',
      userId: user?['user_id'] ?? '',
      namaAlat: alat?['nama_alat'] ?? '-',
      kategori: kategori?['nama'] ?? '-',
      idAlat: alat?['id_alat'] ?? 0,
      jumlah: map['jumlah_pinjam'] ?? 1,
      tanggalPinjam: map['tanggal_pinjam'] ?? '-',
      tanggalKembali: map['tanggal_kembali_rencana'] ?? '-',
      tanggalKembaliActual: map['tanggal_kembali_actual'],
      status: map['status_peminjaman'] ?? 'diajukan',
      keperluan: map['keperluan'] ?? '-',
      catatanAdmin: map['catatan_admin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_user': namaUser,
      'email_user': emailUser,
      'user_id': userId,
      'nama_alat': namaAlat,
      'kategori': kategori,
      'id_alat': idAlat,
      'jumlah': jumlah,
      'tanggal_pinjam': tanggalPinjam,
      'tanggal_kembali': tanggalKembali,
      'tanggal_kembali_actual': tanggalKembaliActual,
      'status': status,
      'keperluan': keperluan,
      'catatan_admin': catatanAdmin,
    };
  }
}

class UserModel {
  final String userId;
  final String nama;
  final String email;

  UserModel({
    required this.userId,
    required this.nama,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'],
      nama: map['nama'],
      email: map['email'],
    );
  }
}

class AlatModel {
  final int idAlat;
  final String namaAlat;
  final int stok;

  AlatModel({
    required this.idAlat,
    required this.namaAlat,
    required this.stok,
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      idAlat: map['id_alat'],
      namaAlat: map['nama_alat'],
      stok: map['stok'] ?? 0,
    );
  }
}
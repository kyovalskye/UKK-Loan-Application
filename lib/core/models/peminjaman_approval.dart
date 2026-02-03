class PeminjamanApproval {
  final int idPeminjaman;
  final String kodePeminjaman;
  final String idUser;
  final int idAlat;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembaliRencana;
  final int jumlahPinjam;
  final String? keperluan;
  final String statusPeminjaman;
  final String? catatanAdmin;
  final DateTime createdAt;
  
  // Relasi
  final String namaUser;
  final String emailUser;
  final String namaAlat;
  final String kategoriAlat;
  final String? fotoAlat;
  final int jumlahTersedia;

  PeminjamanApproval({
    required this.idPeminjaman,
    required this.kodePeminjaman,
    required this.idUser,
    required this.idAlat,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.jumlahPinjam,
    this.keperluan,
    required this.statusPeminjaman,
    this.catatanAdmin,
    required this.createdAt,
    required this.namaUser,
    required this.emailUser,
    required this.namaAlat,
    required this.kategoriAlat,
    this.fotoAlat,
    required this.jumlahTersedia,
  });

  factory PeminjamanApproval.fromMap(Map<String, dynamic> map) {
    return PeminjamanApproval(
      idPeminjaman: map['id_peminjaman'] as int,
      kodePeminjaman: map['kode_peminjaman'] as String,
      idUser: map['id_user'] as String,
      idAlat: map['id_alat'] as int,
      tanggalPinjam: DateTime.parse(map['tanggal_pinjam'] as String),
      tanggalKembaliRencana: DateTime.parse(map['tanggal_kembali_rencana'] as String),
      jumlahPinjam: map['jumlah_pinjam'] as int,
      keperluan: map['keperluan'] as String?,
      statusPeminjaman: map['status_peminjaman'] as String,
      catatanAdmin: map['catatan_admin'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      namaUser: map['users']?['nama'] as String? ?? 'Unknown',
      emailUser: map['users']?['email'] as String? ?? 'Unknown',
      namaAlat: map['alat']?['nama_alat'] as String? ?? 'Unknown',
      kategoriAlat: map['alat']?['kategori']?['nama'] as String? ?? '-',
      fotoAlat: map['alat']?['foto_alat'] as String?,
      jumlahTersedia: map['alat']?['jumlah_tersedia'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_peminjaman': idPeminjaman,
      'kode_peminjaman': kodePeminjaman,
      'id_user': idUser,
      'id_alat': idAlat,
      'tanggal_pinjam': tanggalPinjam.toIso8601String(),
      'tanggal_kembali_rencana': tanggalKembaliRencana.toIso8601String(),
      'jumlah_pinjam': jumlahPinjam,
      'keperluan': keperluan,
      'status_peminjaman': statusPeminjaman,
      'catatan_admin': catatanAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get canApprove => statusPeminjaman == 'diajukan';
  bool get isApproved => statusPeminjaman == 'dipinjam' || statusPeminjaman == 'disetujui';
  bool get isRejected => statusPeminjaman == 'ditolak';
  bool get hasEnoughStock => jumlahTersedia >= jumlahPinjam;
  
  int get durasiPinjam => tanggalKembaliRencana.difference(tanggalPinjam).inDays;
}
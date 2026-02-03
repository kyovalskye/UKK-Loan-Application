class Pengembalian {
  final int idPengembalian;
  final int idPeminjaman;
  final String kodePeminjaman;
  final String namaUser;
  final String namaAlat;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;
  final String tanggalKembaliActual;
  final String kondisiKembali;
  final String catatan;
  final int keterlambatan;
  final int dendaKeterlambatan;
  final int dendaKerusakan;
  final int totalDenda;
  final String statusPembayaran;
  final String namaPetugas;
  final DateTime createdAt;

  Pengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.kodePeminjaman,
    required this.namaUser,
    required this.namaAlat,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.tanggalKembaliActual,
    required this.kondisiKembali,
    required this.catatan,
    required this.keterlambatan,
    required this.dendaKeterlambatan,
    required this.dendaKerusakan,
    required this.totalDenda,
    required this.statusPembayaran,
    required this.namaPetugas,
    required this.createdAt,
  });

  factory Pengembalian.fromMap(Map<String, dynamic> map) {
    // Extract nested data dengan null safety
    final peminjaman = map['peminjaman'] as Map<String, dynamic>?;
    final users = peminjaman?['users'] as Map<String, dynamic>?;
    final alat = peminjaman?['alat'] as Map<String, dynamic>?;
    final petugas = map['petugas'] as Map<String, dynamic>?;

    // Parse tanggal pengembalian
    final tanggalPengembalianStr = map['tanggal_pengembalian'] as String?;
    DateTime parsedDate = DateTime.now();
    if (tanggalPengembalianStr != null) {
      try {
        parsedDate = DateTime.parse(tanggalPengembalianStr);
      } catch (e) {
        // Jika parsing gagal, gunakan current date
        parsedDate = DateTime.now();
      }
    }

    return Pengembalian(
      idPengembalian: map['id_pengembalian'] as int? ?? 0,
      idPeminjaman: peminjaman?['id_peminjaman'] as int? ?? 0,
      kodePeminjaman: peminjaman?['kode_peminjaman'] as String? ?? 'N/A',
      namaUser: users?['nama'] as String? ?? 'Unknown',
      namaAlat: alat?['nama_alat'] as String? ?? 'Unknown',
      tanggalPinjam: peminjaman?['tanggal_pinjam'] as String? ?? 'N/A',
      tanggalKembaliRencana:
          peminjaman?['tanggal_kembali_rencana'] as String? ?? 'N/A',
      tanggalKembaliActual: _formatDateTime(parsedDate),
      kondisiKembali: map['kondisi_saat_kembali'] as String? ?? 'baik',
      catatan: map['catatan_pengembalian'] as String? ?? '',
      keterlambatan: map['keterlambatan_hari'] as int? ?? 0,
      dendaKeterlambatan:
          (map['denda_keterlambatan'] as num?)?.toInt() ?? 0,
      dendaKerusakan: (map['denda_kerusakan'] as num?)?.toInt() ?? 0,
      totalDenda: (map['total_denda'] as num?)?.toInt() ?? 0,
      statusPembayaran: map['status_pembayaran'] as String? ?? 'belum_bayar',
      namaPetugas: petugas?['nama'] as String? ?? 'Unknown',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'tanggal_pengembalian': createdAt.toIso8601String(),
      'kondisi_saat_kembali': kondisiKembali,
      'catatan_pengembalian': catatan,
      'keterlambatan_hari': keterlambatan,
      'denda_keterlambatan': dendaKeterlambatan,
      'denda_kerusakan': dendaKerusakan,
      'total_denda': totalDenda,
      'status_pembayaran': statusPembayaran,
    };
  }

  // Helper methods
  bool get isLunas => statusPembayaran == 'lunas';
  bool get hasLate => keterlambatan > 0;
  bool get hasDamage => kondisiKembali != 'baik';

  String get kondisiText {
    const kondisiMap = {
      'baik': 'Baik',
      'rusak_ringan': 'Rusak Ringan',
      'rusak_berat': 'Rusak Berat',
      'hilang': 'Hilang',
    };
    return kondisiMap[kondisiKembali] ?? kondisiKembali;
  }

  String get statusText => isLunas ? 'Lunas' : 'Belum Bayar';

  
  // Format DateTime ke string yang lebih readable
  static String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }

  Pengembalian copyWith({
    int? idPengembalian,
    int? idPeminjaman,
    String? kodePeminjaman,
    String? namaUser,
    String? namaAlat,
    String? tanggalPinjam,
    String? tanggalKembaliRencana,
    String? tanggalKembaliActual,
    String? kondisiKembali,
    String? catatan,
    int? keterlambatan,
    int? dendaKeterlambatan,
    int? dendaKerusakan,
    int? totalDenda,
    String? statusPembayaran,
    String? namaPetugas,
    DateTime? createdAt,
  }) {
    return Pengembalian(
      idPengembalian: idPengembalian ?? this.idPengembalian,
      idPeminjaman: idPeminjaman ?? this.idPeminjaman,
      kodePeminjaman: kodePeminjaman ?? this.kodePeminjaman,
      namaUser: namaUser ?? this.namaUser,
      namaAlat: namaAlat ?? this.namaAlat,
      tanggalPinjam: tanggalPinjam ?? this.tanggalPinjam,
      tanggalKembaliRencana:
          tanggalKembaliRencana ?? this.tanggalKembaliRencana,
      tanggalKembaliActual: tanggalKembaliActual ?? this.tanggalKembaliActual,
      kondisiKembali: kondisiKembali ?? this.kondisiKembali,
      catatan: catatan ?? this.catatan,
      keterlambatan: keterlambatan ?? this.keterlambatan,
      dendaKeterlambatan: dendaKeterlambatan ?? this.dendaKeterlambatan,
      dendaKerusakan: dendaKerusakan ?? this.dendaKerusakan,
      totalDenda: totalDenda ?? this.totalDenda,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Pengembalian(idPengembalian: $idPengembalian, kodePeminjaman: $kodePeminjaman, namaUser: $namaUser, totalDenda: $totalDenda)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pengembalian && other.idPengembalian == idPengembalian;
  }

  @override
  int get hashCode => idPengembalian.hashCode;
}
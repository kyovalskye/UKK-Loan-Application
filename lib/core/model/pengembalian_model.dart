class PengembalianModel {
  final int idPengembalian;
  final int idPeminjaman;
  final String kodePeminjaman;
  final String namaUser;
  final String namaAlat;
  final String kategori;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;
  final DateTime tanggalPengembalian;
  final String kondisiKembali;
  final String? catatanPengembalian;
  final int keterlambatan;
  final double dendaKeterlambatan;
  final double dendaKerusakan;
  final double totalDenda;
  final String statusPembayaran;
  final String namaPetugas;

  PengembalianModel({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.kodePeminjaman,
    required this.namaUser,
    required this.namaAlat,
    required this.kategori,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.tanggalPengembalian,
    required this.kondisiKembali,
    this.catatanPengembalian,
    required this.keterlambatan,
    required this.dendaKeterlambatan,
    required this.dendaKerusakan,
    required this.totalDenda,
    required this.statusPembayaran,
    required this.namaPetugas,
  });

  factory PengembalianModel.fromMap(Map<String, dynamic> map) {
    final peminjaman = map['peminjaman'] as Map<String, dynamic>?;
    final user = peminjaman?['users'] as Map<String, dynamic>?;
    final alat = peminjaman?['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;
    final petugas = map['petugas'] as Map<String, dynamic>?;

    return PengembalianModel(
      idPengembalian: map['id_pengembalian'] ?? 0,
      idPeminjaman: map['id_peminjaman'] ?? 0,
      kodePeminjaman: peminjaman?['kode_peminjaman'] ?? '-',
      namaUser: user?['nama'] ?? 'Unknown',
      namaAlat: alat?['nama_alat'] ?? '-',
      kategori: kategori?['nama'] ?? '-',
      jumlah: peminjaman?['jumlah_pinjam'] ?? 1,
      tanggalPinjam: peminjaman?['tanggal_pinjam'] ?? '-',
      tanggalKembaliRencana: peminjaman?['tanggal_kembali_rencana'] ?? '-',
      tanggalPengembalian: DateTime.parse(map['tanggal_pengembalian']),
      kondisiKembali: map['kondisi_saat_kembali'] ?? 'baik',
      catatanPengembalian: map['catatan_pengembalian'],
      keterlambatan: map['keterlambatan_hari'] ?? 0,
      dendaKeterlambatan: (map['denda_keterlambatan'] ?? 0).toDouble(),
      dendaKerusakan: (map['denda_kerusakan'] ?? 0).toDouble(),
      totalDenda: (map['total_denda'] ?? 0).toDouble(),
      statusPembayaran: map['status_pembayaran'] ?? 'belum_bayar',
      namaPetugas: petugas?['nama'] ?? 'Unknown',
    );
  }
}

class PeminjamanDipinjamModel {
  final int idPeminjaman;
  final String kodePeminjaman;
  final String namaUser;
  final String userId;
  final String namaAlat;
  final int idAlat;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;

  PeminjamanDipinjamModel({
    required this.idPeminjaman,
    required this.kodePeminjaman,
    required this.namaUser,
    required this.userId,
    required this.namaAlat,
    required this.idAlat,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
  });

  factory PeminjamanDipinjamModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] as Map<String, dynamic>?;
    final alat = map['alat'] as Map<String, dynamic>?;

    return PeminjamanDipinjamModel(
      idPeminjaman: map['id_peminjaman'] ?? 0,
      kodePeminjaman: map['kode_peminjaman'] ?? '-',
      namaUser: user?['nama'] ?? 'Unknown',
      userId: user?['user_id'] ?? '',
      namaAlat: alat?['nama_alat'] ?? '-',
      idAlat: alat?['id_alat'] ?? 0,
      jumlah: map['jumlah_pinjam'] ?? 1,
      tanggalPinjam: map['tanggal_pinjam'] ?? '-',
      tanggalKembaliRencana: map['tanggal_kembali_rencana'] ?? '-',
    );
  }
}

class SettingDendaModel {
  final double dendaPerHari;
  final double dendaRusakRingan;
  final double dendaRusakBerat;
  final int dendaHilangPersen;

  SettingDendaModel({
    required this.dendaPerHari,
    required this.dendaRusakRingan,
    required this.dendaRusakBerat,
    required this.dendaHilangPersen,
  });

  factory SettingDendaModel.fromMap(Map<String, dynamic> map) {
    return SettingDendaModel(
      dendaPerHari: (map['denda_per_hari'] ?? 5000).toDouble(),
      dendaRusakRingan: (map['denda_rusak_ringan'] ?? 50000).toDouble(),
      dendaRusakBerat: (map['denda_rusak_berat'] ?? 200000).toDouble(),
      dendaHilangPersen: map['denda_hilang_persen'] ?? 100,
    );
  }
}
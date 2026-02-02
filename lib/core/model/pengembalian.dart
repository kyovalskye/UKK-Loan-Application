class Pengembalian {
  final int idPengembalian;
  final int idPeminjaman;
  final String kodePeminjaman;
  final String namaUser;
  final String emailUser;
  final String namaAlat;
  final String kategori;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;
  final String tanggalKembaliActual;
  final String kondisiKembali;
  final int keterlambatan;
  final int dendaKeterlambatan;
  final int dendaKerusakan;
  final int totalDenda;
  final String statusPembayaran;
  final String catatan;
  final String namaPetugas;
  final String createdAt;

  const Pengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.kodePeminjaman,
    required this.namaUser,
    required this.emailUser,
    required this.namaAlat,
    required this.kategori,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.tanggalKembaliActual,
    required this.kondisiKembali,
    required this.keterlambatan,
    required this.dendaKeterlambatan,
    required this.dendaKerusakan,
    required this.totalDenda,
    required this.statusPembayaran,
    required this.catatan,
    required this.namaPetugas,
    required this.createdAt,
  });

  factory Pengembalian.fromMap(Map<String, dynamic> map) {
    return Pengembalian(
      idPengembalian: map['id_pengembalian'] ?? 0,
      idPeminjaman: map['id_peminjaman'] ?? 0,
      kodePeminjaman: map['kode_peminjaman'] ?? 'N/A',
      namaUser: map['nama_user'] ?? 'Unknown',
      emailUser: map['email_user'] ?? '',
      namaAlat: map['nama_alat'] ?? 'Unknown',
      kategori: map['kategori'] ?? 'Uncategorized',
      jumlah: map['jumlah'] ?? 0,
      tanggalPinjam: map['tanggal_pinjam'] ?? '',
      tanggalKembaliRencana: map['tanggal_kembali_rencana'] ?? '',
      tanggalKembaliActual: map['tanggal_kembali_actual'] ?? '',
      kondisiKembali: map['kondisi_kembali'] ?? 'baik',
      keterlambatan: map['keterlambatan'] ?? 0,
      dendaKeterlambatan: map['denda_keterlambatan'] ?? 0,
      dendaKerusakan: map['denda_kerusakan'] ?? 0,
      totalDenda: map['total_denda'] ?? 0,
      statusPembayaran: map['status_pembayaran'] ?? 'belum_bayar',
      catatan: map['catatan'] ?? '',
      namaPetugas: map['nama_petugas'] ?? 'Unknown',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'kode_peminjaman': kodePeminjaman,
      'nama_user': namaUser,
      'email_user': emailUser,
      'nama_alat': namaAlat,
      'kategori': kategori,
      'jumlah': jumlah,
      'tanggal_pinjam': tanggalPinjam,
      'tanggal_kembali_rencana': tanggalKembaliRencana,
      'tanggal_kembali_actual': tanggalKembaliActual,
      'kondisi_kembali': kondisiKembali,
      'keterlambatan': keterlambatan,
      'denda_keterlambatan': dendaKeterlambatan,
      'denda_kerusakan': dendaKerusakan,
      'total_denda': totalDenda,
      'status_pembayaran': statusPembayaran,
      'catatan': catatan,
      'nama_petugas': namaPetugas,
      'created_at': createdAt,
    };
  }

  bool get hasLate => keterlambatan > 0;
  bool get hasDamage => dendaKerusakan > 0;
  bool get isLunas => statusPembayaran == 'lunas';

  String get kondisiText {
    const kondisiMap = {
      'baik': 'Baik',
      'rusak_ringan': 'Rusak Ringan',
      'rusak_berat': 'Rusak Berat',
      'hilang': 'Hilang',
    };
    return kondisiMap[kondisiKembali] ?? kondisiKembali;
  }
}
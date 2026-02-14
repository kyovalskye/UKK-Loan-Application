import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_pengembalian_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffPengembalianCubit extends Cubit<StaffPengembalianState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  StaffPengembalianCubit() : super(StaffPengembalianInitial());

  /// Load peminjaman yang statusnya 'dipinjam' (belum dikembalikan)
  Future<void> loadActiveBorrowings() async {
    try {
      emit(StaffPengembalianLoading());

      final response = await _supabase
          .from('peminjaman')
          .select('''
            *,
            users!inner(nama, email),
            alat!inner(nama_alat, kategori:id_kategori(nama))
          ''')
          .eq('status_peminjaman', 'dipinjam')
          .order('tanggal_kembali_rencana', ascending: true);

      final borrowingList = response as List<dynamic>;

      if (borrowingList.isEmpty) {
        emit(StaffPengembalianLoaded(
          allBorrowings: [],
          filteredBorrowings: [],
        ));
        return;
      }

      emit(StaffPengembalianLoaded(
        allBorrowings: borrowingList,
        filteredBorrowings: borrowingList,
      ));
    } catch (e) {
      print('❌ Error loadActiveBorrowings: $e');
      emit(StaffPengembalianError('Gagal memuat data: ${e.toString()}'));
    }
  }

  /// Search borrowings
  void searchBorrowings(String query) {
    final currentState = state;
    if (currentState is! StaffPengembalianLoaded) return;

    final filtered = currentState.allBorrowings.where((item) {
      final kodePeminjaman = item['kode_peminjaman']?.toString().toLowerCase() ?? '';
      final namaUser = item['users']?['nama']?.toString().toLowerCase() ?? '';
      final namaAlat = item['alat']?['nama_alat']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return kodePeminjaman.contains(searchLower) ||
          namaUser.contains(searchLower) ||
          namaAlat.contains(searchLower);
    }).toList();

    emit(currentState.copyWith(
      filteredBorrowings: filtered,
      searchQuery: query,
    ));
  }

  /// Get setting denda
  Future<Map<String, dynamic>> getSettingDenda() async {
    try {
      final response = await _supabase
          .from('setting_denda')
          .select()
          .limit(1)
          .single();

      return {
        'denda_per_hari': (response['denda_per_hari'] as num).toDouble(),
        'denda_rusak_ringan': (response['denda_rusak_ringan'] as num).toDouble(),
        'denda_rusak_berat': (response['denda_rusak_berat'] as num).toDouble(),
        'denda_hilang_persen': response['denda_hilang_persen'] as int,
        'maksimal_hari_pinjam': response['maksimal_hari_pinjam'] as int,
      };
    } catch (e) {
      return {
        'denda_per_hari': 10000.0,
        'denda_rusak_ringan': 100000.0,
        'denda_rusak_berat': 500000.0,
        'denda_hilang_persen': 100,
        'maksimal_hari_pinjam': 7,
      };
    }
  }

  /// Calculate denda - FIXED: Responsif terhadap perubahan waktu sistem
  Map<String, dynamic> calculateDenda({
    required DateTime tanggalKembaliRencana,
    required String kondisi,
    required Map<String, dynamic> settingDenda,
  }) {
    // Normalisasi tanggal agar hanya membandingkan hari (tanpa jam/menit/detik)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(
      tanggalKembaliRencana.year,
      tanggalKembaliRencana.month,
      tanggalKembaliRencana.day,
    );

    // Hitung keterlambatan: jika hari ini LEBIH dari tanggal jatuh tempo
    // Contoh: jatuh tempo 13 Feb, hari ini 14 Feb = terlambat 1 hari
    final keterlambatan = todayDate.isAfter(dueDate)
        ? todayDate.difference(dueDate).inDays
        : 0;

    final dendaPerHari = settingDenda['denda_per_hari'] as double;
    final dendaKeterlambatan = keterlambatan * dendaPerHari;

    double dendaKerusakan = 0;
    switch (kondisi) {
      case 'rusak_ringan':
        dendaKerusakan = settingDenda['denda_rusak_ringan'] as double;
        break;
      case 'rusak_berat':
        dendaKerusakan = settingDenda['denda_rusak_berat'] as double;
        break;
      case 'hilang':
        // FIXED: Ambil dari setting_denda, bukan hardcoded
        final dendaHilangPersen = (settingDenda['denda_hilang_persen'] ?? 100) as int;
        // Untuk sementara gunakan denda_rusak_berat * (persen/100) jika tidak ada harga alat
        // Atau bisa disesuaikan dengan harga alat jika ada field harga_alat
        dendaKerusakan = (settingDenda['denda_rusak_berat'] as double) * (dendaHilangPersen / 100);
        break;
      default:
        dendaKerusakan = 0;
    }

    return {
      'keterlambatan': keterlambatan,
      'denda_keterlambatan': dendaKeterlambatan,
      'denda_kerusakan': dendaKerusakan,
      'total_denda': dendaKeterlambatan + dendaKerusakan,
    };
  }

  /// Process return (create pengembalian)
  Future<void> processPengembalian({
    required int idPeminjaman,
    required int idAlat,
    required int jumlahPinjam,
    required String kondisiSaatKembali,
    String? catatanPengembalian,
    required int keterlambatanHari,
    required double dendaKeterlambatan,
    required double dendaKerusakan,
    required String idPetugas,
  }) async {
    try {
      emit(StaffPengembalianOperationLoading('Memproses pengembalian...'));

      final totalDenda = dendaKeterlambatan + dendaKerusakan;

      // 1. Create record pengembalian
      await _supabase.from('pengembalian').insert({
        'id_peminjaman': idPeminjaman,
        'tanggal_pengembalian': DateTime.now().toIso8601String(),
        'kondisi_saat_kembali': kondisiSaatKembali,
        'catatan_pengembalian': catatanPengembalian,
        'keterlambatan_hari': keterlambatanHari,
        'denda_keterlambatan': dendaKeterlambatan,
        'denda_kerusakan': dendaKerusakan,
        'total_denda': totalDenda,
        'status_pembayaran': totalDenda > 0 ? 'belum_bayar' : 'lunas',
        'id_petugas': idPetugas,
      });

      // 2. Update status peminjaman menjadi 'dikembalikan'
      await _supabase.from('peminjaman').update({
        'status_peminjaman': 'dikembalikan',
        'tanggal_kembali_actual': DateTime.now().toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_peminjaman', idPeminjaman);

      // 3. Kembalikan stok alat
      final alatResponse = await _supabase
          .from('alat')
          .select('jumlah_tersedia')
          .eq('id_alat', idAlat)
          .single();

      final currentStock = alatResponse['jumlah_tersedia'] as int;
      await _supabase.from('alat').update({
        'jumlah_tersedia': currentStock + jumlahPinjam,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);

      emit(StaffPengembalianOperationSuccess('Pengembalian berhasil diproses'));
      await loadActiveBorrowings();
    } catch (e) {
      print('❌ Error processPengembalian: $e');
      emit(StaffPengembalianError('Gagal memproses: ${e.toString()}'));
      await loadActiveBorrowings();
    }
  }
}
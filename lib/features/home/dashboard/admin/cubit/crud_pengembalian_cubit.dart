import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianCubit extends Cubit<PengembalianState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  PengembalianCubit() : super(PengembalianInitial());

  /// Load semua data pengembalian dengan relasi
  Future<void> loadPengembalian() async {
    try {
      emit(PengembalianLoading());

      final response = await _supabase.from('pengembalian').select('''
        *,
        peminjaman:id_peminjaman(
          kode_peminjaman,
          tanggal_pinjam,
          tanggal_kembali_rencana,
          jumlah_pinjam,
          users:id_user(nama),
          alat:id_alat(nama_alat)
        ),
        petugas:id_petugas(nama)
      ''').order('created_at', ascending: false);

      final pengembalianList = response as List<dynamic>;

      emit(PengembalianLoaded(
        allList: pengembalianList,
        filteredList: pengembalianList,
      ));
    } catch (e) {
      emit(PengembalianError('Gagal memuat data: ${e.toString()}'));
    }
  }

  /// Search pengembalian
  void searchPengembalian(String query) {
    final currentState = state;
    if (currentState is! PengembalianLoaded) return;

    final filtered = currentState.allList.where((item) {
      final kodePeminjaman =
          item['peminjaman']?['kode_peminjaman']?.toString().toLowerCase() ??
              '';
      final namaUser = item['peminjaman']?['users']?['nama']
              ?.toString()
              .toLowerCase() ??
          '';
      final namaAlat = item['peminjaman']?['alat']?['nama_alat']
              ?.toString()
              .toLowerCase() ??
          '';
      final searchLower = query.toLowerCase();

      return kodePeminjaman.contains(searchLower) ||
          namaUser.contains(searchLower) ||
          namaAlat.contains(searchLower);
    }).toList();

    emit(currentState.copyWith(
      filteredList: filtered,
      searchQuery: query,
    ));
  }

  /// Filter by status pembayaran
  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is! PengembalianLoaded) return;

    List<dynamic> filtered;
    if (status == 'Semua') {
      filtered = currentState.allList;
    } else {
      final statusDb = status == 'Lunas' ? 'lunas' : 'belum_bayar';
      filtered = currentState.allList
          .where((item) => item['status_pembayaran'] == statusDb)
          .toList();
    }

    emit(currentState.copyWith(
      filteredList: filtered,
      statusFilter: status,
    ));
  }

  /// Get peminjaman yang statusnya 'dipinjam' (untuk form pengembalian)
  Future<List<Map<String, dynamic>>> getActivePeminjaman() async {
    try {
      final response = await _supabase.from('peminjaman').select('''
        *,
        users:id_user(nama, email),
        alat:id_alat(nama_alat, kategori:id_kategori(nama))
      ''').eq('status_peminjaman', 'dipinjam').order('created_at',
          ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Gagal memuat peminjaman aktif: ${e.toString()}');
    }
  }

  /// Calculate denda berdasarkan keterlambatan dan kondisi
  Future<Map<String, dynamic>> calculateDenda({
    required DateTime tanggalKembaliRencana,
    required String kondisi,
  }) async {
    try {
      // Get setting denda dari database
      final settingResponse =
          await _supabase.from('setting_denda').select().limit(1).single();

      final dendaPerHari =
          (settingResponse['denda_per_hari'] as num).toDouble();
      final dendaRusakRingan =
          (settingResponse['denda_rusak_ringan'] as num).toDouble();
      final dendaRusakBerat =
          (settingResponse['denda_rusak_berat'] as num).toDouble();
      final dendaHilangPersen =
          settingResponse['denda_hilang_persen'] as int;

      // Calculate keterlambatan
      final today = DateTime.now();
      final keterlambatan = today.isAfter(tanggalKembaliRencana)
          ? today.difference(tanggalKembaliRencana).inDays
          : 0;

      // Calculate denda keterlambatan
      final dendaKeterlambatan = keterlambatan * dendaPerHari;

      // Calculate denda kerusakan
      double dendaKerusakan = 0;
      switch (kondisi) {
        case 'rusak_ringan':
          dendaKerusakan = dendaRusakRingan;
          break;
        case 'rusak_berat':
          dendaKerusakan = dendaRusakBerat;
          break;
        case 'hilang':
          // Untuk hilang, bisa dihitung berdasarkan harga alat
          // Untuk saat ini gunakan nilai default yang besar
          dendaKerusakan = 500000; // Atau bisa ambil dari harga alat
          break;
        default:
          dendaKerusakan = 0;
      }

      final totalDenda = dendaKeterlambatan + dendaKerusakan;

      return {
        'keterlambatan': keterlambatan,
        'denda_keterlambatan': dendaKeterlambatan,
        'denda_kerusakan': dendaKerusakan,
        'total_denda': totalDenda,
      };
    } catch (e) {
      // Return default calculation if setting not found
      final today = DateTime.now();
      final keterlambatan = today.isAfter(tanggalKembaliRencana)
          ? today.difference(tanggalKembaliRencana).inDays
          : 0;

      final dendaKeterlambatan = keterlambatan * 5000.0;
      double dendaKerusakan = 0;

      switch (kondisi) {
        case 'rusak_ringan':
          dendaKerusakan = 50000;
          break;
        case 'rusak_berat':
          dendaKerusakan = 200000;
          break;
        case 'hilang':
          dendaKerusakan = 500000;
          break;
      }

      return {
        'keterlambatan': keterlambatan,
        'denda_keterlambatan': dendaKeterlambatan,
        'denda_kerusakan': dendaKerusakan,
        'total_denda': dendaKeterlambatan + dendaKerusakan,
      };
    }
  }

  /// Create pengembalian baru
  Future<void> createPengembalian({
    required int idPeminjaman,
    required String kondisiSaatKembali,
    String? catatanPengembalian,
    required int keterlambatanHari,
    required double dendaKeterlambatan,
    required double dendaKerusakan,
    required String idPetugas,
  }) async {
    try {
      emit(PengembalianOperationLoading('Memproses pengembalian...'));

      final totalDenda = dendaKeterlambatan + dendaKerusakan;

      // 1. Get data peminjaman untuk mengembalikan stok
      final peminjamanResponse = await _supabase
          .from('peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      final idAlat = peminjamanResponse['id_alat'] as int;
      final jumlahPinjam = peminjamanResponse['jumlah_pinjam'] as int;

      // 2. Create record pengembalian
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

      // 3. Update status peminjaman menjadi 'dikembalikan'
      await _supabase.from('peminjaman').update({
        'status_peminjaman': 'dikembalikan',
        'tanggal_kembali_actual': DateTime.now().toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_peminjaman', idPeminjaman);

      // 4. Kembalikan stok alat
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

      emit(PengembalianOperationSuccess('Pengembalian berhasil diproses'));
      await loadPengembalian();
    } catch (e) {
      emit(PengembalianError('Gagal memproses pengembalian: ${e.toString()}'));
      await loadPengembalian();
    }
  }

  /// Update status pembayaran menjadi lunas
  Future<void> updatePaymentStatus(int idPengembalian) async {
    try {
      emit(PengembalianOperationLoading('Mengkonfirmasi pembayaran...'));

      await _supabase.from('pengembalian').update({
        'status_pembayaran': 'lunas',
      }).eq('id_pengembalian', idPengembalian);

      emit(PengembalianOperationSuccess('Pembayaran berhasil dikonfirmasi'));
      await loadPengembalian();
    } catch (e) {
      emit(PengembalianError('Gagal mengkonfirmasi pembayaran: ${e.toString()}'));
      await loadPengembalian();
    }
  }

  /// Delete pengembalian
  /// NOTE: Saat delete, status peminjaman tetap 'dikembalikan' dan stok tidak berubah
  /// karena barang memang sudah dikembalikan sebelumnya
  Future<void> deletePengembalian(
      int idPengembalian, int idPeminjaman) async {
    try {
      emit(PengembalianOperationLoading('Menghapus data pengembalian...'));

      // Delete record pengembalian
      await _supabase
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', idPengembalian);

      // Status peminjaman tetap 'dikembalikan'
      // Stok alat tidak dikembalikan lagi karena sudah dikembalikan saat create

      emit(PengembalianOperationSuccess('Data pengembalian berhasil dihapus'));
      await loadPengembalian();
    } catch (e) {
      emit(PengembalianError('Gagal menghapus data: ${e.toString()}'));
      await loadPengembalian();
    }
  }
}
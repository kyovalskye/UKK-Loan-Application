import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianCubit extends Cubit<PengembalianState> {
  final SupabaseClient _supabase;
  StreamSubscription<List<Map<String, dynamic>>>? _pengembalianSubscription;

  PengembalianCubit(this._supabase) : super(PengembalianInitial());

  // Load pengembalian with realtime
  Future<void> loadPengembalian() async {
    try {
      emit(PengembalianLoading());

      // Cancel previous subscription if exists
      await _pengembalianSubscription?.cancel();

      // Setup realtime subscription
      _pengembalianSubscription = _supabase
          .from('pengembalian')
          .stream(primaryKey: ['id_pengembalian'])
          .order('created_at', ascending: false)
          .listen(
            (data) async {
              // Enrich data with related information
              final enrichedData = await _enrichPengembalianData(data);

              final currentState = state;
              if (currentState is PengembalianLoaded) {
                emit(currentState.copyWith(pengembalianList: enrichedData));
              } else {
                emit(PengembalianLoaded(pengembalianList: enrichedData));
              }
            },
            onError: (error) {
              emit(PengembalianError('Gagal memuat data: ${error.toString()}'));
            },
          );
    } catch (e) {
      emit(PengembalianError('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  // Enrich pengembalian data with user and alat information
  Future<List<Map<String, dynamic>>> _enrichPengembalianData(
    List<Map<String, dynamic>> pengembalianData,
  ) async {
    List<Map<String, dynamic>> enrichedList = [];

    for (var pengembalian in pengembalianData) {
      try {
        // Get peminjaman data
        final peminjamanResponse = await _supabase
            .from('peminjaman')
            .select(
              '*, users!peminjaman_id_user_fkey(nama, email), alat!peminjaman_id_alat_fkey(nama_alat, id_kategori, kategori!alat_id_kategori_fkey(nama))',
            )
            .eq('id_peminjaman', pengembalian['id_peminjaman'])
            .single();

        // Get petugas data
        final petugasResponse = await _supabase
            .from('users')
            .select('nama, email')
            .eq('user_id', pengembalian['id_petugas'])
            .single();

        enrichedList.add({
          'id_pengembalian': pengembalian['id_pengembalian'],
          'id_peminjaman': pengembalian['id_peminjaman'],
          'kode_peminjaman': peminjamanResponse['kode_peminjaman'],
          'nama_user': peminjamanResponse['users']['nama'] ?? 'Unknown',
          'email_user': peminjamanResponse['users']['email'] ?? '',
          'nama_alat': peminjamanResponse['alat']['nama_alat'] ?? 'Unknown',
          'kategori':
              peminjamanResponse['alat']['kategori']['nama'] ?? 'Uncategorized',
          'jumlah': peminjamanResponse['jumlah_pinjam'],
          'tanggal_pinjam': peminjamanResponse['tanggal_pinjam'],
          'tanggal_kembali_rencana':
              peminjamanResponse['tanggal_kembali_rencana'],
          'tanggal_kembali_actual': pengembalian['tanggal_pengembalian']
              .toString()
              .split('T')[0],
          'kondisi_kembali': pengembalian['kondisi_saat_kembali'],
          'keterlambatan': pengembalian['keterlambatan_hari'] ?? 0,
          'denda_keterlambatan': (pengembalian['denda_keterlambatan'] ?? 0)
              .toInt(),
          'denda_kerusakan': (pengembalian['denda_kerusakan'] ?? 0).toInt(),
          'total_denda': (pengembalian['total_denda'] ?? 0).toInt(),
          'status_pembayaran': pengembalian['status_pembayaran'],
          'catatan': pengembalian['catatan_pengembalian'] ?? '',
          'nama_petugas': petugasResponse['nama'] ?? 'Unknown',
          'created_at': pengembalian['created_at'],
        });
      } catch (e) {
        print(
          'Error enriching pengembalian ${pengembalian['id_pengembalian']}: $e',
        );
        // Add with minimal data if enrichment fails
        enrichedList.add({
          'id_pengembalian': pengembalian['id_pengembalian'],
          'id_peminjaman': pengembalian['id_peminjaman'],
          'kode_peminjaman': 'Unknown',
          'nama_user': 'Unknown',
          'email_user': '',
          'nama_alat': 'Unknown',
          'kategori': 'Unknown',
          'jumlah': 0,
          'tanggal_pinjam': '',
          'tanggal_kembali_rencana': '',
          'tanggal_kembali_actual': pengembalian['tanggal_pengembalian']
              .toString()
              .split('T')[0],
          'kondisi_kembali': pengembalian['kondisi_saat_kembali'],
          'keterlambatan': pengembalian['keterlambatan_hari'] ?? 0,
          'denda_keterlambatan': (pengembalian['denda_keterlambatan'] ?? 0)
              .toInt(),
          'denda_kerusakan': (pengembalian['denda_kerusakan'] ?? 0).toInt(),
          'total_denda': (pengembalian['total_denda'] ?? 0).toInt(),
          'status_pembayaran': pengembalian['status_pembayaran'],
          'catatan': pengembalian['catatan_pengembalian'] ?? '',
          'nama_petugas': 'Unknown',
          'created_at': pengembalian['created_at'],
        });
      }
    }

    return enrichedList;
  }

  // Create pengembalian
  Future<void> createPengembalian({
    required int idPeminjaman,
    required String kondisiSaatKembali,
    required String catatanPengembalian,
    required int keterlambatanHari,
    required double dendaKeterlambatan,
    required double dendaKerusakan,
    required String idPetugas,
  }) async {
    try {
      emit(const PengembalianOperationLoading('Memproses pengembalian...'));

      final totalDenda = dendaKeterlambatan + dendaKerusakan;

      // Insert pengembalian
      await _supabase.from('pengembalian').insert({
        'id_peminjaman': idPeminjaman,
        'kondisi_saat_kembali': kondisiSaatKembali,
        'catatan_pengembalian': catatanPengembalian,
        'keterlambatan_hari': keterlambatanHari,
        'denda_keterlambatan': dendaKeterlambatan,
        'denda_kerusakan': dendaKerusakan,
        'total_denda': totalDenda,
        'status_pembayaran': totalDenda > 0 ? 'belum_bayar' : 'lunas',
        'id_petugas': idPetugas,
      });

      // Update peminjaman status
      await _supabase
          .from('peminjaman')
          .update({
            'status_peminjaman': 'dikembalikan',
            'tanggal_kembali_actual': DateTime.now().toIso8601String().split(
              'T',
            )[0],
          })
          .eq('id_peminjaman', idPeminjaman);

      // Get peminjaman data to update alat
      final peminjaman = await _supabase
          .from('peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      // Update alat availability
      await _supabase.rpc(
        'kembalikan_alat',
        params: {
          'p_id_alat': peminjaman['id_alat'],
          'p_jumlah': peminjaman['jumlah_pinjam'],
          'p_kondisi': kondisiSaatKembali,
        },
      );

      emit(
        const PengembalianOperationSuccess('Pengembalian berhasil diproses'),
      );

      // Reload data
      await loadPengembalian();
    } catch (e) {
      emit(PengembalianError('Gagal memproses pengembalian: ${e.toString()}'));
      await loadPengembalian();
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(int idPengembalian) async {
    try {
      emit(
        const PengembalianOperationLoading('Memperbarui status pembayaran...'),
      );

      await _supabase
          .from('pengembalian')
          .update({'status_pembayaran': 'lunas'})
          .eq('id_pengembalian', idPengembalian);

      emit(
        const PengembalianOperationSuccess(
          'Status pembayaran berhasil diperbarui',
        ),
      );

      // State will auto-update via realtime
    } catch (e) {
      emit(
        PengembalianError(
          'Gagal memperbarui status pembayaran: ${e.toString()}',
        ),
      );
      await loadPengembalian();
    }
  }

  // Delete pengembalian
  Future<void> deletePengembalian(int idPengembalian, int idPeminjaman) async {
    try {
      emit(const PengembalianOperationLoading('Menghapus data...'));

      // Get peminjaman data before deleting
      final peminjaman = await _supabase
          .from('peminjaman')
          .select('id_alat, jumlah_pinjam, status_peminjaman')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      // Delete pengembalian
      await _supabase
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', idPengembalian);

      // If peminjaman was returned, change status back to dipinjam
      if (peminjaman['status_peminjaman'] == 'dikembalikan') {
        await _supabase
            .from('peminjaman')
            .update({
              'status_peminjaman': 'dipinjam',
              'tanggal_kembali_actual': null,
            })
            .eq('id_peminjaman', idPeminjaman);

        // Decrease alat availability
        await _supabase.rpc(
          'pinjam_alat',
          params: {
            'p_id_alat': peminjaman['id_alat'],
            'p_jumlah': peminjaman['jumlah_pinjam'],
          },
        );
      }

      emit(
        const PengembalianOperationSuccess(
          'Data pengembalian berhasil dihapus',
        ),
      );

      // State will auto-update via realtime
    } catch (e) {
      emit(PengembalianError('Gagal menghapus data: ${e.toString()}'));
      await loadPengembalian();
    }
  }

  // Search pengembalian
  void searchPengembalian(String query) {
    final currentState = state;
    if (currentState is PengembalianLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  // Filter by status
  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is PengembalianLoaded) {
      emit(currentState.copyWith(statusFilter: status));
    }
  }

  // Get active peminjaman (for creating pengembalian)
  Future<List<Map<String, dynamic>>> getActivePeminjaman() async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select(
            '*, users!peminjaman_id_user_fkey(nama), alat!peminjaman_id_alat_fkey(nama_alat)',
          )
          .eq('status_peminjaman', 'dipinjam')
          .order('tanggal_pinjam', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat data peminjaman: ${e.toString()}');
    }
  }

  // Calculate denda
  Future<Map<String, dynamic>> calculateDenda({
    required DateTime tanggalKembaliRencana,
    required String kondisi,
  }) async {
    try {
      // Get setting denda
      final settingDenda = await _supabase
          .from('setting_denda')
          .select()
          .single();

      // Calculate late days
      final now = DateTime.now();
      final plannedReturn = tanggalKembaliRencana;
      final lateDays = now.difference(plannedReturn).inDays;
      final keterlambatan = lateDays > 0 ? lateDays : 0;

      // Calculate late fee
      final dendaPerHari = settingDenda['denda_per_hari'] ?? 5000;
      final dendaKeterlambatan = keterlambatan * dendaPerHari.toDouble();

      // Calculate damage fee
      double dendaKerusakan = 0;
      if (kondisi == 'rusak_ringan') {
        dendaKerusakan = (settingDenda['denda_rusak_ringan'] ?? 50000)
            .toDouble();
      } else if (kondisi == 'rusak_berat') {
        dendaKerusakan = (settingDenda['denda_rusak_berat'] ?? 200000)
            .toDouble();
      }

      return {
        'keterlambatan': keterlambatan,
        'denda_keterlambatan': dendaKeterlambatan,
        'denda_kerusakan': dendaKerusakan,
        'total_denda': dendaKeterlambatan + dendaKerusakan,
      };
    } catch (e) {
      throw Exception('Gagal menghitung denda: ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    _pengembalianSubscription?.cancel();
    return super.close();
  }
}

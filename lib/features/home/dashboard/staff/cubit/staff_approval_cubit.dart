import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/models/peminjaman_approval.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_approval_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffApprovalCubit extends Cubit<StaffApprovalState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _realtimeChannel; // TAMBAHKAN untuk realtime

  StaffApprovalCubit() : super(StaffApprovalInitial());

  /// Setup realtime subscription (OPSIONAL)
  void setupRealtime() {
    _realtimeChannel = _supabase
        .channel('peminjaman_approval_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'peminjaman',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status_peminjaman',
            value: 'diajukan',
          ),
          callback: (payload) {
            print('🔄 Realtime update detected: ${payload.eventType}');
            loadPendingRequests();
          },
        )
        .subscribe();
    
    print('✅ Realtime subscription active');
  }

  /// Load semua peminjaman yang statusnya 'diajukan'
  Future<void> loadPendingRequests() async {
    try {
      emit(StaffApprovalLoading());

      // 1. Query peminjaman dengan user (menggunakan foreign key relationship)
      final peminjamanResponse = await _supabase
          .from('peminjaman')
          .select('*, users!inner(nama, email)')
          .eq('status_peminjaman', 'diajukan')
          .order('created_at', ascending: false);

      final peminjamanList = peminjamanResponse as List<dynamic>;

      // Jika tidak ada data
      if (peminjamanList.isEmpty) {
        emit(StaffApprovalLoaded(
          allRequests: [],
          filteredRequests: [],
        ));
        return;
      }

      // 2. Ambil semua ID alat yang unik
      final alatIds = peminjamanList
          .map((p) => p['id_alat'] as int)
          .toSet()
          .toList();

      // 3. Query alat TANPA kategori dulu
      final alatResponse = await _supabase
          .from('alat')
          .select('id_alat, nama_alat, jumlah_tersedia, foto_alat, id_kategori')
          .inFilter('id_alat', alatIds);

      final alatList = alatResponse as List<dynamic>;

      // 4. Ambil semua kategori ID yang ada
      final kategoriIds = alatList
          .where((a) => a['id_kategori'] != null)
          .map((a) => a['id_kategori'] as int)
          .toSet()
          .toList();

      // 5. Query kategori secara terpisah dan buat Map
      final Map<int, String> kategoriMap = {};
      if (kategoriIds.isNotEmpty) {
        final kategoriResponse = await _supabase
            .from('kategori')
            .select('id_kategori, nama')
            .inFilter('id_kategori', kategoriIds);

        final kategoriList = kategoriResponse as List<dynamic>;
        for (var kat in kategoriList) {
          kategoriMap[kat['id_kategori'] as int] = kat['nama'] as String;
        }
      }

      // 6. Buat Map untuk lookup alat berdasarkan id_alat
      final Map<int, Map<String, dynamic>> alatMap = {};
      for (var alat in alatList) {
        final idAlat = alat['id_alat'] as int;
        final idKategori = alat['id_kategori'] as int?;
        
        // Gabungkan data alat dengan nama kategori
        alatMap[idAlat] = <String, dynamic>{
          ...alat,
          'kategori': <String, dynamic>{
            'nama': idKategori != null ? (kategoriMap[idKategori] ?? '-') : '-'
          }
        };
      }

      // 7. Gabungkan semua data dan transform ke PeminjamanApproval
      final requests = <PeminjamanApproval>[];
      for (var peminjaman in peminjamanList) {
        final idAlat = peminjaman['id_alat'] as int;
        
        // Ambil data alat dari map, atau gunakan default jika tidak ada
        final alatData = alatMap[idAlat] ?? <String, dynamic>{
          'id_alat': idAlat,
          'nama_alat': 'Unknown',
          'jumlah_tersedia': 0,
          'foto_alat': null,
          'id_kategori': null,
          'kategori': <String, dynamic>{'nama': '-'},
        };

        // Buat enriched data dengan struktur yang benar
        final enrichedData = <String, dynamic>{
          ...peminjaman,
          'alat': alatData,
        };

        requests.add(PeminjamanApproval.fromMap(enrichedData));
      }

      emit(StaffApprovalLoaded(
        allRequests: requests,
        filteredRequests: requests,
      ));
    } catch (e) {
      print('❌ Error loadPendingRequests: $e');
      emit(StaffApprovalError('Gagal memuat data: ${e.toString()}'));
    }
  }

  /// Search peminjaman
  void searchRequests(String query) {
    final currentState = state;
    if (currentState is! StaffApprovalLoaded) return;

    final filtered = currentState.allRequests.where((request) {
      final searchLower = query.toLowerCase();
      return request.kodePeminjaman.toLowerCase().contains(searchLower) ||
          request.namaUser.toLowerCase().contains(searchLower) ||
          request.namaAlat.toLowerCase().contains(searchLower);
    }).toList();

    emit(currentState.copyWith(
      filteredRequests: filtered,
      searchQuery: query,
    ));
  }

  /// Filter by status
  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is! StaffApprovalLoaded) return;

    List<PeminjamanApproval> filtered;
    if (status == 'Semua') {
      filtered = currentState.allRequests;
    } else {
      filtered = currentState.allRequests.where((request) {
        if (status == 'Diajukan') return request.statusPeminjaman == 'diajukan';
        return false;
      }).toList();
    }

    emit(currentState.copyWith(
      filteredRequests: filtered,
      statusFilter: status,
    ));
  }

  /// Approve peminjaman
  Future<void> approvePeminjaman({
    required int idPeminjaman,
    required int idAlat,
    required int jumlahPinjam,
    String? catatanAdmin,
  }) async {
    try {
      final currentState = state;
      if (currentState is! StaffApprovalLoaded) return;

      // Emit loading state sambil mempertahankan data
      emit(currentState.copyWith(
        isOperating: true,
        operationMessage: 'Menyetujui peminjaman...',
      ));

      // 1. Cek stok terlebih dahulu
      final alatResponse = await _supabase
          .from('alat')
          .select('jumlah_tersedia')
          .eq('id_alat', idAlat)
          .single();

      final jumlahTersedia = alatResponse['jumlah_tersedia'] as int;

      if (jumlahTersedia < jumlahPinjam) {
        emit(StaffApprovalError('Stok tidak mencukupi. Tersedia: $jumlahTersedia'));
        await loadPendingRequests();
        return;
      }

      // 2. Update status peminjaman menjadi 'dipinjam'
      await _supabase.from('peminjaman').update({
        'status_peminjaman': 'dipinjam',
        'catatan_admin': catatanAdmin,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_peminjaman', idPeminjaman);

      // 3. Kurangi stok alat
      await _supabase.from('alat').update({
        'jumlah_tersedia': jumlahTersedia - jumlahPinjam,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);

      emit(StaffApprovalOperationSuccess('Peminjaman berhasil disetujui'));
      await loadPendingRequests();
    } catch (e) {
      print('❌ Error approvePeminjaman: $e');
      final message = e is PostgrestException ? e.message : e.toString();
      emit(StaffApprovalError('Gagal menyetujui peminjaman:\n$message'));
      await loadPendingRequests();
    }
  }

  /// Reject peminjaman
  Future<void> rejectPeminjaman({
    required int idPeminjaman,
    String? catatanAdmin,
  }) async {
    try {
      final currentState = state;
      if (currentState is! StaffApprovalLoaded) return;

      // Emit loading state sambil mempertahankan data
      emit(currentState.copyWith(
        isOperating: true,
        operationMessage: 'Menolak peminjaman...',
      ));

      await _supabase.from('peminjaman').update({
        'status_peminjaman': 'ditolak',
        'catatan_admin': catatanAdmin ?? 'Peminjaman ditolak',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_peminjaman', idPeminjaman);

      emit(StaffApprovalOperationSuccess('Peminjaman berhasil ditolak'));
      await loadPendingRequests();
    } catch (e) {
      print('❌ Error rejectPeminjaman: $e');
      emit(StaffApprovalError('Gagal menolak: ${e.toString()}'));
      await loadPendingRequests();
    }
  }

  /// Get detail setting denda untuk perhitungan
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
      // Return default values if setting not found
      return {
        'denda_per_hari': 5000.0,
        'denda_rusak_ringan': 50000.0,
        'denda_rusak_berat': 200000.0,
        'denda_hilang_persen': 100,
        'maksimal_hari_pinjam': 7,
      };
    }
  }

  @override
  Future<void> close() {
    _realtimeChannel?.unsubscribe(); // Unsubscribe saat cubit di-close
    return super.close();
  }
}
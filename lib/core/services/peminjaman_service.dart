import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamanService {
  final _supabase = Supabase.instance.client;

  // Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Get all peminjaman for current user
  Future<List<Map<String, dynamic>>> getPeminjamanByUser({
    String? statusFilter,
    String? searchQuery,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Build query dengan filter status jika ada
      var query = _supabase
          .from('peminjaman')
          .select('''
            *,
            alat:id_alat (
              id_alat,
              nama_alat,
              foto_alat,
              kategori:id_kategori (
                id_kategori,
                nama
              )
            ),
            users:id_user (
              user_id,
              nama,
              email
            )
          ''')
          .eq('id_user', userId);

      // Apply status filter
      if (statusFilter != null && statusFilter != 'Semua') {
        // Map display name to database value
        final statusMap = {
          'Diajukan': 'diajukan',
          'Disetujui': 'disetujui',
          'Dipinjam': 'dipinjam',
          'Dikembalikan': 'dikembalikan',
          'Ditolak': 'ditolak',
          'Terlambat': 'terlambat',
        };
        
        final dbStatus = statusMap[statusFilter] ?? statusFilter.toLowerCase();
        query = query.eq('status_peminjaman', dbStatus);
      }

      final response = await query.order('created_at', ascending: false);

      // Apply search filter locally if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return (response as List).where((item) {
          final kode = (item['kode_peminjaman'] ?? '').toString().toLowerCase();
          final namaAlat = ((item['alat'] as Map?)?['nama_alat'] ?? '')
              .toString()
              .toLowerCase();
          final search = searchQuery.toLowerCase();
          return kode.contains(search) || namaAlat.contains(search);
        }).toList().cast<Map<String, dynamic>>();
      }

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting peminjaman: $e');
      rethrow;
    }
  }

  // Get active tanggungan (dipinjam/terlambat) for current user
  Future<List<Map<String, dynamic>>> getTanggunganByUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('peminjaman')
          .select('''
            *,
            alat:id_alat (
              id_alat,
              nama_alat,
              foto_alat,
              kategori:id_kategori (
                id_kategori,
                nama
              )
            )
          ''')
          .eq('id_user', userId)
          .inFilter('status_peminjaman', ['dipinjam', 'terlambat'])
          .order('tanggal_kembali_rencana', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting tanggungan: $e');
      rethrow;
    }
  }

  // Get denda information for a peminjaman
  Future<Map<String, dynamic>> getPeminjamanDenda(int idPeminjaman) async {
    try {
      final response = await _supabase
          .rpc('get_peminjaman_denda', params: {'p_id_peminjaman': idPeminjaman});

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }

      return {
        'hari_terlambat': 0,
        'denda_per_hari': 0,
        'total_denda': 0,
      };
    } catch (e) {
      print('Error getting denda: $e');
      return {
        'hari_terlambat': 0,
        'denda_per_hari': 0,
        'total_denda': 0,
      };
    }
  }

  // Get setting denda
  Future<Map<String, dynamic>> getSettingDenda() async {
    try {
      final response = await _supabase
          .from('setting_denda')
          .select()
          .limit(1)
          .single();

      return response;
    } catch (e) {
      print('Error getting setting denda: $e');
      // Return default values
      return {
        'denda_per_hari': 5000,
        'denda_rusak_ringan': 50000,
        'denda_rusak_berat': 200000,
        'denda_hilang_persen': 100,
        'maksimal_hari_pinjam': 7,
      };
    }
  }

  // Manual check and update late peminjaman
  Future<void> checkAndUpdateLatePeminjaman() async {
    try {
      await _supabase.rpc('check_and_update_late_peminjaman');
    } catch (e) {
      print('Error checking late peminjaman: $e');
      rethrow;
    }
  }

  // Get peminjaman statistics for current user
  Future<Map<String, int>> getPeminjamanStats() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('peminjaman')
          .select('status_peminjaman')
          .eq('id_user', userId);

      final data = (response as List).cast<Map<String, dynamic>>();

      return {
        'total': data.length,
        'diajukan': data.where((p) => p['status_peminjaman'] == 'diajukan').length,
        'disetujui': data.where((p) => p['status_peminjaman'] == 'disetujui').length,
        'dipinjam': data.where((p) => p['status_peminjaman'] == 'dipinjam').length,
        'dikembalikan': data.where((p) => p['status_peminjaman'] == 'dikembalikan').length,
        'ditolak': data.where((p) => p['status_peminjaman'] == 'ditolak').length,
        'terlambat': data.where((p) => p['status_peminjaman'] == 'terlambat').length,
      };
    } catch (e) {
      print('Error getting stats: $e');
      rethrow;
    }
  }

  // Check if peminjaman is late
  bool isPeminjamanLate(Map<String, dynamic> peminjaman) {
    if (peminjaman['status_peminjaman'] == 'terlambat') return true;
    
    if (peminjaman['status_peminjaman'] != 'dipinjam') return false;

    final tanggalKembali = DateTime.parse(peminjaman['tanggal_kembali_rencana']);
    final today = DateTime.now();
    
    return today.isAfter(tanggalKembali);
  }

  // Calculate days late
  int getDaysLate(String tanggalKembaliRencana) {
    final dueDate = DateTime.parse(tanggalKembaliRencana);
    final today = DateTime.now();
    
    if (today.isAfter(dueDate)) {
      return today.difference(dueDate).inDays;
    }
    
    return 0;
  }

  // Calculate days until due
  int getDaysUntilDue(String tanggalKembaliRencana) {
    final dueDate = DateTime.parse(tanggalKembaliRencana);
    final today = DateTime.now();
    
    return dueDate.difference(today).inDays;
  }

  // Calculate denda locally (fallback if RPC not available)
  Future<Map<String, dynamic>> calculateDendaLocally(
    Map<String, dynamic> peminjaman,
  ) async {
    try {
      print('\n🔄 calculateDendaLocally called');
      print('   Peminjaman: ${peminjaman['kode_peminjaman']}');
      
      final status = peminjaman['status_peminjaman'];
      print('   Status: $status');
      
      // Hanya hitung denda jika status dipinjam atau terlambat
      if (status != 'dipinjam' && status != 'terlambat') {
        print('   ℹ️ Status bukan dipinjam/terlambat, skip calculation');
        return {
          'hari_terlambat': 0,
          'denda_per_hari': 0,
          'total_denda': 0,
        };
      }

      final tanggalKembaliStr = peminjaman['tanggal_kembali_rencana'];
      print('   Tanggal kembali rencana: $tanggalKembaliStr');
      
      final tanggalKembali = DateTime.parse(tanggalKembaliStr);
      final today = DateTime.now();
      
      print('   Today: ${today.toIso8601String()}');
      print('   Due date: ${tanggalKembali.toIso8601String()}');

      // Cek apakah sudah lewat jatuh tempo
      if (!today.isAfter(tanggalKembali)) {
        print('   ℹ️ Belum lewat jatuh tempo');
        return {
          'hari_terlambat': 0,
          'denda_per_hari': 0,
          'total_denda': 0,
        };
      }

      // Hitung hari terlambat
      final hariTerlambat = today.difference(tanggalKembali).inDays;
      print('   Hari terlambat: $hariTerlambat hari');

      // Get setting denda
      final setting = await getSettingDenda();
      final dendaPerHari = (setting['denda_per_hari'] as num).toDouble();
      print('   Denda per hari: Rp $dendaPerHari');

      // Get jumlah pinjam
      final jumlahPinjam = peminjaman['jumlah_pinjam'] as int? ?? 1;
      print('   Jumlah pinjam: $jumlahPinjam');

      // Hitung total denda
      final totalDenda = hariTerlambat * dendaPerHari * jumlahPinjam;
      print('   💰 Total denda: Rp $totalDenda');
      print('   Formula: $hariTerlambat × $dendaPerHari × $jumlahPinjam = $totalDenda');

      final result = {
        'hari_terlambat': hariTerlambat,
        'denda_per_hari': dendaPerHari,
        'total_denda': totalDenda,
      };
      
      print('   ✅ Result: $result');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error calculating denda locally: $e');
      print('Stack trace: $stackTrace');
      return {
        'hari_terlambat': 0,
        'denda_per_hari': 0,
        'total_denda': 0,
      };
    }
  }
}
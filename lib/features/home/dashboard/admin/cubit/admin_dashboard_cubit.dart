import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final _supabase = Supabase.instance.client;

  AdminDashboardCubit() : super(AdminDashboardInitial());

  Future<void> loadDashboardStatistics() async {
    try {
      emit(AdminDashboardLoading());

      // Fetch data secara parallel untuk performa lebih baik
      final results = await Future.wait([
        _getAlatStatistics(),
        _getPeminjamanStatistics(),
        _getUserStatistics(),
      ]);

      final alatStats = results[0];
      final peminjamanStats = results[1];
      final userStats = results[2];

      final statistics = {
        // Alat Statistics
        'totalAlat': alatStats['total'] ?? 0,
        'totalTersedia': alatStats['tersedia'] ?? 0,
        'totalDipinjam': alatStats['dipinjam'] ?? 0,
        'totalMaintenance': alatStats['maintenance'] ?? 0,
        
        // Peminjaman Statistics
        'totalPeminjaman': peminjamanStats['total'] ?? 0,
        'pendingApproval': peminjamanStats['diajukan'] ?? 0,
        'activePeminjaman': peminjamanStats['dipinjam'] ?? 0,
        'terlambat': peminjamanStats['terlambat'] ?? 0,
        'disetujui': peminjamanStats['disetujui'] ?? 0,
        'dikembalikan': peminjamanStats['dikembalikan'] ?? 0,
        'ditolak': peminjamanStats['ditolak'] ?? 0,
        
        // User Statistics
        'totalUsers': userStats['total'] ?? 0,
        'totalPeminjam': userStats['peminjam'] ?? 0,
        'totalAdmin': userStats['admin'] ?? 0,
        'totalPetugas': userStats['petugas'] ?? 0,
      };

      emit(AdminDashboardLoaded(statistics));
    } catch (e) {
      print('Error loading dashboard statistics: $e');
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _getAlatStatistics() async {
    try {
      final response = await _supabase
          .from('alat')
          .select('status, jumlah_total, jumlah_tersedia');

      final data = (response as List).cast<Map<String, dynamic>>();

      int total = data.length;
      int tersedia = 0;
      int dipinjam = 0;
      int maintenance = 0;

      for (var alat in data) {
        final status = alat['status'] as String?;
        if (status == 'tersedia') {
          tersedia++;
        } else if (status == 'dipinjam') {
          dipinjam++;
        } else if (status == 'maintenance') {
          maintenance++;
        }
      }

      return {
        'total': total,
        'tersedia': tersedia,
        'dipinjam': dipinjam,
        'maintenance': maintenance,
      };
    } catch (e) {
      print('Error getting alat statistics: $e');
      return {
        'total': 0,
        'tersedia': 0,
        'dipinjam': 0,
        'maintenance': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _getPeminjamanStatistics() async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('status_peminjaman');

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
      print('Error getting peminjaman statistics: $e');
      return {
        'total': 0,
        'diajukan': 0,
        'disetujui': 0,
        'dipinjam': 0,
        'dikembalikan': 0,
        'ditolak': 0,
        'terlambat': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _getUserStatistics() async {
    try {
      final response = await _supabase
          .from('users')
          .select('role');

      final data = (response as List).cast<Map<String, dynamic>>();

      return {
        'total': data.length,
        'peminjam': data.where((u) => u['role'] == 'peminjam').length,
        'admin': data.where((u) => u['role'] == 'admin').length,
        'petugas': data.where((u) => u['role'] == 'petugas').length,
        'kasir': data.where((u) => u['role'] == 'kasir').length,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'total': 0,
        'peminjam': 0,
        'admin': 0,
        'petugas': 0,
        'kasir': 0,
      };
    }
  }

  Future<void> refresh() async {
    await loadDashboardStatistics();
  }
}
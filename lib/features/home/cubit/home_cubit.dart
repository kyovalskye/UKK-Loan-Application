import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/supabase_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SupabaseService _supabaseService;

  HomeCubit(this._supabaseService) : super(const HomeState());

  // Load data untuk Peminjam (list alat tersedia)
  Future<void> loadAlatTersedia() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final alatList = await _supabaseService.getAlat(status: 'tersedia');

      emit(state.copyWith(
        status: HomeStatus.loaded,
        alatList: alatList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Load data untuk Petugas (pending requests)
  Future<void> loadPendingRequests() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final requests = await _supabaseService.getPeminjaman(
        status: 'diajukan',
      );

      emit(state.copyWith(
        status: HomeStatus.loaded,
        pendingRequests: requests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Load data untuk Admin (statistics dashboard)
  Future<void> loadAdminDashboard() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Get all data for statistics
      final allPeminjaman = await _supabaseService.getPeminjaman();
      final allAlat = await _supabaseService.getAlat();

      // Calculate statistics
      final totalAlat = allAlat.length;
      final totalTersedia = allAlat.where((a) => a['status'] == 'tersedia').length;
      final totalDipinjam = allAlat.where((a) => a['status'] == 'dipinjam').length;
      
      final totalPeminjaman = allPeminjaman.length;
      final pendingApproval = allPeminjaman.where((p) => p['status_peminjaman'] == 'diajukan').length;
      final activePeminjaman = allPeminjaman.where((p) => p['status_peminjaman'] == 'dipinjam').length;
      final terlambat = allPeminjaman.where((p) => p['status_peminjaman'] == 'terlambat').length;

      final statistics = {
        'totalAlat': totalAlat,
        'totalTersedia': totalTersedia,
        'totalDipinjam': totalDipinjam,
        'totalPeminjaman': totalPeminjaman,
        'pendingApproval': pendingApproval,
        'activePeminjaman': activePeminjaman,
        'terlambat': terlambat,
      };

      emit(state.copyWith(
        status: HomeStatus.loaded,
        statistics: statistics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Refresh berdasarkan role
  Future<void> refresh(String role) async {
    if (role == 'peminjam') {
      await loadAlatTersedia();
    } else if (role == 'petugas') {
      await loadPendingRequests();
    } else if (role == 'admin') {
      await loadAdminDashboard();
    }
  }
}
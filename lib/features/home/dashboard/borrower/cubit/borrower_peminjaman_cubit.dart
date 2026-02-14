import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/peminjaman_service.dart';
import 'borrower_peminjaman_state.dart';

class BorrowerPeminjamanCubit extends Cubit<BorrowerPeminjamanState> {
  final PeminjamanService _peminjamanService;

  BorrowerPeminjamanCubit({
    required PeminjamanService peminjamanService,
  })  : _peminjamanService = peminjamanService,
        super(const BorrowerPeminjamanState());

  Future<void> loadData({
    String? statusFilter,
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Load peminjaman data
      final peminjaman = await _peminjamanService.getPeminjamanByUser(
        statusFilter: statusFilter ?? state.selectedStatusFilter,
        searchQuery: searchQuery ?? state.searchQuery,
      );

      // Load statistics
      final stats = await _peminjamanService.getPeminjamanStats();

      emit(state.copyWith(
        peminjamanList: peminjaman,
        stats: stats,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data: ${e.toString()}',
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateStatusFilter(String status) {
    emit(state.copyWith(selectedStatusFilter: status));
    loadData();
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
    loadData();
  }

  Future<void> refresh() async {
    await loadData();
  }
}
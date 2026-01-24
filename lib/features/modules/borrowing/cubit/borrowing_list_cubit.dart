import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/supabase_service.dart';
import 'borrowing_list_state.dart';

class BorrowingListCubit extends Cubit<BorrowingListState> {
  final SupabaseService _supabaseService;

  BorrowingListCubit(this._supabaseService) : super(const BorrowingListState());

  Future<void> loadMyBorrowings() async {
    emit(state.copyWith(status: BorrowingListStatus.loading));

    try {
      final userId = _supabaseService.currentUserId;
      final peminjamanList = await _supabaseService.getPeminjaman(userId: userId);

      emit(state.copyWith(
        status: BorrowingListStatus.loaded,
        peminjamanList: peminjamanList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BorrowingListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    await loadMyBorrowings();
  }
}
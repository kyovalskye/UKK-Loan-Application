import 'package:equatable/equatable.dart';

enum BorrowingListStatus {
  initial,
  loading,
  loaded,
  error,
}

class BorrowingListState extends Equatable {
  final BorrowingListStatus status;
  final List<Map<String, dynamic>> peminjamanList;
  final String? errorMessage;

  const BorrowingListState({
    this.status = BorrowingListStatus.initial,
    this.peminjamanList = const [],
    this.errorMessage,
  });

  BorrowingListState copyWith({
    BorrowingListStatus? status,
    List<Map<String, dynamic>>? peminjamanList,
    String? errorMessage,
  }) {
    return BorrowingListState(
      status: status ?? this.status,
      peminjamanList: peminjamanList ?? this.peminjamanList,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, peminjamanList, errorMessage];
}
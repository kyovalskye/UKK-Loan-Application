abstract class StaffPengembalianState {}

class StaffPengembalianInitial extends StaffPengembalianState {}

class StaffPengembalianLoading extends StaffPengembalianState {}

class StaffPengembalianLoaded extends StaffPengembalianState {
  final List<dynamic> allBorrowings;
  final List<dynamic> filteredBorrowings;
  final String searchQuery;

  StaffPengembalianLoaded({
    required this.allBorrowings,
    required this.filteredBorrowings,
    this.searchQuery = '',
  });

  StaffPengembalianLoaded copyWith({
    List<dynamic>? allBorrowings,
    List<dynamic>? filteredBorrowings,
    String? searchQuery,
  }) {
    return StaffPengembalianLoaded(
      allBorrowings: allBorrowings ?? this.allBorrowings,
      filteredBorrowings: filteredBorrowings ?? this.filteredBorrowings,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StaffPengembalianOperationLoading extends StaffPengembalianState {
  final String operation;
  StaffPengembalianOperationLoading(this.operation);
}

class StaffPengembalianOperationSuccess extends StaffPengembalianState {
  final String message;
  StaffPengembalianOperationSuccess(this.message);
}

class StaffPengembalianError extends StaffPengembalianState {
  final String message;
  StaffPengembalianError(this.message);
}
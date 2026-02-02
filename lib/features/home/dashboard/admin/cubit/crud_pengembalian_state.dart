abstract class PengembalianState {}

class PengembalianInitial extends PengembalianState {}

class PengembalianLoading extends PengembalianState {}

class PengembalianLoaded extends PengembalianState {
  final List<dynamic> allList;
  final List<dynamic> filteredList;
  final String searchQuery;
  final String statusFilter;

  PengembalianLoaded({
    required this.allList,
    required this.filteredList,
    this.searchQuery = '',
    this.statusFilter = 'Semua',
  });

  PengembalianLoaded copyWith({
    List<dynamic>? allList,
    List<dynamic>? filteredList,
    String? searchQuery,
    String? statusFilter,
  }) {
    return PengembalianLoaded(
      allList: allList ?? this.allList,
      filteredList: filteredList ?? this.filteredList,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class PengembalianOperationLoading extends PengembalianState {
  final String operation;

  PengembalianOperationLoading(this.operation);
}

class PengembalianOperationSuccess extends PengembalianState {
  final String message;

  PengembalianOperationSuccess(this.message);
}

class PengembalianError extends PengembalianState {
  final String message;

  PengembalianError(this.message);
}
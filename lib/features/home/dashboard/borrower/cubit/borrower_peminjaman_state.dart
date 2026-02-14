import 'package:equatable/equatable.dart';

class BorrowerPeminjamanState extends Equatable {
  final List<Map<String, dynamic>> peminjamanList;
  final Map<String, int> stats;
  final String selectedStatusFilter;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const BorrowerPeminjamanState({
    this.peminjamanList = const [],
    this.stats = const {},
    this.selectedStatusFilter = 'Semua',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  BorrowerPeminjamanState copyWith({
    List<Map<String, dynamic>>? peminjamanList,
    Map<String, int>? stats,
    String? selectedStatusFilter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BorrowerPeminjamanState(
      peminjamanList: peminjamanList ?? this.peminjamanList,
      stats: stats ?? this.stats,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        peminjamanList,
        stats,
        selectedStatusFilter,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}
import 'package:equatable/equatable.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Map<String, dynamic>> alatList;
  final List<Map<String, dynamic>> pendingRequests;
  final Map<String, int> statistics;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.alatList = const [],
    this.pendingRequests = const [],
    this.statistics = const {},
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Map<String, dynamic>>? alatList,
    List<Map<String, dynamic>>? pendingRequests,
    Map<String, int>? statistics,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      alatList: alatList ?? this.alatList,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      statistics: statistics ?? this.statistics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        alatList,
        pendingRequests,
        statistics,
        errorMessage,
      ];
} 
import 'package:rentalify/core/model/peminjaman_approval.dart';

abstract class StaffApprovalState {}

class StaffApprovalInitial extends StaffApprovalState {}

class StaffApprovalLoading extends StaffApprovalState {}

class StaffApprovalLoaded extends StaffApprovalState {
  final List<PeminjamanApproval> allRequests;
  final List<PeminjamanApproval> filteredRequests;
  final String searchQuery;
  final String statusFilter;

  StaffApprovalLoaded({
    required this.allRequests,
    required this.filteredRequests,
    this.searchQuery = '',
    this.statusFilter = 'Semua',
  });

  StaffApprovalLoaded copyWith({
    List<PeminjamanApproval>? allRequests,
    List<PeminjamanApproval>? filteredRequests,
    String? searchQuery,
    String? statusFilter,
  }) {
    return StaffApprovalLoaded(
      allRequests: allRequests ?? this.allRequests,
      filteredRequests: filteredRequests ?? this.filteredRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class StaffApprovalOperationLoading extends StaffApprovalState {
  final String operation;

  StaffApprovalOperationLoading(this.operation);
}

class StaffApprovalOperationSuccess extends StaffApprovalState {
  final String message;

  StaffApprovalOperationSuccess(this.message);
}

class StaffApprovalError extends StaffApprovalState {
  final String message;

  StaffApprovalError(this.message);
}
import 'package:rentalify/core/models/peminjaman_approval.dart';

abstract class StaffApprovalState {}

class StaffApprovalInitial extends StaffApprovalState {}

class StaffApprovalLoading extends StaffApprovalState {}

class StaffApprovalLoaded extends StaffApprovalState {
  final List<PeminjamanApproval> allRequests;
  final List<PeminjamanApproval> filteredRequests;
  final String searchQuery;
  final String statusFilter;
  final bool isOperating; // TAMBAHKAN INI
  final String? operationMessage; // TAMBAHKAN INI

  StaffApprovalLoaded({
    required this.allRequests,
    required this.filteredRequests,
    this.searchQuery = '',
    this.statusFilter = 'Semua',
    this.isOperating = false, // TAMBAHKAN INI
    this.operationMessage, // TAMBAHKAN INI
  });

  StaffApprovalLoaded copyWith({
    List<PeminjamanApproval>? allRequests,
    List<PeminjamanApproval>? filteredRequests,
    String? searchQuery,
    String? statusFilter,
    bool? isOperating, // TAMBAHKAN INI
    String? operationMessage, // TAMBAHKAN INI
  }) {
    return StaffApprovalLoaded(
      allRequests: allRequests ?? this.allRequests,
      filteredRequests: filteredRequests ?? this.filteredRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isOperating: isOperating ?? this.isOperating, // TAMBAHKAN INI
      operationMessage: operationMessage ?? this.operationMessage, // TAMBAHKAN INI
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
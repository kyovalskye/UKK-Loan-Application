import 'package:equatable/equatable.dart';

enum ApprovalStatus {
  initial,
  loading,
  loaded,
  processing,
  success,
  error,
}

class ApprovalState extends Equatable {
  final ApprovalStatus status;
  final List<Map<String, dynamic>> pendingList;
  final String? errorMessage;
  final String? successMessage;

  const ApprovalState({
    this.status = ApprovalStatus.initial,
    this.pendingList = const [],
    this.errorMessage,
    this.successMessage,
  });

  ApprovalState copyWith({
    ApprovalStatus? status,
    List<Map<String, dynamic>>? pendingList,
    String? errorMessage,
    String? successMessage,
  }) {
    return ApprovalState(
      status: status ?? this.status,
      pendingList: pendingList ?? this.pendingList,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, pendingList, errorMessage, successMessage];
}
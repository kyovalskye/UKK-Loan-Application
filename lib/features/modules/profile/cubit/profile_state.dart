import 'package:equatable/equatable.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? errorMessage;
  final String? successMessage;
  final bool isUploading;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isUploading = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? isUploading,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage, isUploading];
}
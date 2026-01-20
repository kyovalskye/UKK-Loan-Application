import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final Map<String, dynamic>? userData;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userData,
    this.errorMessage,
  });

  String? get userId => userData?['user_id'];
  String? get userName => userData?['nama'];
  String? get userEmail => userData?['email'];
  String? get userRole => userData?['role'];

  bool get isAdmin => userRole == 'admin';
  bool get isPetugas => userRole == 'petugas';
  bool get isPeminjam => userRole == 'peminjam';

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? userData,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userData: userData ?? this.userData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userData, errorMessage];
}
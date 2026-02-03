part of 'admin_crud_peminjaman_cubit.dart';

abstract class CrudPeminjamanState extends Equatable {
  const CrudPeminjamanState();

  @override
  List<Object?> get props => [];
}

class CrudPeminjamanInitial extends CrudPeminjamanState {}

class CrudPeminjamanLoading extends CrudPeminjamanState {}

class CrudPeminjamanLoaded extends CrudPeminjamanState {
  final List<PeminjamanModel> peminjaman;

  const CrudPeminjamanLoaded(this.peminjaman);

  @override
  List<Object?> get props => [peminjaman];
}

class CrudPeminjamanSuccess extends CrudPeminjamanState {
  final String message;

  const CrudPeminjamanSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CrudPeminjamanError extends CrudPeminjamanState {
  final String message;

  const CrudPeminjamanError(this.message);

  @override
  List<Object?> get props => [message];
}
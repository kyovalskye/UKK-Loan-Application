part of 'admin_crud_kategori_cubit.dart';

abstract class CrudKategoriState extends Equatable {
  const CrudKategoriState();

  @override
  List<Object?> get props => [];
}

class CrudKategoriInitial extends CrudKategoriState {}

class CrudKategoriLoading extends CrudKategoriState {}

class CrudKategoriLoaded extends CrudKategoriState {
  final List<Map<String, dynamic>> kategori;

  const CrudKategoriLoaded(this.kategori);

  @override
  List<Object?> get props => [kategori];
}

class CrudKategoriSuccess extends CrudKategoriState {
  final String message;

  const CrudKategoriSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CrudKategoriError extends CrudKategoriState {
  final String message;

  const CrudKategoriError(this.message);

  @override
  List<Object?> get props => [message];
}
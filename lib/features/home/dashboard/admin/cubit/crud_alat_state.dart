// crud_alat_state.dart
part of 'crud_alat_cubit.dart';

abstract class CrudAlatState extends Equatable {
  const CrudAlatState();

  @override
  List<Object?> get props => [];
}

class CrudAlatInitial extends CrudAlatState {}

class CrudAlatLoading extends CrudAlatState {}

class CrudAlatLoaded extends CrudAlatState {
  final List<Map<String, dynamic>> alatList;

  const CrudAlatLoaded(this.alatList);

  @override
  List<Object?> get props => [alatList];
}

class CrudAlatError extends CrudAlatState {
  final String message;

  const CrudAlatError(this.message);

  @override
  List<Object?> get props => [message];
}

class CrudAlatSuccess extends CrudAlatState {
  final String message;

  const CrudAlatSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
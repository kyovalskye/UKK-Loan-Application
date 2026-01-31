// crud_user_state.dart
part of 'crud_user_cubit.dart';

abstract class CrudUserState extends Equatable {
  const CrudUserState();

  @override
  List<Object?> get props => [];
}

class CrudUserInitial extends CrudUserState {}

class CrudUserLoading extends CrudUserState {}

class CrudUserLoaded extends CrudUserState {
  final List<Map<String, dynamic>> users;

  const CrudUserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class CrudUserError extends CrudUserState {
  final String message;

  const CrudUserError(this.message);

  @override
  List<Object?> get props => [message];
}

class CrudUserSuccess extends CrudUserState {
  final String message;

  const CrudUserSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
import 'package:equatable/equatable.dart';

abstract class LogAktivitasState extends Equatable {
  const LogAktivitasState();

  @override
  List<Object?> get props => [];
}

class LogAktivitasInitial extends LogAktivitasState {}

class LogAktivitasLoading extends LogAktivitasState {}

class LogAktivitasLoaded extends LogAktivitasState {
  final List<Map<String, dynamic>> logs;
  final String tableFilter;
  final String operasiFilter;

  const LogAktivitasLoaded({
    required this.logs,
    required this.tableFilter,
    required this.operasiFilter,
  });

  @override
  List<Object?> get props => [logs, tableFilter, operasiFilter];
}

class LogAktivitasError extends LogAktivitasState {
  final String message;

  const LogAktivitasError(this.message);

  @override
  List<Object?> get props => [message];
}
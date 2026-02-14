import 'package:equatable/equatable.dart';

abstract class LaporanState extends Equatable {
  const LaporanState();

  @override
  List<Object?> get props => [];
}

class LaporanInitial extends LaporanState {}

class LaporanLoading extends LaporanState {}

class LaporanLoaded extends LaporanState {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> statistik;

  const LaporanLoaded({
    required this.data,
    required this.statistik,
  });

  @override
  List<Object?> get props => [data, statistik];
}

class LaporanGenerating extends LaporanState {
  final String message;

  const LaporanGenerating(this.message);

  @override
  List<Object?> get props => [message];
}

class LaporanGenerated extends LaporanState {
  final String filePath;
  final String fileName;

  const LaporanGenerated({
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [filePath, fileName];
}

class LaporanError extends LaporanState {
  final String message;

  const LaporanError(this.message);

  @override
  List<Object?> get props => [message];
}
import 'package:equatable/equatable.dart';

enum BorrowingStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class BorrowingState extends Equatable {
  final BorrowingStatus status;
  final Map<String, dynamic>? selectedAlat;
  final DateTime? tanggalPinjam;
  final DateTime? tanggalKembali;
  final int jumlahPinjam;
  final String keperluan;
  final String? errorMessage;
  final String? successMessage;

  const BorrowingState({
    this.status = BorrowingStatus.initial,
    this.selectedAlat,
    this.tanggalPinjam,
    this.tanggalKembali,
    this.jumlahPinjam = 1,
    this.keperluan = '',
    this.errorMessage,
    this.successMessage,
  });

  BorrowingState copyWith({
    BorrowingStatus? status,
    Map<String, dynamic>? selectedAlat,
    DateTime? tanggalPinjam,
    DateTime? tanggalKembali,
    int? jumlahPinjam,
    String? keperluan,
    String? errorMessage,
    String? successMessage,
  }) {
    return BorrowingState(
      status: status ?? this.status,
      selectedAlat: selectedAlat ?? this.selectedAlat,
      tanggalPinjam: tanggalPinjam ?? this.tanggalPinjam,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      jumlahPinjam: jumlahPinjam ?? this.jumlahPinjam,
      keperluan: keperluan ?? this.keperluan,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedAlat,
        tanggalPinjam,
        tanggalKembali,
        jumlahPinjam,
        keperluan,
        errorMessage,
        successMessage,
      ];
}
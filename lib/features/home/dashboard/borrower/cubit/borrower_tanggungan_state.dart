import 'package:equatable/equatable.dart';

/// Base state untuk Tanggungan
abstract class TanggunganState extends Equatable {
  const TanggunganState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TanggunganInitial extends TanggunganState {
  const TanggunganInitial();
}

/// Loading state
class TanggunganLoading extends TanggunganState {
  const TanggunganLoading();
}

/// Loaded state dengan data tanggungan
class TanggunganLoaded extends TanggunganState {
  final List<Map<String, dynamic>> tanggunganList;
  final Map<String, dynamic> settingDenda;
  final int jumlahTerlambat;
  final Map<int, Map<String, dynamic>> dendaInfo; // id_peminjaman -> denda info

  const TanggunganLoaded({
    required this.tanggunganList,
    required this.settingDenda,
    required this.jumlahTerlambat,
    required this.dendaInfo,
  });

  @override
  List<Object?> get props => [
        tanggunganList,
        settingDenda,
        jumlahTerlambat,
        dendaInfo,
      ];

  /// Helper method untuk mendapatkan denda info untuk peminjaman tertentu
  Map<String, dynamic> getDendaForPeminjaman(int idPeminjaman) {
    return dendaInfo[idPeminjaman] ?? {
      'hari_terlambat': 0,
      'denda_per_hari': 0,
      'total_denda': 0,
    };
  }

  /// Copy with method
  TanggunganLoaded copyWith({
    List<Map<String, dynamic>>? tanggunganList,
    Map<String, dynamic>? settingDenda,
    int? jumlahTerlambat,
    Map<int, Map<String, dynamic>>? dendaInfo,
  }) {
    return TanggunganLoaded(
      tanggunganList: tanggunganList ?? this.tanggunganList,
      settingDenda: settingDenda ?? this.settingDenda,
      jumlahTerlambat: jumlahTerlambat ?? this.jumlahTerlambat,
      dendaInfo: dendaInfo ?? this.dendaInfo,
    );
  }
}

/// Error state
class TanggunganError extends TanggunganState {
  final String message;

  const TanggunganError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state - tidak ada tanggungan
class TanggunganEmpty extends TanggunganState {
  const TanggunganEmpty();
}
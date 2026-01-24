import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';
import 'borrowing_state.dart';

class BorrowingCubit extends Cubit<BorrowingState> {
  final SupabaseService _supabaseService;

  BorrowingCubit(this._supabaseService) : super(const BorrowingState());

  void selectAlat(Map<String, dynamic> alat) {
    emit(state.copyWith(
      selectedAlat: alat,
      status: BorrowingStatus.loaded,
    ));
  }

  void setTanggalPinjam(DateTime tanggal) {
    emit(state.copyWith(tanggalPinjam: tanggal));
  }

  void setTanggalKembali(DateTime tanggal) {
    emit(state.copyWith(tanggalKembali: tanggal));
  }

  void setJumlahPinjam(int jumlah) {
    emit(state.copyWith(jumlahPinjam: jumlah));
  }

  void setKeperluan(String keperluan) {
    emit(state.copyWith(keperluan: keperluan));
  }

  Future<void> submitPeminjamanFromDialog({
    required Map<String, dynamic> alat,
    required DateTime tanggalPinjam,
    required int jumlahHari,
    required int jumlahPinjam,
    required String keperluan,
  }) async {
    // Calculate tanggal kembali
    final tanggalKembali = tanggalPinjam.add(Duration(days: jumlahHari));

    // Validation
    if (jumlahPinjam < 1) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Jumlah pinjam minimal 1',
      ));
      return;
    }

    final jumlahTersedia = alat['jumlah_tersedia'] as int;
    if (jumlahPinjam > jumlahTersedia) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Jumlah melebihi stok tersedia ($jumlahTersedia)',
      ));
      return;
    }

    if (jumlahHari < 1 || jumlahHari > 7) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Durasi peminjaman 1-7 hari',
      ));
      return;
    }

    emit(state.copyWith(status: BorrowingStatus.submitting));

    try {
      // Generate kode peminjaman
      final kodePeminjaman = _generateKodePeminjaman();

      // Create peminjaman
      final userId = _supabaseService.currentUserId;
      await _supabaseService.createPeminjaman({
        'kode_peminjaman': kodePeminjaman,
        'id_user': userId,
        'id_alat': alat['id_alat'],
        'tanggal_pinjam': tanggalPinjam.toIso8601String().split('T')[0],
        'tanggal_kembali_rencana': tanggalKembali.toIso8601String().split('T')[0],
        'jumlah_pinjam': jumlahPinjam,
        'keperluan': keperluan.isNotEmpty ? keperluan : null,
        'status_peminjaman': 'diajukan',
      });

      // Log aktivitas
      await _supabaseService.createLogAktivitas(
        namaTabel: 'peminjaman',
        operasi: 'INSERT',
        dataBaru: {
          'kode_peminjaman': kodePeminjaman,
          'alat': alat['nama_alat'],
          'jumlah': jumlahPinjam,
          'durasi': '$jumlahHari hari',
        },
      );

      emit(state.copyWith(
        status: BorrowingStatus.success,
        successMessage: 'Permintaan peminjaman berhasil diajukan! Tunggu persetujuan petugas.',
      ));

      // Reset after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const BorrowingState());
    } catch (e) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Gagal mengajukan peminjaman: ${e.toString()}',
      ));
    }
  }

  Future<void> submitPeminjaman() async {
    if (state.selectedAlat == null ||
        state.tanggalPinjam == null ||
        state.tanggalKembali == null) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Lengkapi semua data peminjaman',
      ));
      return;
    }

    if (state.tanggalKembali!.isBefore(state.tanggalPinjam!)) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Tanggal kembali tidak boleh lebih awal dari tanggal pinjam',
      ));
      return;
    }

    if (state.jumlahPinjam < 1) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Jumlah pinjam minimal 1',
      ));
      return;
    }

    final jumlahTersedia = state.selectedAlat!['jumlah_tersedia'] as int;
    if (state.jumlahPinjam > jumlahTersedia) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Jumlah melebihi stok tersedia ($jumlahTersedia)',
      ));
      return;
    }

    emit(state.copyWith(status: BorrowingStatus.submitting));

    try {
      // Generate kode peminjaman
      final kodePeminjaman = _generateKodePeminjaman();

      // Create peminjaman
      final userId = _supabaseService.currentUserId;
      await _supabaseService.createPeminjaman({
        'kode_peminjaman': kodePeminjaman,
        'id_user': userId,
        'id_alat': state.selectedAlat!['id_alat'],
        'tanggal_pinjam': state.tanggalPinjam!.toIso8601String(),
        'tanggal_kembali_rencana': state.tanggalKembali!.toIso8601String(),
        'jumlah_pinjam': state.jumlahPinjam,
        'keperluan': state.keperluan.isNotEmpty ? state.keperluan : null,
        'status_peminjaman': 'diajukan',
      });

      // Log aktivitas
      await _supabaseService.createLogAktivitas(
        namaTabel: 'peminjaman',
        operasi: 'INSERT',
        dataBaru: {
          'kode_peminjaman': kodePeminjaman,
          'alat': state.selectedAlat!['nama_alat'],
          'jumlah': state.jumlahPinjam,
        },
      );

      emit(state.copyWith(
        status: BorrowingStatus.success,
        successMessage: 'Permintaan peminjaman berhasil diajukan',
      ));

      // Reset form after success
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const BorrowingState());
    } catch (e) {
      emit(state.copyWith(
        status: BorrowingStatus.error,
        errorMessage: 'Gagal mengajukan peminjaman: ${e.toString()}',
      ));
    }
  }

  String _generateKodePeminjaman() {
    final now = DateTime.now();
    final uuid = const Uuid().v4().substring(0, 8).toUpperCase();
    return 'PJM-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$uuid';
  }

  void reset() {
    emit(const BorrowingState());
  }
}
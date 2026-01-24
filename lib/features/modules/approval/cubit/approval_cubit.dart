import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/supabase_service.dart';
import 'approval_state.dart';

class ApprovalCubit extends Cubit<ApprovalState> {
  final SupabaseService _supabaseService;

  ApprovalCubit(this._supabaseService) : super(const ApprovalState());

  Future<void> loadPendingRequests() async {
    emit(state.copyWith(status: ApprovalStatus.loading));

    try {
      final pendingList = await _supabaseService.getPeminjaman(status: 'diajukan');

      emit(state.copyWith(
        status: ApprovalStatus.loaded,
        pendingList: pendingList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApprovalStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> approvePeminjaman({
    required int idPeminjaman,
    required int idAlat,
    required int jumlahPinjam,
    String? tanggalPinjam,
    String? catatan,
  }) async {
    emit(state.copyWith(status: ApprovalStatus.processing));

    try {
      // Get current alat data
      final alat = await _supabaseService.getAlatById(idAlat);
      final jumlahTersedia = alat['jumlah_tersedia'] as int;

      // Check if enough stock
      if (jumlahPinjam > jumlahTersedia) {
        emit(state.copyWith(
          status: ApprovalStatus.error,
          errorMessage: 'Stok tidak mencukupi (tersedia: $jumlahTersedia)',
        ));
        return;
      }

      // Waktu sekarang untuk tanggal mulai pinjam
      final now = DateTime.now();
      final tanggalMulaiPinjam = tanggalPinjam ?? now.toIso8601String();

      // Update status peminjaman to "dipinjam" dengan waktu mulai pinjam = sekarang
      await _supabaseService.updatePeminjaman(
        idPeminjaman: idPeminjaman,
        data: {
          'status_peminjaman': 'dipinjam',
          'tanggal_pinjam': tanggalMulaiPinjam.split('T')[0], // YYYY-MM-DD format
          'waktu_mulai_pinjam': now.toIso8601String(), // Full datetime
          'catatan_admin': catatan,
          'updated_at': now.toIso8601String(),
        },
      );

      // Reduce stock alat
      final newJumlahTersedia = jumlahTersedia - jumlahPinjam;
      
      // Status alat menjadi 'dipinjam' jika stok habis, 'tersedia' jika masih ada
      final newStatus = newJumlahTersedia == 0 ? 'dipinjam' : 'tersedia';

      await _supabaseService.updateAlat(
        idAlat: idAlat,
        data: {
          'jumlah_tersedia': newJumlahTersedia,
          'status': newStatus,
          'updated_at': now.toIso8601String(),
        },
      );

      // Log aktivitas
      await _supabaseService.createLogAktivitas(
        namaTabel: 'peminjaman',
        operasi: 'APPROVE',
        idRecord: idPeminjaman,
        dataBaru: {
          'action': 'approve',
          'status': 'dipinjam',
          'alat': alat['nama_alat'],
          'jumlah': jumlahPinjam,
          'stok_tersisa': newJumlahTersedia,
          'waktu_mulai': now.toIso8601String(),
        },
      );

      emit(state.copyWith(
        status: ApprovalStatus.success,
        successMessage: 'Peminjaman berhasil disetujui. Stok tersisa: $newJumlahTersedia',
      ));

      // Reload pending list - akan otomatis hilang karena status sudah 'dipinjam'
      await Future.delayed(const Duration(milliseconds: 300));
      await loadPendingRequests();
    } catch (e) {
      emit(state.copyWith(
        status: ApprovalStatus.error,
        errorMessage: 'Gagal menyetujui: ${e.toString()}',
      ));
    }
  }

  Future<void> rejectPeminjaman({
    required int idPeminjaman,
    required String alasan,
  }) async {
    if (alasan.trim().isEmpty) {
      emit(state.copyWith(
        status: ApprovalStatus.error,
        errorMessage: 'Alasan penolakan harus diisi',
      ));
      return;
    }

    emit(state.copyWith(status: ApprovalStatus.processing));

    try {
      final now = DateTime.now();

      // Update status peminjaman to "ditolak"
      await _supabaseService.updatePeminjaman(
        idPeminjaman: idPeminjaman,
        data: {
          'status_peminjaman': 'ditolak',
          'catatan_admin': alasan,
          'updated_at': now.toIso8601String(),
        },
      );

      // Log aktivitas
      await _supabaseService.createLogAktivitas(
        namaTabel: 'peminjaman',
        operasi: 'REJECT',
        idRecord: idPeminjaman,
        dataBaru: {
          'action': 'reject',
          'status': 'ditolak',
          'alasan': alasan,
        },
      );

      emit(state.copyWith(
        status: ApprovalStatus.success,
        successMessage: 'Peminjaman berhasil ditolak',
      ));

      // Reload pending list - akan otomatis hilang karena status sudah 'ditolak'
      await Future.delayed(const Duration(milliseconds: 300));
      await loadPendingRequests();
    } catch (e) {
      emit(state.copyWith(
        status: ApprovalStatus.error,
        errorMessage: 'Gagal menolak: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    await loadPendingRequests();
  }
}
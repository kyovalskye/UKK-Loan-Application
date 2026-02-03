import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/model/peminjaman_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_peminjaman_state.dart';

class CrudPeminjamanCubit extends Cubit<CrudPeminjamanState> {
  final _supabase = Supabase.instance.client;

  CrudPeminjamanCubit() : super(CrudPeminjamanInitial());

  // Tambahkan method untuk get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final res = await _supabase
          .from('users')
          .select('role')
          .eq('user_id', userId)
          .single();

      return res['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchPeminjaman({String? statusFilter}) async {
    emit(CrudPeminjamanLoading());
    try {
      var query = _supabase.from('peminjaman').select('''
          id_peminjaman,
          kode_peminjaman,
          tanggal_pinjam,
          tanggal_kembali_rencana,
          tanggal_kembali_actual,
          jumlah_pinjam,
          keperluan,
          status_peminjaman,
          catatan_admin,
          users!peminjaman_id_user_fkey(user_id, nama, email),
          alat!peminjaman_id_alat_fkey(id_alat, nama_alat, kategori!alat_id_kategori_fkey(nama))
        ''');

      if (statusFilter != null && statusFilter != 'Semua') {
        query = query.eq('status_peminjaman', statusFilter.toLowerCase());
      }

      final res = await query.order('created_at', ascending: false);
      final data = (res as List).map((e) => PeminjamanModel.fromMap(e)).toList();

      emit(CrudPeminjamanLoaded(data));
    } catch (e) {
      emit(CrudPeminjamanError(e.toString()));
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final res = await _supabase
          .from('users')
          .select('user_id, nama, email')
          .order('nama');

      return (res as List).map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AlatModel>> fetchAlat() async {
    try {
      final res = await _supabase
          .from('alat')
          .select('id_alat, nama_alat, jumlah_total')
          .gt('jumlah_total', 0)
          .order('nama_alat');

      if (res.isEmpty) {
        print('⚠️ Tidak ada data alat di database');
      } else {
        print('✅ Berhasil fetch ${(res as List).length} alat');
      }

      return (res as List).map((e) => AlatModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ Error fetch alat: $e');
      return [];
    }
  }

  Future<int> getjumlah_totalAlat(int idAlat) async {
    try {
      final res = await _supabase
          .from('alat')
          .select('jumlah_total')
          .eq('id_alat', idAlat)
          .single();

      return res['jumlah_total'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> addPeminjaman({
    required String idUser,
    required int idAlat,
    required String tanggalPinjam,
    required String tanggalKembali,
    required int jumlah,
    String? keperluan,
  }) async {
    try {
      // Validasi jumlah_total
      final jumlah_total = await getjumlah_totalAlat(idAlat);
      if (jumlah > jumlah_total) {
        emit(CrudPeminjamanError('Jumlah melebihi jumlah_total tersedia ($jumlah_total)'));
        return;
      }

      final now = DateTime.now();
      final kode = 'PMJ-${now.year}-${now.millisecondsSinceEpoch % 10000}';

      await _supabase.from('peminjaman').insert({
        'kode_peminjaman': kode,
        'id_user': idUser,
        'id_alat': idAlat,
        'tanggal_pinjam': tanggalPinjam,
        'tanggal_kembali_rencana': tanggalKembali,
        'jumlah_pinjam': jumlah,
        'keperluan': keperluan ?? '',
        'status_peminjaman': 'diajukan',
      });

      await fetchPeminjaman();
      emit(const CrudPeminjamanSuccess('Peminjaman berhasil ditambahkan'));
    } catch (e) {
      emit(CrudPeminjamanError(e.toString()));
    }
  }

  Future<void> updatePeminjaman({
    required int id,
    required String idUser,
    required int idAlat,
    required String tanggalPinjam,
    required String tanggalKembali,
    required int jumlah,
    String? keperluan,
  }) async {
    try {
      // Validasi jumlah_total
      final jumlah_total = await getjumlah_totalAlat(idAlat);
      if (jumlah > jumlah_total) {
        emit(CrudPeminjamanError('Jumlah melebihi jumlah_total tersedia ($jumlah_total)'));
        return;
      }

      // Admin tidak bisa mengubah status dan catatan admin
      await _supabase.from('peminjaman').update({
        'id_user': idUser,
        'id_alat': idAlat,
        'tanggal_pinjam': tanggalPinjam,
        'tanggal_kembali_rencana': tanggalKembali,
        'jumlah_pinjam': jumlah,
        'keperluan': keperluan ?? '',
        // TIDAK ada status_peminjaman dan catatan_admin di sini
      }).eq('id_peminjaman', id);

      await fetchPeminjaman();
      emit(const CrudPeminjamanSuccess('Peminjaman berhasil diupdate'));
    } catch (e) {
      emit(CrudPeminjamanError(e.toString()));
    }
  }

  Future<void> approvePeminjaman({
    required int id,
    required bool approve,
    String? catatan,
  }) async {
    try {
      // Cek apakah user adalah petugas
      final role = await getCurrentUserRole();
      if (role != 'petugas') {
        emit(const CrudPeminjamanError('Hanya petugas yang bisa menyetujui/menolak peminjaman'));
        return;
      }

      await _supabase.from('peminjaman').update({
        'status_peminjaman': approve ? 'disetujui' : 'ditolak',
        'catatan_admin': catatan,
      }).eq('id_peminjaman', id);

      await fetchPeminjaman();
      emit(CrudPeminjamanSuccess(
        approve ? 'Peminjaman disetujui' : 'Peminjaman ditolak',
      ));
    } catch (e) {
      emit(CrudPeminjamanError(e.toString()));
    }
  }

  Future<void> deletePeminjaman(int id) async {
    try {
      await _supabase.from('peminjaman').delete().eq('id_peminjaman', id);
      await fetchPeminjaman();
      emit(const CrudPeminjamanSuccess('Peminjaman berhasil dihapus'));
    } catch (e) {
      emit(CrudPeminjamanError(e.toString()));
    }
  }
}
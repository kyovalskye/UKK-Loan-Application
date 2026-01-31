// crud_alat_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_alat_state.dart';

class CrudAlatCubit extends Cubit<CrudAlatState> {
  final _supabase = Supabase.instance.client;

  CrudAlatCubit() : super(CrudAlatInitial());

  Future<void> loadAlat() async {
    emit(CrudAlatLoading());
    try {
      final response = await _supabase
          .from('alat')
          .select()
          .order('created_at', ascending: false);

      emit(CrudAlatLoaded(List<Map<String, dynamic>>.from(response)));
    } catch (e) {
      emit(CrudAlatError('Error loading alat: ${e.toString()}'));
    }
  }

  Future<void> createAlat({
    required String namaAlat,
    required String kategori,
    required String kondisi,
    required String status,
    required int jumlahTotal,
    String? fotoAlat,
  }) async {
    try {
      // Validasi input
      if (namaAlat.trim().isEmpty) {
        emit(const CrudAlatError('Nama alat tidak boleh kosong'));
        return;
      }

      if (kategori.trim().isEmpty) {
        emit(const CrudAlatError('Kategori tidak boleh kosong'));
        return;
      }

      if (jumlahTotal < 1) {
        emit(const CrudAlatError('Jumlah total minimal 1'));
        return;
      }

      // Insert ke database
      await _supabase.from('alat').insert({
        'nama_alat': namaAlat.trim(),
        'kategori': kategori.trim(),
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': jumlahTotal, // Default sama dengan jumlah total
        'foto_alat': fotoAlat,
      });

      emit(const CrudAlatSuccess('Alat berhasil ditambahkan'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError('Error creating alat: ${e.toString()}'));
    }
  }

  Future<void> updateAlat({
    required int idAlat,
    required String namaAlat,
    required String kategori,
    required String kondisi,
    required String status,
    required int jumlahTotal,
    int? jumlahTersedia,
    String? fotoAlat,
  }) async {
    try {
      // Validasi input
      if (namaAlat.trim().isEmpty) {
        emit(const CrudAlatError('Nama alat tidak boleh kosong'));
        return;
      }

      if (kategori.trim().isEmpty) {
        emit(const CrudAlatError('Kategori tidak boleh kosong'));
        return;
      }

      if (jumlahTotal < 1) {
        emit(const CrudAlatError('Jumlah total minimal 1'));
        return;
      }

      // Jika jumlah tersedia tidak di-set, gunakan nilai dari jumlah total
      final tersedia = jumlahTersedia ?? jumlahTotal;

      // Validasi jumlah tersedia tidak melebihi total
      if (tersedia > jumlahTotal) {
        emit(const CrudAlatError('Jumlah tersedia tidak boleh melebihi jumlah total'));
        return;
      }

      // Update database
      await _supabase.from('alat').update({
        'nama_alat': namaAlat.trim(),
        'kategori': kategori.trim(),
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': tersedia,
        'foto_alat': fotoAlat,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);

      emit(const CrudAlatSuccess('Alat berhasil diupdate'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError('Error updating alat: ${e.toString()}'));
    }
  }

  Future<void> deleteAlat(int idAlat) async {
    try {
      // Cek apakah alat sedang dipinjam
    final peminjaman = await _supabase
        .from('peminjaman')
        .select()
        .eq('id_alat', idAlat)
        .filter('status_peminjaman', 'in', '("diajukan","disetujui","dipinjam")');

      if (peminjaman.isNotEmpty) {
        emit(const CrudAlatError(
            'Tidak dapat menghapus alat yang sedang dalam peminjaman'));
        return;
      }

      // Delete dari database
      await _supabase.from('alat').delete().eq('id_alat', idAlat);

      emit(const CrudAlatSuccess('Alat berhasil dihapus'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError('Error deleting alat: ${e.toString()}'));
    }
  }

  // Method untuk filter alat berdasarkan status dan kategori
  List<Map<String, dynamic>> filterAlat({
    required List<Map<String, dynamic>> alatList,
    String? status,
    String? kategori,
    String? searchQuery,
  }) {
    return alatList.where((alat) {
      // Filter search
      final matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          alat['nama_alat']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          alat['kategori']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      // Filter status
      final matchesStatus = status == null ||
          status == 'Semua' ||
          alat['status'].toString().toLowerCase() == status.toLowerCase();

      // Filter kategori
      final matchesKategori = kategori == null ||
          kategori == 'Semua' ||
          alat['kategori'].toString() == kategori;

      return matchesSearch && matchesStatus && matchesKategori;
    }).toList();
  }
}
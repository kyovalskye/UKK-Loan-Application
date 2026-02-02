import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/alat_image_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_alat_state.dart';

class CrudAlatCubit extends Cubit<CrudAlatState> {
  final _supabase = Supabase.instance.client;

  CrudAlatCubit() : super(CrudAlatInitial());

  Future<void> loadAlat() async {
    emit(CrudAlatLoading());
    try {
      final res = await _supabase
          .from('alat')
          .select()
          .order('created_at', ascending: false);

      emit(CrudAlatLoaded(List<Map<String, dynamic>>.from(res)));
    } catch (e) {
      emit(CrudAlatError(e.toString()));
    }
  }

  Future<void> createAlat({
    required String namaAlat,
    required String kategori,
    required String kondisi,
    required String status,
    required int jumlahTotal,
    Uint8List? fotoBytes,
    String? fotoName,
  }) async {
    try {
      String? fotoUrl;

      if (fotoBytes != null && fotoName != null) {
        fotoUrl = await AlatImageService.upload(
          bytes: fotoBytes,
          fileName: fotoName,
        );
      }

      await _supabase.from('alat').insert({
        'nama_alat': namaAlat.trim(),
        'kategori': kategori.trim(),
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': jumlahTotal,
        'foto_alat': fotoUrl,
      });

      emit(const CrudAlatSuccess('Alat berhasil ditambahkan'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
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
    Uint8List? fotoBytes,
    String? fotoName,
  }) async {
    try {
      String? fotoUrl;

      if (fotoBytes != null && fotoName != null) {
        fotoUrl = await AlatImageService.upload(
          bytes: fotoBytes,
          fileName: fotoName,
        );
      }

      await _supabase.from('alat').update({
        'nama_alat': namaAlat.trim(),
        'kategori': kategori.trim(),
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': jumlahTersedia ?? jumlahTotal,
        if (fotoUrl != null) 'foto_alat': fotoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);

      emit(const CrudAlatSuccess('Alat berhasil diupdate'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
    }
  }

  Future<void> deleteAlat(int idAlat) async {
    try {
      final peminjaman = await _supabase
          .from('peminjaman')
          .select()
          .eq('id_alat', idAlat)
          .filter('status_peminjaman',
              'in', '("diajukan","disetujui","dipinjam")');

      if (peminjaman.isNotEmpty) {
        emit(const CrudAlatError(
            'Tidak dapat menghapus alat yang sedang dipinjam'));
        return;
      }

      await _supabase.from('alat').delete().eq('id_alat', idAlat);
      emit(const CrudAlatSuccess('Alat berhasil dihapus'));
      await loadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
    }
  }

  List<Map<String, dynamic>> filterAlat({
    required List<Map<String, dynamic>> alatList,
    String? status,
    String? kategori,
    String? searchQuery,
  }) {
    return alatList.where((alat) {
      final search = searchQuery == null ||
          searchQuery.isEmpty ||
          alat['nama_alat']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final st = status == null ||
          status == 'Semua' ||
          alat['status'] == status.toLowerCase();

      final kat =
          kategori == null || kategori == 'Semua' || alat['kategori'] == kategori;

      return search && st && kat;
    }).toList();
  }
}

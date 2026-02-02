import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_kategori_state.dart';

class CrudKategoriCubit extends Cubit<CrudKategoriState> {
  final _supabase = Supabase.instance.client;

  CrudKategoriCubit() : super(CrudKategoriInitial());

  Future<void> fetchKategori() async {
    emit(CrudKategoriLoading());
    try {
      // Fetch kategori
      final kategoriRes = await _supabase
          .from('kategori')
          .select('id_kategori, nama, deskripsi')
          .order('created_at');

      // Fetch semua alat untuk hitung count per kategori
      final alatRes = await _supabase
          .from('alat')
          .select('id_kategori');

      // Hitung jumlah alat per kategori
      final countMap = <int, int>{};
      for (final row in alatRes) {
        final idKategori = row['id_kategori'];
        if (idKategori != null) {
          countMap[idKategori as int] = (countMap[idKategori] ?? 0) + 1;
        }
      }

      final data = kategoriRes.map((e) {
        final id = e['id_kategori'] as int;
        return {
          'id': id,
          'nama': e['nama'],
          'deskripsi': e['deskripsi'],
          'jumlah_alat': countMap[id] ?? 0,
        };
      }).toList();

      emit(CrudKategoriLoaded(List<Map<String, dynamic>>.from(data)));
    } catch (e) {
      emit(CrudKategoriError(e.toString()));
    }
  }

  Future<void> addKategori({
    required String nama,
    required String deskripsi,
  }) async {
    try {
      await _supabase.from('kategori').insert({
        'nama': nama,
        'deskripsi': deskripsi,
      });
      await fetchKategori();
      emit(const CrudKategoriSuccess('Kategori ditambahkan'));
    } catch (e) {
      emit(CrudKategoriError(e.toString()));
    }
  }

  Future<void> updateKategori({
    required int id,
    required String nama,
    required String deskripsi,
  }) async {
    try {
      await _supabase.from('kategori').update({
        'nama': nama,
        'deskripsi': deskripsi,
      }).eq('id_kategori', id);

      await fetchKategori();
      emit(const CrudKategoriSuccess('Kategori diupdate'));
    } catch (e) {
      emit(CrudKategoriError(e.toString()));
    }
  }

  Future<void> deleteKategori(int id) async {
    try {
      await _supabase.from('kategori').delete().eq('id_kategori', id);
      await fetchKategori();
      emit(const CrudKategoriSuccess('Kategori dihapus'));
    } catch (e) {
      emit(CrudKategoriError(e.toString()));
    }
  }
}
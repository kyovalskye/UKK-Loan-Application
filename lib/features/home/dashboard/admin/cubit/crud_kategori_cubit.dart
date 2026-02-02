import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_kategori_state.dart';

class CrudKategoriCubit extends Cubit<CrudKategoriState> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _kategoriChannel;
  RealtimeChannel? _alatChannel;

  CrudKategoriCubit() : super(CrudKategoriInitial());

  /// ✅ Subscribe ke realtime channel untuk tabel kategori dan alat
  void subscribeToRealtime() {
    // Subscribe ke perubahan tabel kategori
    _kategoriChannel = _supabase
        .channel('public:kategori')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kategori',
          callback: (payload) {
            print('🔥 Kategori changed: ${payload.eventType}');
            // Langsung fetch tanpa delay
            fetchKategori();
          },
        )
        .subscribe();

    // Subscribe ke perubahan tabel alat (untuk update jumlah_alat)
    _alatChannel = _supabase
        .channel('public:alat')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alat',
          callback: (payload) {
            print('🔥 Alat changed: ${payload.eventType}');
            fetchKategori();
          },
        )
        .subscribe();
  }

  /// ✅ Unsubscribe saat cubit di-dispose
  @override
  Future<void> close() {
    _kategoriChannel?.unsubscribe();
    _alatChannel?.unsubscribe();
    return super.close();
  }

  /// ✅ Fetch kategori - PENTING: jangan emit Loading kalau sudah ada data
  Future<void> fetchKategori({bool showLoading = true}) async {
    // Hanya show loading jika belum ada data atau diminta
    if (showLoading && state is! CrudKategoriLoaded) {
      emit(CrudKategoriLoading());
    }
    
    try {
      // Fetch kategori
      final kategoriRes = await _supabase
          .from('kategori')
          .select('id_kategori, nama, deskripsi, created_at')
          .order('created_at');

      // Fetch semua alat untuk hitung count per kategori
      final alatRes = await _supabase.from('alat').select('id_kategori');

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

      print('✅ Fetched ${data.length} kategori');
      emit(CrudKategoriLoaded(List<Map<String, dynamic>>.from(data)));
    } catch (e) {
      print('❌ Error fetching kategori: $e');
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
      
      print('✅ Kategori added, waiting for realtime...');
      
      // ✅ Emit success message (akan ditangkap listener untuk snackbar)
      emit(const CrudKategoriSuccess('Kategori ditambahkan'));
      
      // ✅ Langsung fetch ulang sebagai backup kalau realtime lambat
      await Future.delayed(const Duration(milliseconds: 300));
      await fetchKategori(showLoading: false);
      
    } catch (e) {
      print('❌ Error adding kategori: $e');
      emit(CrudKategoriError(e.toString()));
      // Reload data untuk kembali ke state loaded
      await fetchKategori(showLoading: false);
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

      print('✅ Kategori updated, waiting for realtime...');
      
      emit(const CrudKategoriSuccess('Kategori diupdate'));
      
      // Backup fetch
      await Future.delayed(const Duration(milliseconds: 300));
      await fetchKategori(showLoading: false);
      
    } catch (e) {
      print('❌ Error updating kategori: $e');
      emit(CrudKategoriError(e.toString()));
      await fetchKategori(showLoading: false);
    }
  }

  Future<void> deleteKategori(int id) async {
    try {
      await _supabase.from('kategori').delete().eq('id_kategori', id);
      
      print('✅ Kategori deleted, waiting for realtime...');
      
      emit(const CrudKategoriSuccess('Kategori dihapus'));
      
      // Backup fetch
      await Future.delayed(const Duration(milliseconds: 300));
      await fetchKategori(showLoading: false);
      
    } catch (e) {
      print('❌ Error deleting kategori: $e');
      emit(CrudKategoriError(e.toString()));
      await fetchKategori(showLoading: false);
    }
  }
}
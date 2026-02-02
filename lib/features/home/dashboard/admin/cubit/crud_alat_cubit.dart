import 'dart:async';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/alat_image_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_alat_state.dart';

class CrudAlatCubit extends Cubit<CrudAlatState> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _alatChannel;
  RealtimeChannel? _kategoriChannel;
  Timer? _debounceTimer;

  CrudAlatCubit() : super(CrudAlatInitial()) {
    _initRealtimeSubscription();
    loadAlat();
  }

  void _initRealtimeSubscription() {
    // Subscribe to alat table changes
    _alatChannel = _supabase
        .channel('alat-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alat',
          callback: (payload) {
            // Debounce untuk menghindari multiple refresh
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              _silentLoadAlat();
            });
          },
        )
        .subscribe();

    // Subscribe to kategori table changes
    _kategoriChannel = _supabase
        .channel('kategori-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kategori',
          callback: (payload) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              _silentLoadAlat();
            });
          },
        )
        .subscribe();
  }

  // Initial load dengan loading state
  Future<void> loadAlat() async {
    emit(CrudAlatLoading());

    try {
      // Load both alat and kategori
      final alatRes = await _supabase
          .from('alat')
          .select('*, kategori(*)')
          .order('created_at', ascending: false);

      final kategoriRes = await _supabase
          .from('kategori')
          .select()
          .order('nama', ascending: true);

      emit(CrudAlatLoaded(
        List<Map<String, dynamic>>.from(alatRes),
        kategoriList: List<Map<String, dynamic>>.from(kategoriRes),
      ));
    } catch (e) {
      emit(CrudAlatError(e.toString()));
    }
  }

  // Silent load untuk refresh tanpa loading state
  Future<void> _silentLoadAlat() async {
    try {
      // Load both alat and kategori
      final alatRes = await _supabase
          .from('alat')
          .select('*, kategori(*)')
          .order('created_at', ascending: false);

      final kategoriRes = await _supabase
          .from('kategori')
          .select()
          .order('nama', ascending: true);

      // Emit loaded state langsung tanpa loading
      emit(CrudAlatLoaded(
        List<Map<String, dynamic>>.from(alatRes),
        kategoriList: List<Map<String, dynamic>>.from(kategoriRes),
      ));
    } catch (e) {
      // Silent error, tidak emit error state
      print('Error silent load: $e');
    }
  }

  Future<void> createAlat({
    required String namaAlat,
    required int idKategori,
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
        'id_kategori': idKategori,
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': jumlahTotal,
        'foto_alat': fotoUrl,
      });

      emit(const CrudAlatSuccess('Alat berhasil ditambahkan'));
      
      // Langsung silent load tanpa delay
      await _silentLoadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
      await _silentLoadAlat();
    }
  }

  Future<void> updateAlat({
    required int idAlat,
    required String namaAlat,
    required int idKategori,
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
        'id_kategori': idKategori,
        'kondisi': kondisi,
        'status': status,
        'jumlah_total': jumlahTotal,
        'jumlah_tersedia': jumlahTersedia ?? jumlahTotal,
        if (fotoUrl != null) 'foto_alat': fotoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);

      emit(const CrudAlatSuccess('Alat berhasil diupdate'));
      
      // Langsung silent load tanpa delay
      await _silentLoadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
      await _silentLoadAlat();
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
      
      // Langsung silent load tanpa delay
      await _silentLoadAlat();
    } catch (e) {
      emit(CrudAlatError(e.toString()));
      await _silentLoadAlat();
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

      final kat = kategori == null ||
          kategori == 'Semua' ||
          (alat['kategori'] != null &&
              alat['kategori']['nama'] == kategori);

      return search && st && kat;
    }).toList();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _alatChannel?.unsubscribe();
    _kategoriChannel?.unsubscribe();
    return super.close();
  }
}
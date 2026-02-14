import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_log_aktivitas_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasCubit extends Cubit<LogAktivitasState> {
  final _supabase = Supabase.instance.client;

  LogAktivitasCubit() : super(LogAktivitasInitial());

  // SOLUSI 1: Untuk Supabase v2.x (Recommended)
  Future<void> loadLogs({
    String tableFilter = 'Semua',
    String operasiFilter = 'Semua',
  }) async {
    try {
      print('\n🔍 LoadLogs called:');
      print('   Table Filter: $tableFilter');
      print('   Operasi Filter: $operasiFilter');

      emit(LogAktivitasLoading());

      // Build base query
      var baseQuery = _supabase.from('log_aktivitas');
      
      // Apply filters menggunakan chaining
      var filteredQuery = baseQuery.select('''
            *,
            users:user_id (
              user_id,
              nama,
              email
            )
          ''');

      // Apply table filter jika bukan 'Semua'
      if (tableFilter != 'Semua') {
        filteredQuery = filteredQuery.eq('nama_tabel', tableFilter.toLowerCase());
      }

      // Apply operasi filter jika bukan 'Semua'
      if (operasiFilter != 'Semua') {
        filteredQuery = filteredQuery.eq('operasi', operasiFilter);
      }

      // Execute query dengan order
      final response = await filteredQuery.order('waktu_operasi', ascending: false);

      final logs = (response as List).cast<Map<String, dynamic>>();

      print('✅ Logs loaded: ${logs.length} records');

      emit(LogAktivitasLoaded(
        logs: logs,
        tableFilter: tableFilter,
        operasiFilter: operasiFilter,
      ));
    } catch (e, stackTrace) {
      print('❌ Error loading logs: $e');
      print('Stack trace: $stackTrace');
      
      // Jika error, coba metode alternatif
      await _loadLogsAlternative(tableFilter, operasiFilter);
    }
  }

  // SOLUSI 2: Metode alternatif tanpa chaining
  Future<void> _loadLogsAlternative(
    String tableFilter,
    String operasiFilter,
  ) async {
    try {
      print('🔄 Trying alternative query method...');
      
      // Query tanpa filter dulu
      final response = await _supabase.from('log_aktivitas').select('''
            *,
            users:user_id (
              user_id,
              nama,
              email
            )
          ''').order('waktu_operasi', ascending: false);

      var logs = (response as List).cast<Map<String, dynamic>>();

      // Filter di Dart
      if (tableFilter != 'Semua') {
        logs = logs.where((log) => 
          log['nama_tabel'] == tableFilter.toLowerCase()
        ).toList();
      }

      if (operasiFilter != 'Semua') {
        logs = logs.where((log) => 
          log['operasi'] == operasiFilter
        ).toList();
      }

      print('✅ Logs loaded (alternative): ${logs.length} records');

      emit(LogAktivitasLoaded(
        logs: logs,
        tableFilter: tableFilter,
        operasiFilter: operasiFilter,
      ));
    } catch (e, stackTrace) {
      print('❌ Error in alternative method: $e');
      print('Stack trace: $stackTrace');
      emit(LogAktivitasError('Gagal memuat log aktivitas: ${e.toString()}'));
    }
  }

  // Filter by table
  Future<void> filterByTable(String tableFilter, String currentOperasiFilter) async {
    await loadLogs(
      tableFilter: tableFilter,
      operasiFilter: currentOperasiFilter,
    );
  }

  // Filter by operasi
  Future<void> filterByOperasi(String operasiFilter, String currentTableFilter) async {
    await loadLogs(
      tableFilter: currentTableFilter,
      operasiFilter: operasiFilter,
    );
  }

  // Refresh logs
  Future<void> refreshLogs({
    String tableFilter = 'Semua',
    String operasiFilter = 'Semua',
  }) async {
    await loadLogs(
      tableFilter: tableFilter,
      operasiFilter: operasiFilter,
    );
  }
}
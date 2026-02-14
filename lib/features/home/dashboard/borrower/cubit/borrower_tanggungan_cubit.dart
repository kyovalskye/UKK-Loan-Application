import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/peminjaman_service.dart';
import 'borrower_tanggungan_state.dart';

class TanggunganCubit extends Cubit<TanggunganState> {
  final PeminjamanService _peminjamanService;

  TanggunganCubit({required PeminjamanService peminjamanService})
    : _peminjamanService = peminjamanService,
      super(const TanggunganInitial());

  /// Load data tanggungan
  Future<void> loadTanggungan() async {
    try {
      emit(const TanggunganLoading());

      // 1. Check and update late peminjaman first
      try {
        await _peminjamanService.checkAndUpdateLatePeminjaman();
        print('✅ Check late peminjaman berhasil');
      } catch (e) {
        print('⚠️ Warning: Could not run check_and_update_late_peminjaman: $e');
        print('   Akan menggunakan fallback calculation');
      }

      // 2. Get tanggungan list
      final tanggunganList = await _peminjamanService.getTanggunganByUser();
      print('📦 Tanggungan list count: ${tanggunganList.length}');

      // 3. Get setting denda
      final settingDenda = await _peminjamanService.getSettingDenda();
      print('⚙️ Setting denda: $settingDenda');

      // 4. Jika tidak ada tanggungan, emit empty state
      if (tanggunganList.isEmpty) {
        emit(const TanggunganEmpty());
        return;
      }

      // 5. FIXED: Calculate denda dengan normalisasi tanggal
      final dendaInfo = <int, Map<String, dynamic>>{};

      // Normalisasi tanggal hari ini
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (final tanggungan in tanggunganList) {
        final idPeminjaman = tanggungan['id_peminjaman'] as int;
        final kodePeminjaman = tanggungan['kode_peminjaman'];
        final tanggalKembaliRencana = DateTime.parse(
          tanggungan['tanggal_kembali_rencana'],
        );

        // Normalisasi tanggal jatuh tempo
        final dueDate = DateTime(
          tanggalKembaliRencana.year,
          tanggalKembaliRencana.month,
          tanggalKembaliRencana.day,
        );

        print('\n🔍 Processing: $kodePeminjaman (ID: $idPeminjaman)');
        print('   Tanggal jatuh tempo: ${dueDate.toString().split(' ')[0]}');
        print('   Hari ini: ${todayDate.toString().split(' ')[0]}');

        Map<String, dynamic> denda;

        try {
          // Try to get denda from RPC
          denda = await _peminjamanService.getPeminjamanDenda(idPeminjaman);
          print('   ✅ Denda dari RPC: $denda');
        } catch (e) {
          print('   ⚠️ RPC gagal: $e');
          print('   🔄 Menggunakan fallback calculation...');

          // Fallback to local calculation dengan normalisasi tanggal
          denda = _calculateDendaLocallyNormalized(
            tanggungan,
            settingDenda,
            todayDate,
            dueDate,
          );
          print('   ✅ Denda dari fallback: $denda');
        }

        dendaInfo[idPeminjaman] = denda;

        final totalDenda = (denda['total_denda'] as num).toDouble();
        if (totalDenda > 0) {
          print('   💰 Total denda: Rp ${totalDenda.toStringAsFixed(0)}');
        }
      }

      // 6. FIXED: Count jumlah terlambat dengan normalisasi tanggal
      int jumlahTerlambat = 0;
      for (final tanggungan in tanggunganList) {
        final tanggalKembaliRencana = DateTime.parse(
          tanggungan['tanggal_kembali_rencana'],
        );
        final dueDate = DateTime(
          tanggalKembaliRencana.year,
          tanggalKembaliRencana.month,
          tanggalKembaliRencana.day,
        );

        if (todayDate.isAfter(dueDate)) {
          jumlahTerlambat++;
        }
      }

      print('\n📊 Summary:');
      print('   Total tanggungan: ${tanggunganList.length}');
      print('   Jumlah terlambat: $jumlahTerlambat');

      double totalAllDenda = 0;
      for (final denda in dendaInfo.values) {
        totalAllDenda += (denda['total_denda'] as num).toDouble();
      }
      print('   Total semua denda: Rp ${totalAllDenda.toStringAsFixed(0)}');

      // 7. Emit loaded state
      emit(
        TanggunganLoaded(
          tanggunganList: tanggunganList,
          settingDenda: settingDenda,
          jumlahTerlambat: jumlahTerlambat,
          dendaInfo: dendaInfo,
        ),
      );

      print('✅ State berhasil di-emit');
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack trace: $stackTrace');
      emit(TanggunganError('Gagal memuat data: ${e.toString()}'));
    }
  }

  /// FIXED: Calculate denda locally dengan normalisasi tanggal
  Map<String, dynamic> _calculateDendaLocallyNormalized(
    Map<String, dynamic> tanggungan,
    Map<String, dynamic> settingDenda,
    DateTime todayDate,
    DateTime dueDate,
  ) {
    // Hitung keterlambatan dengan perbandingan tanggal yang sudah dinormalisasi
    final hariTerlambat = todayDate.isAfter(dueDate)
        ? todayDate.difference(dueDate).inDays
        : 0;

    final dendaPerHari = (settingDenda['denda_per_hari'] as num).toDouble();
    final totalDenda = hariTerlambat * dendaPerHari;

    return {
      'hari_terlambat': hariTerlambat,
      'denda_per_hari': dendaPerHari,
      'total_denda': totalDenda,
    };
  }

  /// Refresh data tanggungan
  Future<void> refreshTanggungan() async {
    await loadTanggungan();
  }

  /// Get denda info untuk peminjaman tertentu
  Map<String, dynamic> getDendaInfo(int idPeminjaman) {
    final currentState = state;
    if (currentState is TanggunganLoaded) {
      return currentState.getDendaForPeminjaman(idPeminjaman);
    }
    return {'hari_terlambat': 0, 'denda_per_hari': 0, 'total_denda': 0};
  }

  /// Calculate total denda untuk semua tanggungan
  double getTotalAllDenda() {
    final currentState = state;
    if (currentState is TanggunganLoaded) {
      double total = 0;
      for (final denda in currentState.dendaInfo.values) {
        final dendaValue = denda['total_denda'];
        if (dendaValue != null) {
          total += (dendaValue as num).toDouble();
        }
      }
      print('💰 getTotalAllDenda: Rp ${total.toStringAsFixed(0)}');
      return total;
    }
    return 0;
  }

  /// FIXED: Get tanggungan yang akan jatuh tempo dalam X hari dengan normalisasi tanggal
  List<Map<String, dynamic>> getTanggunganNearDue(int days) {
    final currentState = state;
    if (currentState is TanggunganLoaded) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      return currentState.tanggunganList.where((tanggungan) {
        final tanggalKembaliRencana = DateTime.parse(
          tanggungan['tanggal_kembali_rencana'],
        );
        final dueDate = DateTime(
          tanggalKembaliRencana.year,
          tanggalKembaliRencana.month,
          tanggalKembaliRencana.day,
        );

        // Skip jika sudah terlambat
        if (todayDate.isAfter(dueDate)) return false;

        final daysUntilDue = dueDate.difference(todayDate).inDays;
        return daysUntilDue >= 0 && daysUntilDue <= days;
      }).toList();
    }
    return [];
  }

  /// FIXED: Get tanggungan yang sudah terlambat dengan normalisasi tanggal
  List<Map<String, dynamic>> getTanggunganLate() {
    final currentState = state;
    if (currentState is TanggunganLoaded) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      return currentState.tanggunganList.where((tanggungan) {
        final tanggalKembaliRencana = DateTime.parse(
          tanggungan['tanggal_kembali_rencana'],
        );
        final dueDate = DateTime(
          tanggalKembaliRencana.year,
          tanggalKembaliRencana.month,
          tanggalKembaliRencana.day,
        );

        return todayDate.isAfter(dueDate);
      }).toList();
    }
    return [];
  }
}

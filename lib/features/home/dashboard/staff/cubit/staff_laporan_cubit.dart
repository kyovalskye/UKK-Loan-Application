import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_laporan_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class LaporanCubit extends Cubit<LaporanState> {
  final _supabase = Supabase.instance.client;

  LaporanCubit() : super(LaporanInitial());

  // Load data laporan
  Future<void> loadLaporan({
    required String jenisLaporan,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('\n🔍 LoadLaporan called:');
      print('   Jenis: $jenisLaporan');
      print('   Start: ${DateFormat('yyyy-MM-dd').format(startDate)}');
      print('   End: ${DateFormat('yyyy-MM-dd').format(endDate)}');

      emit(LaporanLoading());

      List<Map<String, dynamic>> data = [];
      Map<String, dynamic> statistik = {};

      if (jenisLaporan == 'all') {
        // Load semua data
        final dataPeminjaman = await _getLaporanPeminjaman(startDate, endDate);
        final dataPengembalian = await _getLaporanPengembalian(
          startDate,
          endDate,
        );
        final dataDenda = await _getLaporanDenda(startDate, endDate);

        // Gabungkan statistik
        final statPeminjaman = _calculateStatistikPeminjaman(dataPeminjaman);
        final statPengembalian = _calculateStatistikPengembalian(
          dataPengembalian,
        );
        final statDenda = _calculateStatistikDenda(dataDenda);

        statistik = {...statPeminjaman, ...statPengembalian, ...statDenda};

        // Untuk data, gabungkan semua
        data = [...dataPeminjaman, ...dataPengembalian, ...dataDenda];
      } else if (jenisLaporan == 'peminjaman') {
        data = await _getLaporanPeminjaman(startDate, endDate);
        statistik = _calculateStatistikPeminjaman(data);
      } else if (jenisLaporan == 'pengembalian') {
        data = await _getLaporanPengembalian(startDate, endDate);
        statistik = _calculateStatistikPengembalian(data);
      } else if (jenisLaporan == 'denda') {
        data = await _getLaporanDenda(startDate, endDate);
        statistik = _calculateStatistikDenda(data);
      }

      print('✅ Data loaded: ${data.length} records');
      print('📊 Statistik: $statistik\n');

      emit(LaporanLoaded(data: data, statistik: statistik));
    } catch (e, stackTrace) {
      print('❌ Error loading laporan: $e');
      print('Stack trace: $stackTrace');
      emit(LaporanError('Gagal memuat laporan: ${e.toString()}'));
    }
  }

  // Get laporan peminjaman
  Future<List<Map<String, dynamic>>> _getLaporanPeminjaman(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Format tanggal ke YYYY-MM-DD untuk kolom tipe date
      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      print('📊 Getting laporan peminjaman from $startDateStr to $endDateStr');

      final response = await _supabase
          .from('peminjaman')
          .select('''
            *,
            alat:id_alat (
              id_alat,
              nama_alat,
              kategori:id_kategori (
                nama
              )
            ),
            users:id_user (
              user_id,
              nama,
              email
            )
          ''')
          .gte('tanggal_pinjam', startDateStr)
          .lte('tanggal_pinjam', endDateStr)
          .order('tanggal_pinjam', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>();
      print('📊 Found ${data.length} peminjaman records');

      // Jika tidak ada data, coba query tanpa filter untuk debugging
      if (data.isEmpty) {
        print('⚠️ No data found with date filter, checking total records...');
        final allResponse = await _supabase
            .from('peminjaman')
            .select('id_peminjaman, tanggal_pinjam')
            .order('tanggal_pinjam', ascending: false)
            .limit(5);
        print(
          '   Total peminjaman records (sample): ${(allResponse as List).length}',
        );
        if ((allResponse as List).isNotEmpty) {
          print(
            '   Sample dates: ${allResponse.map((e) => e['tanggal_pinjam']).toList()}',
          );
        }
      }

      return data;
    } catch (e, stackTrace) {
      print('❌ Error in _getLaporanPeminjaman: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get laporan pengembalian
  Future<List<Map<String, dynamic>>> _getLaporanPengembalian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Untuk timestamp, kita perlu include waktu juga
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(endDate.add(const Duration(days: 1)));

    print('📊 Getting laporan pengembalian from $startDateStr to $endDateStr');

    final response = await _supabase
        .from('pengembalian')
        .select('''
          *,
          peminjaman:id_peminjaman (
            kode_peminjaman,
            tanggal_pinjam,
            tanggal_kembali_rencana,
            users:id_user (
              nama,
              email
            ),
            alat:id_alat (
              nama_alat,
              kategori:id_kategori (
                nama
              )
            )
          )
        ''')
        .gte('tanggal_pengembalian', startDateStr)
        .lt('tanggal_pengembalian', endDateStr)
        .order('tanggal_pengembalian', ascending: false);

    print('📊 Found ${(response as List).length} pengembalian records');
    return (response as List).cast<Map<String, dynamic>>();
  }

  // Get laporan denda
  Future<List<Map<String, dynamic>>> _getLaporanDenda(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Untuk timestamp, kita perlu include waktu juga
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(endDate.add(const Duration(days: 1)));

    print('📊 Getting laporan denda from $startDateStr to $endDateStr');

    final response = await _supabase
        .from('pengembalian')
        .select('''
          *,
          peminjaman:id_peminjaman (
            kode_peminjaman,
            tanggal_pinjam,
            tanggal_kembali_rencana,
            users:id_user (
              nama,
              email
            ),
            alat:id_alat (
              nama_alat
            )
          )
        ''')
        .gte('tanggal_pengembalian', startDateStr)
        .lt('tanggal_pengembalian', endDateStr)
        .gt('total_denda', 0)
        .order('tanggal_pengembalian', ascending: false);

    print('📊 Found ${(response as List).length} denda records');
    return (response as List).cast<Map<String, dynamic>>();
  }

  // Calculate statistik peminjaman
  Map<String, dynamic> _calculateStatistikPeminjaman(
    List<Map<String, dynamic>> data,
  ) {
    return {
      'total': data.length,
      'diajukan': data
          .where((p) => p['status_peminjaman'] == 'diajukan')
          .length,
      'disetujui': data
          .where((p) => p['status_peminjaman'] == 'disetujui')
          .length,
      'dipinjam': data
          .where((p) => p['status_peminjaman'] == 'dipinjam')
          .length,
      'dikembalikan': data
          .where((p) => p['status_peminjaman'] == 'dikembalikan')
          .length,
      'ditolak': data.where((p) => p['status_peminjaman'] == 'ditolak').length,
      'terlambat': data
          .where((p) => p['status_peminjaman'] == 'terlambat')
          .length,
    };
  }

  // Calculate statistik pengembalian
  Map<String, dynamic> _calculateStatistikPengembalian(
    List<Map<String, dynamic>> data,
  ) {
    return {
      'total': data.length,
      'tepat_waktu': data
          .where((p) => (p['keterlambatan_hari'] ?? 0) == 0)
          .length,
      'terlambat': data.where((p) => (p['keterlambatan_hari'] ?? 0) > 0).length,
      'kondisi_baik': data
          .where((p) => p['kondisi_saat_kembali'] == 'baik')
          .length,
      'rusak': data.where((p) => p['kondisi_saat_kembali'] != 'baik').length,
    };
  }

  // Calculate statistik denda
  Map<String, dynamic> _calculateStatistikDenda(
    List<Map<String, dynamic>> data,
  ) {
    double totalDenda = 0;
    double totalDendaKeterlambatan = 0;
    double totalDendaKerusakan = 0;
    int totalLunas = 0;
    int totalBelumLunas = 0;

    for (var item in data) {
      final denda = (item['total_denda'] ?? 0).toDouble();
      final dendaKeterlambatan = (item['denda_keterlambatan'] ?? 0).toDouble();
      final dendaKerusakan = (item['denda_kerusakan'] ?? 0).toDouble();

      totalDenda += denda;
      totalDendaKeterlambatan += dendaKeterlambatan;
      totalDendaKerusakan += dendaKerusakan;

      if (item['status_pembayaran'] == 'lunas') {
        totalLunas++;
      } else {
        totalBelumLunas++;
      }
    }

    return {
      'total_transaksi': data.length,
      'total_denda': totalDenda,
      'total_denda_keterlambatan': totalDendaKeterlambatan,
      'total_denda_kerusakan': totalDendaKerusakan,
      'lunas': totalLunas,
      'belum_lunas': totalBelumLunas,
    };
  }

  // Generate and Preview PDF in Browser
  Future<void> generateAndPreviewPDF({
    required String jenisLaporan,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      emit(const LaporanGenerating('Mengambil data...'));

      // Load data first
      List<Map<String, dynamic>> data = [];
      Map<String, dynamic> statistik = {};

      if (jenisLaporan == 'all') {
        // Load semua data untuk PDF
        final dataPeminjaman = await _getLaporanPeminjaman(startDate, endDate);
        final dataPengembalian = await _getLaporanPengembalian(
          startDate,
          endDate,
        );
        final dataDenda = await _getLaporanDenda(startDate, endDate);

        // Gabungkan statistik
        final statPeminjaman = _calculateStatistikPeminjaman(dataPeminjaman);
        final statPengembalian = _calculateStatistikPengembalian(
          dataPengembalian,
        );
        final statDenda = _calculateStatistikDenda(dataDenda);

        statistik = {
          'peminjaman': statPeminjaman,
          'pengembalian': statPengembalian,
          'denda': statDenda,
        };

        data = [...dataPeminjaman, ...dataPengembalian, ...dataDenda];
      } else if (jenisLaporan == 'peminjaman') {
        data = await _getLaporanPeminjaman(startDate, endDate);
        statistik = _calculateStatistikPeminjaman(data);
      } else if (jenisLaporan == 'pengembalian') {
        data = await _getLaporanPengembalian(startDate, endDate);
        statistik = _calculateStatistikPengembalian(data);
      } else if (jenisLaporan == 'denda') {
        data = await _getLaporanDenda(startDate, endDate);
        statistik = _calculateStatistikDenda(data);
      }

      emit(const LaporanGenerating('Membuat PDF...'));

      // Create PDF
      final pdf = pw.Document();

      // Load font
      final font = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      // Add pages
      if (jenisLaporan == 'all') {
        // Generate PDF untuk semua laporan
        await _addAllPages(pdf, statistik, startDate, endDate, font, fontBold);
      } else if (jenisLaporan == 'peminjaman') {
        _addPeminjamanPages(
          pdf,
          data,
          statistik,
          startDate,
          endDate,
          font,
          fontBold,
        );
      } else if (jenisLaporan == 'pengembalian') {
        _addPengembalianPages(
          pdf,
          data,
          statistik,
          startDate,
          endDate,
          font,
          fontBold,
        );
      } else if (jenisLaporan == 'denda') {
        _addDendaPages(
          pdf,
          data,
          statistik,
          startDate,
          endDate,
          font,
          fontBold,
        );
      }

      emit(const LaporanGenerating('Membuka PDF...'));

      // OPEN PDF IN NEW BROWSER TAB
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Laporan_${jenisLaporan}_$dateStr.pdf';

      // Save PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // Create blob and open in new tab (web only)
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);

      emit(LaporanGenerated(filePath: 'browser', fileName: fileName));
    } catch (e) {
      emit(LaporanError('Gagal generate PDF: ${e.toString()}'));
    }
  }

  // Add all pages to PDF (combined report)
  Future<void> _addAllPages(
    pw.Document pdf,
    Map<String, dynamic> statistik,
    DateTime startDate,
    DateTime endDate,
    pw.Font font,
    pw.Font fontBold,
  ) async {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statPeminjaman = statistik['peminjaman'] as Map<String, dynamic>;
    final statPengembalian = statistik['pengembalian'] as Map<String, dynamic>;
    final statDenda = statistik['denda'] as Map<String, dynamic>;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.purple),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN LENGKAP PEMINJAMAN',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 24,
                    color: PdfColors.purple900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  'Dicetak: ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistik Peminjaman
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK PEMINJAMAN',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total',
                      '${statPeminjaman['total']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Dipinjam',
                      '${statPeminjaman['dipinjam']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Dikembalikan',
                      '${statPeminjaman['dikembalikan']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Terlambat',
                      '${statPeminjaman['terlambat']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Ditolak',
                      '${statPeminjaman['ditolak']}',
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(width: 100),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 15),

          // Statistik Pengembalian
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK PENGEMBALIAN',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total',
                      '${statPengembalian['total']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Tepat Waktu',
                      '${statPengembalian['tepat_waktu']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Terlambat',
                      '${statPengembalian['terlambat']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Kondisi Baik',
                      '${statPengembalian['kondisi_baik']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Rusak',
                      '${statPengembalian['rusak']}',
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(width: 100),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 15),

          // Statistik Denda
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK DENDA',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.orange900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Transaksi',
                      '${statDenda['total_transaksi']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Lunas',
                      '${statDenda['lunas']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Belum Lunas',
                      '${statDenda['belum_lunas']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Denda',
                      currencyFormat.format(statDenda['total_denda']),
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Denda Keterlambatan',
                      currencyFormat.format(
                        statDenda['total_denda_keterlambatan'],
                      ),
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Denda Kerusakan',
                      currencyFormat.format(statDenda['total_denda_kerusakan']),
                      font,
                      fontBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RINGKASAN',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Laporan ini mencakup data peminjaman, pengembalian, dan denda untuk periode yang dipilih.',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Total Peminjaman: ${statPeminjaman['total']} transaksi',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.Text(
                  '• Total Pengembalian: ${statPengembalian['total']} transaksi',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.Text(
                  '• Total Denda: ${currencyFormat.format(statDenda['total_denda'])}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add peminjaman pages to PDF
  void _addPeminjamanPages(
    pw.Document pdf,
    List<Map<String, dynamic>> data,
    Map<String, dynamic> statistik,
    DateTime startDate,
    DateTime endDate,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN PEMINJAMAN',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 24,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  'Dicetak: ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistik
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Peminjaman',
                      '${statistik['total']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Diajukan',
                      '${statistik['diajukan']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Disetujui',
                      '${statistik['disetujui']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Dipinjam',
                      '${statistik['dipinjam']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Dikembalikan',
                      '${statistik['dikembalikan']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Terlambat',
                      '${statistik['terlambat']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Text(
            'DAFTAR PEMINJAMAN',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  _buildTableCell('No', font, fontBold, isHeader: true),
                  _buildTableCell('Kode', font, fontBold, isHeader: true),
                  _buildTableCell('Peminjam', font, fontBold, isHeader: true),
                  _buildTableCell('Alat', font, fontBold, isHeader: true),
                  _buildTableCell('Tgl Pinjam', font, fontBold, isHeader: true),
                  _buildTableCell('Status', font, fontBold, isHeader: true),
                ],
              ),
              // Data rows
              ...data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}', font, fontBold),
                    _buildTableCell(
                      item['kode_peminjaman'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      item['users']?['nama'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      item['alat']?['nama_alat'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(item['tanggal_pinjam'])),
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      _formatStatus(item['status_peminjaman']),
                      font,
                      fontBold,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Add pengembalian pages to PDF
  void _addPengembalianPages(
    pw.Document pdf,
    List<Map<String, dynamic>> data,
    Map<String, dynamic> statistik,
    DateTime startDate,
    DateTime endDate,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.green),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN PENGEMBALIAN',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 24,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  'Dicetak: ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistik
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Pengembalian',
                      '${statistik['total']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Tepat Waktu',
                      '${statistik['tepat_waktu']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Terlambat',
                      '${statistik['terlambat']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Kondisi Baik',
                      '${statistik['kondisi_baik']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Rusak',
                      '${statistik['rusak']}',
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(width: 100),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Text(
            'DAFTAR PENGEMBALIAN',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FixedColumnWidth(25),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.2),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  _buildTableCell('No', font, fontBold, isHeader: true),
                  _buildTableCell('Kode', font, fontBold, isHeader: true),
                  _buildTableCell('Peminjam', font, fontBold, isHeader: true),
                  _buildTableCell('Alat', font, fontBold, isHeader: true),
                  _buildTableCell(
                    'Tgl Kembali',
                    font,
                    fontBold,
                    isHeader: true,
                  ),
                  _buildTableCell('Kondisi', font, fontBold, isHeader: true),
                ],
              ),
              // Data rows
              ...data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final peminjaman = item['peminjaman'] as Map<String, dynamic>?;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}', font, fontBold),
                    _buildTableCell(
                      peminjaman?['kode_peminjaman'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      peminjaman?['users']?['nama'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      peminjaman?['alat']?['nama_alat'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(item['tanggal_pengembalian'])),
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      _formatKondisi(item['kondisi_saat_kembali']),
                      font,
                      fontBold,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Add denda pages to PDF
  void _addDendaPages(
    pw.Document pdf,
    List<Map<String, dynamic>> data,
    Map<String, dynamic> statistik,
    DateTime startDate,
    DateTime endDate,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.orange),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN DENDA',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 24,
                    color: PdfColors.orange900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  'Dicetak: ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistik
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATISTIK',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Transaksi',
                      '${statistik['total_transaksi']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Lunas',
                      '${statistik['lunas']}',
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Belum Lunas',
                      '${statistik['belum_lunas']}',
                      font,
                      fontBold,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Total Denda',
                      currencyFormat.format(statistik['total_denda']),
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Denda Keterlambatan',
                      currencyFormat.format(
                        statistik['total_denda_keterlambatan'],
                      ),
                      font,
                      fontBold,
                    ),
                    _buildStatItem(
                      'Denda Kerusakan',
                      currencyFormat.format(statistik['total_denda_kerusakan']),
                      font,
                      fontBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Text(
            'DAFTAR DENDA',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FixedColumnWidth(25),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange100),
                children: [
                  _buildTableCell('No', font, fontBold, isHeader: true),
                  _buildTableCell('Kode', font, fontBold, isHeader: true),
                  _buildTableCell('Peminjam', font, fontBold, isHeader: true),
                  _buildTableCell('Alat', font, fontBold, isHeader: true),
                  _buildTableCell('Terlambat', font, fontBold, isHeader: true),
                  _buildTableCell(
                    'Total Denda',
                    font,
                    fontBold,
                    isHeader: true,
                  ),
                ],
              ),
              // Data rows
              ...data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final peminjaman = item['peminjaman'] as Map<String, dynamic>?;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}', font, fontBold),
                    _buildTableCell(
                      peminjaman?['kode_peminjaman'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      peminjaman?['users']?['nama'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      peminjaman?['alat']?['nama_alat'] ?? '-',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      '${item['keterlambatan_hari'] ?? 0} hari',
                      font,
                      fontBold,
                    ),
                    _buildTableCell(
                      currencyFormat.format(item['total_denda'] ?? 0),
                      font,
                      fontBold,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Build stat item
  pw.Widget _buildStatItem(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 16)),
      ],
    );
  }

  // Helper: Build table cell
  pw.Widget _buildTableCell(
    String text,
    pw.Font font,
    pw.Font fontBold, {
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? fontBold : font,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
  }

  // Helper: Format status
  String _formatStatus(String? status) {
    if (status == null) return '-';
    final statusMap = {
      'diajukan': 'Diajukan',
      'disetujui': 'Disetujui',
      'ditolak': 'Ditolak',
      'dipinjam': 'Dipinjam',
      'dikembalikan': 'Dikembalikan',
      'terlambat': 'Terlambat',
    };
    return statusMap[status] ?? status;
  }

  // Helper: Format kondisi
  String _formatKondisi(String? kondisi) {
    if (kondisi == null) return '-';
    final kondisiMap = {
      'baik': 'Baik',
      'rusak_ringan': 'Rusak Ringan',
      'rusak_berat': 'Rusak Berat',
      'hilang': 'Hilang',
    };
    return kondisiMap[kondisi] ?? kondisi;
  }
}

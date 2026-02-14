import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/core/services/peminjaman_service.dart';
import 'package:rentalify/features/home/dashboard/borrower/cubit/borrower_tanggungan_cubit.dart';
import 'package:rentalify/features/home/dashboard/borrower/cubit/borrower_tanggungan_state.dart';

class BorrowerTanggunganPage extends StatelessWidget {
  const BorrowerTanggunganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TanggunganCubit(peminjamanService: PeminjamanService())
            ..loadTanggungan(),
      child: const _BorrowerTanggunganView(),
    );
  }
}

class _BorrowerTanggunganView extends StatelessWidget {
  const _BorrowerTanggunganView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tanggungan Pengembalian'),
        elevation: 0,
      ),
      body: BlocBuilder<TanggunganCubit, TanggunganState>(
        builder: (context, state) {
          if (state is TanggunganLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TanggunganError) {
            return _buildErrorState(context, state.message);
          }

          if (state is TanggunganEmpty) {
            return _buildEmptyState();
          }

          if (state is TanggunganLoaded) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TanggunganCubit>().refreshTanggungan(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              displacement: 40,
              strokeWidth: 3,
              child: _buildContent(context, state),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TanggunganLoaded state) {
    // FIXED: Hitung total denda langsung dari state.dendaInfo
    double totalDenda = 0;
    for (final denda in state.dendaInfo.values) {
      totalDenda += (denda['total_denda'] as num).toDouble();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        _buildInfoCard(context, state, totalDenda),
        const SizedBox(height: 16),

        // Info Pengembalian
        _buildReturnInfoCard(context),
        const SizedBox(height: 16),

        // Total Denda Card (jika ada denda)
        if (totalDenda > 0) ...[
          _buildTotalDendaCard(context, totalDenda),
          const SizedBox(height: 16),
        ],

        // List Title
        Text(
          'Daftar Alat yang Harus Dikembalikan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // List
        ...state.tanggunganList.map((tanggungan) {
          final idPeminjaman = tanggungan['id_peminjaman'] as int;
          final dendaInfo = state.getDendaForPeminjaman(idPeminjaman);
          return _buildTanggunganCard(context, tanggungan, dendaInfo);
        }),
        const SizedBox(height: 100), // Bottom padding for navbar
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    TanggunganLoaded state,
    double totalDenda,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.jumlahTerlambat > 0
              ? [AppColors.error, AppColors.error.withOpacity(0.8)]
              : [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  state.jumlahTerlambat > 0
                      ? Icons.warning
                      : Icons.assignment_return,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.jumlahTerlambat > 0
                          ? 'Ada Keterlambatan!'
                          : 'Tanggungan Aktif',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.tanggunganList.length} alat harus dikembalikan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.jumlahTerlambat > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.jumlahTerlambat} alat terlambat! Total denda: ${_formatCurrency(totalDenda)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cara Pengembalian',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk mengembalikan alat, silakan datang ke tempat peminjaman dan hubungi petugas. Petugas akan memproses pengembalian Anda.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDendaCard(BuildContext context, double totalDenda) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Denda Keterlambatan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(totalDenda),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 500, // Fixed height instead of MediaQuery
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<TanggunganCubit>().loadTanggungan();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 500, // Fixed height instead of MediaQuery
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak Ada Tanggungan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda tidak memiliki alat yang harus dikembalikan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTanggunganCard(
    BuildContext context,
    Map<String, dynamic> tanggungan,
    Map<String, dynamic> dendaInfo,
  ) {
    final alat = tanggungan['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;
    final tanggalPinjam = DateTime.parse(tanggungan['tanggal_pinjam']);
    final tanggalKembaliRencana = DateTime.parse(
      tanggungan['tanggal_kembali_rencana'],
    );

    // FIXED: Normalisasi tanggal untuk perhitungan yang akurat
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(
      tanggalKembaliRencana.year,
      tanggalKembaliRencana.month,
      tanggalKembaliRencana.day,
    );

    // Hitung status terlambat berdasarkan perbandingan tanggal yang sudah dinormalisasi
    final isLate = todayDate.isAfter(dueDate);
    final daysLate = dendaInfo['hari_terlambat'] as int;
    final totalDenda = (dendaInfo['total_denda'] as num).toDouble();
    final daysUntilDue = isLate ? 0 : dueDate.difference(todayDate).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLate ? AppColors.error.withOpacity(0.5) : AppColors.border,
          width: isLate ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              _showDetailDialog(context, tanggungan, dendaInfo, isLate),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tanggungan['kode_peminjaman'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isLate
                            ? AppColors.error.withOpacity(0.2)
                            : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLate ? Icons.warning : Icons.schedule,
                            size: 12,
                            color: isLate ? AppColors.error : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLate ? 'Terlambat' : 'Aktif',
                            style: TextStyle(
                              color: isLate
                                  ? AppColors.error
                                  : AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isLate) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Terlambat $daysLate hari',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Alat Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat?['nama_alat'] ?? '-',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${kategori?['nama'] ?? '-'} • Jumlah: ${tanggungan['jumlah_pinjam'] ?? 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          Icons.calendar_today,
                          'Dipinjam',
                          DateFormat('dd MMM yyyy').format(tanggalPinjam),
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppColors.border),
                      Expanded(
                        child: _buildDateInfo(
                          Icons.event,
                          'Jatuh Tempo',
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(tanggalKembaliRencana),
                        ),
                      ),
                    ],
                  ),
                ),

                // Denda Info (jika terlambat)
                if (isLate && totalDenda > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Denda Keterlambatan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatCurrency(totalDenda),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Countdown or Late Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLate
                        ? AppColors.error.withOpacity(0.1)
                        : daysUntilDue <= 2
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLate
                          ? AppColors.error.withOpacity(0.3)
                          : daysUntilDue <= 2
                          ? AppColors.warning.withOpacity(0.3)
                          : AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLate
                            ? Icons.error_outline
                            : daysUntilDue <= 2
                            ? Icons.warning_amber
                            : Icons.info_outline,
                        size: 16,
                        color: isLate
                            ? AppColors.error
                            : daysUntilDue <= 2
                            ? AppColors.warning
                            : AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLate
                              ? 'Segera hubungi petugas untuk pengembalian! Denda bertambah setiap hari.'
                              : daysUntilDue <= 2
                              ? 'Hampir jatuh tempo! Segera kembalikan dalam $daysUntilDue hari.'
                              : 'Sisa waktu peminjaman: $daysUntilDue hari',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLate
                                ? AppColors.error
                                : daysUntilDue <= 2
                                ? AppColors.warning
                                : AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> tanggungan,
    Map<String, dynamic> dendaInfo,
    bool isLate,
  ) {
    final alat = tanggungan['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;
    final daysLate = dendaInfo['hari_terlambat'] as int;
    final dendaPerHari = (dendaInfo['denda_per_hari'] as num).toDouble();
    final totalDenda = (dendaInfo['total_denda'] as num).toDouble();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(tanggungan['kode_peminjaman'] ?? '-'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Alat', alat?['nama_alat'] ?? '-'),
              _buildDetailRow('Kategori', kategori?['nama'] ?? '-'),
              _buildDetailRow(
                'Jumlah',
                '${tanggungan['jumlah_pinjam'] ?? 1} unit',
              ),
              _buildDetailRow(
                'Tanggal Pinjam',
                tanggungan['tanggal_pinjam'] ?? '-',
              ),
              _buildDetailRow(
                'Jatuh Tempo',
                tanggungan['tanggal_kembali_rencana'] ?? '-',
              ),
              _buildDetailRow('Status', isLate ? 'Terlambat' : 'Aktif'),

              // Denda Information
              if (isLate && totalDenda > 0) ...[
                const Divider(color: AppColors.border),
                const Text(
                  'Informasi Denda:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Terlambat', '$daysLate hari'),
                _buildDetailRow(
                  'Denda per Hari',
                  _formatCurrency(dendaPerHari),
                ),
                _buildDetailRow(
                  'Total Denda',
                  _formatCurrency(totalDenda),
                  isHighlight: true,
                ),
              ],

              const Divider(color: AppColors.border),
              const Text(
                'Keperluan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tanggungan['keperluan'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLate
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLate
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLate ? Icons.error_outline : Icons.info_outline,
                      size: 16,
                      color: isLate ? AppColors.error : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isLate
                            ? 'Segera kembalikan untuk menghindari denda yang semakin besar!'
                            : 'Untuk pengembalian, silakan datang ke tempat peminjaman dan hubungi petugas.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLate ? AppColors.error : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

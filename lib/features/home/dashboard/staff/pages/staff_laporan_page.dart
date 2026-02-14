import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_laporan_cubit.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_laporan_state.dart';

class StaffLaporanPage extends StatelessWidget {
  const StaffLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LaporanCubit(),
      child: const _StaffLaporanPageContent(),
    );
  }
}

class _StaffLaporanPageContent extends StatefulWidget {
  const _StaffLaporanPageContent();

  @override
  State<_StaffLaporanPageContent> createState() =>
      _StaffLaporanPageContentState();
}

class _StaffLaporanPageContentState extends State<_StaffLaporanPageContent> {
  String _selectedLaporanType = 'all';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Auto-load statistik saat pertama kali dibuka
    _loadStatistik();
  }

  void _loadStatistik() {
    context.read<LaporanCubit>().loadLaporan(
      jenisLaporan: _selectedLaporanType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Laporan'), elevation: 0),
      body: BlocListener<LaporanCubit, LaporanState>(
        listener: (context, state) {
          if (state is LaporanGenerating) {
            // Show progress dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => PopScope(
                canPop: false,
                child: AlertDialog(
                  backgroundColor: AppColors.surface,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(state.message),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is LaporanGenerated) {
            // Tutup loading dialog dengan root navigator
            Navigator.of(context, rootNavigator: true).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF berhasil dibuat dan dibuka di browser'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is LaporanError) {
            // Tutup loading dialog dengan root navigator
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assessment, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Laporan Peminjaman',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Export dan analisis data peminjaman',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Laporan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jenis Laporan
                  const Text(
                    'Jenis Laporan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLaporanType,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Semua Laporan'),
                          ),
                          DropdownMenuItem(
                            value: 'peminjaman',
                            child: Text('Laporan Peminjaman'),
                          ),
                          DropdownMenuItem(
                            value: 'pengembalian',
                            child: Text('Laporan Pengembalian'),
                          ),
                          DropdownMenuItem(
                            value: 'denda',
                            child: Text('Laporan Denda'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLaporanType = value!;
                          });
                          // Auto-load statistik saat jenis laporan berubah
                          _loadStatistik();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Range
                  const Text(
                    'Periode Laporan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateButton(
                          label: 'Dari',
                          date: _startDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateButton(
                          label: 'Sampai',
                          date: _endDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Generate Button - Hanya untuk export PDF
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exportToPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistik Cards - Auto-load
            BlocBuilder<LaporanCubit, LaporanState>(
              builder: (context, state) {
                if (state is LaporanLoading) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is LaporanLoaded) {
                  if (state.data.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tidak ada data untuk periode ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildStatistikSection(state.statistik);
                }

                if (state is LaporanError) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return _buildStatistikSection({});
              },
            ),
            // const SizedBox(height: 16),

            // Quick Actions
            // _buildQuickActionsSection(),
            // const SizedBox(height: 16),

            // Recent Reports
            // _buildRecentReportsSection(),
            // const SizedBox(height: 100), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistikSection(Map<String, dynamic> statistik) {
    if (_selectedLaporanType == 'all') {
      return _buildStatistikAll(statistik);
    } else if (_selectedLaporanType == 'peminjaman') {
      return _buildStatistikPeminjaman(statistik);
    } else if (_selectedLaporanType == 'pengembalian') {
      return _buildStatistikPengembalian(statistik);
    } else {
      return _buildStatistikDenda(statistik);
    }
  }

  Widget _buildStatistikAll(Map<String, dynamic> statistik) {
    final totalDenda = statistik['total_denda'] ?? 0;
    final formattedDenda = 'Rp ${(totalDenda / 1000).toStringAsFixed(0)}K';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Periode (Semua)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Statistik Peminjaman
        const Text(
          'Peminjaman',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment,
                label: 'Dipinjam',
                value: '${statistik['dipinjam'] ?? 0}',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_return,
                label: 'Dikembalikan',
                value: '${statistik['dikembalikan'] ?? 0}',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning,
                label: 'Terlambat',
                value: '${statistik['terlambat'] ?? 0}',
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cancel,
                label: 'Ditolak',
                value: '${statistik['ditolak'] ?? 0}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Statistik Pengembalian
        const Text(
          'Pengembalian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Tepat Waktu',
                value: '${statistik['tepat_waktu'] ?? 0}',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.verified,
                label: 'Kondisi Baik',
                value: '${statistik['kondisi_baik'] ?? 0}',
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Statistik Denda
        const Text(
          'Denda',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.receipt_long,
                label: 'Transaksi Denda',
                value: '${statistik['total_transaksi'] ?? 0}',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.attach_money,
                label: 'Total Denda',
                value: formattedDenda,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistikPeminjaman(Map<String, dynamic> statistik) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Periode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment,
                label: 'Peminjaman',
                value: '${statistik['dipinjam'] ?? 0}',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_return,
                label: 'Dikembalikan',
                value: '${statistik['dikembalikan'] ?? 0}',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning,
                label: 'Terlambat',
                value: '${statistik['terlambat'] ?? 0}',
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cancel,
                label: 'Ditolak',
                value: '${statistik['ditolak'] ?? 0}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistikPengembalian(Map<String, dynamic> statistik) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Periode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Tepat Waktu',
                value: '${statistik['tepat_waktu'] ?? 0}',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning,
                label: 'Terlambat',
                value: '${statistik['terlambat'] ?? 0}',
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.verified,
                label: 'Kondisi Baik',
                value: '${statistik['kondisi_baik'] ?? 0}',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.build,
                label: 'Rusak',
                value: '${statistik['rusak'] ?? 0}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistikDenda(Map<String, dynamic> statistik) {
    final totalDenda = statistik['total_denda'] ?? 0;
    final formattedDenda = 'Rp ${(totalDenda / 1000).toStringAsFixed(0)}K';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Periode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.receipt_long,
                label: 'Total Transaksi',
                value: '${statistik['total_transaksi'] ?? 0}',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.attach_money,
                label: 'Total Denda',
                value: formattedDenda,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Lunas',
                value: '${statistik['lunas'] ?? 0}',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending,
                label: 'Belum Lunas',
                value: '${statistik['belum_lunas'] ?? 0}',
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Quick Actions',
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        // const SizedBox(height: 12),
        // _buildActionButton(
        //   icon: Icons.picture_as_pdf,
        //   title: 'Export ke PDF',
        //   subtitle: 'Download laporan dalam format PDF',
        //   color: AppColors.error,
        //   onTap: _exportToPdf,
        // ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildRecentReportsSection() {
  // final recentReports = [
  //   {
  //     'title': 'Laporan Peminjaman - Januari 2024',
  //     'date': '2024-01-31',
  //     'type': 'peminjaman',
  //     'size': '1.2 MB',
  //   },
  //   {
  //     'title': 'Laporan Pengembalian - Desember 2023',
  //     'date': '2023-12-31',
  //     'type': 'pengembalian',
  //     'size': '980 KB',
  //   },
  // ];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Laporan Terbaru',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.w600,
  //           color: AppColors.textPrimary,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       ...recentReports.map((report) => _buildReportCard(report)),
  //     ],
  //   );
  // }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report['date'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.file_present,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report['size'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 20),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });

      // Auto-load statistik saat tanggal berubah
      _loadStatistik();
    }
  }

  void _exportToPdf() {
    context.read<LaporanCubit>().generateAndPreviewPDF(
      jenisLaporan: _selectedLaporanType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }
}

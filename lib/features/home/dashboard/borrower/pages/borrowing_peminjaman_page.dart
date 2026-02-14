import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/core/services/peminjaman_service.dart';
import 'package:rentalify/features/home/dashboard/borrower/cubit/borrower_peminjaman_cubit.dart';
import 'package:rentalify/features/home/dashboard/borrower/cubit/borrower_peminjaman_state.dart';

class BorrowerPeminjamanPage extends StatelessWidget {
  const BorrowerPeminjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BorrowerPeminjamanCubit(peminjamanService: PeminjamanService())
            ..loadData(),
      child: const _BorrowerPeminjamanView(),
    );
  }
}

class _BorrowerPeminjamanView extends StatefulWidget {
  const _BorrowerPeminjamanView();

  @override
  State<_BorrowerPeminjamanView> createState() =>
      _BorrowerPeminjamanViewState();
}

class _BorrowerPeminjamanViewState extends State<_BorrowerPeminjamanView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final cubit = context.read<BorrowerPeminjamanCubit>();
    cubit.updateSearchQuery(value);

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        cubit.loadData();
      }
    });
  }

  void _onFilterChanged(String? value) {
    if (value == null) return;
    context.read<BorrowerPeminjamanCubit>().updateStatusFilter(value);
  }

  Future<void> _onRefresh() async {
    await context.read<BorrowerPeminjamanCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Peminjaman Saya'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            // Search & Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                children: [
                  BlocBuilder<BorrowerPeminjamanCubit, BorrowerPeminjamanState>(
                    builder: (context, state) {
                      return TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari peminjaman...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<BorrowerPeminjamanCubit>()
                                        .clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: _onSearchChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<BorrowerPeminjamanCubit, BorrowerPeminjamanState>(
                    builder: (context, state) {
                      return _buildFilterDropdown(
                        label: 'Status',
                        value: state.selectedStatusFilter,
                        items: [
                          'Semua',
                          'Diajukan',
                          'Disetujui',
                          'Dipinjam',
                          'Dikembalikan',
                          'Ditolak',
                          'Terlambat',
                        ],
                        onChanged: _onFilterChanged,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Summary Card
            BlocBuilder<BorrowerPeminjamanCubit, BorrowerPeminjamanState>(
              builder: (context, state) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment,
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
                              'Total Peminjaman',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${state.stats['total'] ?? 0}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.pending,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.stats['diajukan'] ?? 0} Pending',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // List
            Expanded(
              child:
                  BlocBuilder<BorrowerPeminjamanCubit, BorrowerPeminjamanState>(
                    builder: (context, state) {
                      return _buildContent(state);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BorrowerPeminjamanState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.peminjamanList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: state.peminjamanList.length,
      itemBuilder: (context, index) {
        final peminjaman = state.peminjamanList[index];
        return _buildPeminjamanCard(peminjaman);
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
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
              errorMessage,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<BorrowerPeminjamanCubit>().loadData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada peminjaman',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajukan peminjaman alat dari halaman Home',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajukan Peminjaman'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPeminjamanCard(Map<String, dynamic> peminjaman) {
    final alat = peminjaman['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;
    final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final tanggalKembaliRencana = DateTime.parse(
      peminjaman['tanggal_kembali_rencana'],
    );
    final status = peminjaman['status_peminjaman'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(peminjaman),
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
                        peminjaman['kode_peminjaman'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),

                // Alat Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
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
                            alat?['nama_alat'] ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${kategori?['nama'] ?? '-'} • Jumlah: ${peminjaman['jumlah_pinjam'] ?? 1}',
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
                const SizedBox(height: 12),

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
                          'Kembali',
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(tanggalKembaliRencana),
                        ),
                      ),
                    ],
                  ),
                ),

                // Catatan Admin (jika ada)
                if (peminjaman['catatan_admin'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status == 'ditolak'
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: status == 'ditolak'
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: status == 'ditolak'
                              ? AppColors.error
                              : AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan Petugas:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: status == 'ditolak'
                                      ? AppColors.error
                                      : AppColors.info,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                peminjaman['catatan_admin'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: status == 'ditolak'
                                      ? AppColors.error
                                      : AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'diajukan':
        color = AppColors.warning;
        text = 'Diajukan';
        icon = Icons.pending;
        break;
      case 'disetujui':
        color = AppColors.info;
        text = 'Disetujui';
        icon = Icons.check_circle;
        break;
      case 'dipinjam':
        color = AppColors.success;
        text = 'Dipinjam';
        icon = Icons.sync;
        break;
      case 'dikembalikan':
        color = AppColors.success;
        text = 'Dikembalikan';
        icon = Icons.check_circle;
        break;
      case 'ditolak':
        color = AppColors.error;
        text = 'Ditolak';
        icon = Icons.cancel;
        break;
      case 'terlambat':
        color = AppColors.error;
        text = 'Terlambat';
        icon = Icons.warning;
        break;
      default:
        color = AppColors.textTertiary;
        text = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> peminjaman) {
    final alat = peminjaman['alat'] as Map<String, dynamic>?;
    final kategori = alat?['kategori'] as Map<String, dynamic>?;
    final status = peminjaman['status_peminjaman'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Expanded(child: Text(peminjaman['kode_peminjaman'] ?? '-')),
            _buildStatusBadge(status),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Alat', alat?['nama_alat'] ?? '-'),
              _buildDetailRow('Kategori', kategori?['nama'] ?? '-'),
              _buildDetailRow(
                'Jumlah',
                '${peminjaman['jumlah_pinjam'] ?? 1} unit',
              ),
              _buildDetailRow(
                'Tanggal Pinjam',
                peminjaman['tanggal_pinjam'] ?? '-',
              ),
              _buildDetailRow(
                'Tanggal Kembali',
                peminjaman['tanggal_kembali_rencana'] ?? '-',
              ),
              if (peminjaman['tanggal_kembali_actual'] != null)
                _buildDetailRow(
                  'Dikembalikan',
                  peminjaman['tanggal_kembali_actual'],
                ),
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
                peminjaman['keperluan'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (peminjaman['catatan_admin'] != null) ...[
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const Text(
                  'Catatan Petugas:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  peminjaman['catatan_admin'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

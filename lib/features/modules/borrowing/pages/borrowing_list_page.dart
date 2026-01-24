import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/borrowing_list_cubit.dart';
import '../cubit/borrowing_list_state.dart';

class BorrowingListPage extends StatefulWidget {
  const BorrowingListPage({super.key});

  @override
  State<BorrowingListPage> createState() => _BorrowingListPageState();
}

class _BorrowingListPageState extends State<BorrowingListPage> {
  @override
  void initState() {
    super.initState();
    context.read<BorrowingListCubit>().loadMyBorrowings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Saya'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<BorrowingListCubit, BorrowingListState>(
        builder: (context, state) {
          if (state.status == BorrowingListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BorrowingListStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Error',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<BorrowingListCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.peminjamanList.isEmpty) {
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
                    'Belum Ada Peminjaman',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai pinjam alat dari halaman utama',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BorrowingListCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.peminjamanList.length,
              itemBuilder: (context, index) {
                final peminjaman = state.peminjamanList[index];
                return _buildPeminjamanCard(context, peminjaman);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeminjamanCard(BuildContext context, Map<String, dynamic> peminjaman) {
    final alat = peminjaman['alat'];
    final status = peminjaman['status_peminjaman'] as String;
    final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final tanggalKembali = DateTime.parse(peminjaman['tanggal_kembali_rencana']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        peminjaman['kode_peminjaman'] ?? 'N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),

                // Nama Alat
                Text(
                  alat['nama_alat'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategori: ${alat['kategori'] ?? '-'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // Tanggal
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('dd MMM').format(tanggalPinjam)} - ${DateFormat('dd MMM yyyy').format(tanggalKembali)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Jumlah
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Jumlah: ${peminjaman['jumlah_pinjam']} unit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                // Keperluan (if exists)
                if (peminjaman['keperluan'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Keperluan:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    peminjaman['keperluan'],
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Catatan admin (if rejected or approved with note)
                if (peminjaman['catatan_admin'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan Petugas:',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                peminjaman['catatan_admin'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(status),
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
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diajukan':
        return AppColors.warning;
      case 'disetujui':
      case 'dipinjam':
        return AppColors.info;
      case 'ditolak':
        return AppColors.error;
      case 'dikembalikan':
        return AppColors.success;
      case 'terlambat':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'diajukan':
        return 'Menunggu';
      case 'disetujui':
        return 'Disetujui';
      case 'dipinjam':
        return 'Dipinjam';
      case 'ditolak':
        return 'Ditolak';
      case 'dikembalikan':
        return 'Selesai';
      case 'terlambat':
        return 'Terlambat';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'diajukan':
        return Icons.pending;
      case 'disetujui':
      case 'dipinjam':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      case 'dikembalikan':
        return Icons.check_circle_outline;
      case 'terlambat':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}
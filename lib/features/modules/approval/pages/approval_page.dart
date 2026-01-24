import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/approval_cubit.dart';
import '../cubit/approval_state.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  @override
  void initState() {
    super.initState();
    context.read<ApprovalCubit>().loadPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Peminjaman'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ApprovalCubit>().refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<ApprovalCubit, ApprovalState>(
        listener: (context, state) {
          if (state.status == ApprovalStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Berhasil'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state.status == ApprovalStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ApprovalStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ApprovalStatus.error && state.pendingList.isEmpty) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.errorMessage ?? 'Error',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ApprovalCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.pendingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Permintaan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua permintaan sudah diproses',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ApprovalCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.pendingList.length,
              itemBuilder: (context, index) {
                final request = state.pendingList[index];
                return _buildRequestCard(context, request, state.status);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    Map<String, dynamic> request,
    ApprovalStatus currentStatus,
  ) {
    final user = request['users'];
    final alat = request['alat'];
    final tanggalPinjam = DateTime.parse(request['tanggal_pinjam']);
    final tanggalKembali = DateTime.parse(request['tanggal_kembali_rencana']);
    final isProcessing = currentStatus == ApprovalStatus.processing;

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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        request['kode_peminjaman'] ?? 'N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd MMM yyyy').format(
                        DateTime.parse(request['created_at']),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Alat Info
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

                // Peminjam Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Peminjam',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['nama'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (user['email'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user['email'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Detail Peminjaman
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Pinjam',
                        value: DateFormat('dd MMM yyyy').format(tanggalPinjam),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        icon: Icons.event_available,
                        label: 'Tanggal Kembali',
                        value: DateFormat('dd MMM yyyy').format(tanggalKembali),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Jumlah',
                  value: '${request['jumlah_pinjam']} unit (Tersedia: ${alat['jumlah_tersedia']})',
                ),

                if (request['keperluan'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Keperluan',
                    value: request['keperluan'],
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isProcessing
                        ? null
                        : () {
                            print('Tolak button pressed');
                            _showRejectDialog(context, request);
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            color: isProcessing
                                ? AppColors.textTertiary
                                : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tolak',
                            style: TextStyle(
                              color: isProcessing
                                  ? AppColors.textTertiary
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.border,
                ),
                Expanded(
                  child: InkWell(
                    onTap: isProcessing
                        ? null
                        : () {
                            print('Setujui button pressed');
                            _showApproveDialog(context, request);
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            color: isProcessing
                                ? AppColors.textTertiary
                                : AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Setujui',
                            style: TextStyle(
                              color: isProcessing
                                  ? AppColors.textTertiary
                                  : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, Map<String, dynamic> request) {
    print('Showing approve dialog for: ${request['kode_peminjaman']}');
    
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Setujui Peminjaman'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menyetujui peminjaman ini?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waktu peminjaman dimulai saat ini',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan untuk peminjam...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Dialog canceled');
              Navigator.pop(dialogContext);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Approving peminjaman...');
              Navigator.pop(dialogContext);
              
              // Call the cubit function
              context.read<ApprovalCubit>().approvePeminjaman(
                    idPeminjaman: request['id_peminjaman'],
                    idAlat: request['id_alat'],
                    jumlahPinjam: request['jumlah_pinjam'],
                    tanggalPinjam: request['tanggal_pinjam'],
                    catatan: catatanController.text.trim().isEmpty 
                        ? null 
                        : catatanController.text.trim(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Map<String, dynamic> request) {
    print('Showing reject dialog for: ${request['kode_peminjaman']}');
    
    final alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tolak Peminjaman'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Berikan alasan penolakan',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alasanController,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan *',
                  hintText: 'Jelaskan alasan penolakan...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Dialog canceled');
              Navigator.pop(dialogContext);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final alasan = alasanController.text.trim();
              print('Alasan: $alasan');
              
              if (alasan.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              print('Rejecting peminjaman...');
              Navigator.pop(dialogContext);
              
              context.read<ApprovalCubit>().rejectPeminjaman(
                    idPeminjaman: request['id_peminjaman'],
                    alasan: alasan,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
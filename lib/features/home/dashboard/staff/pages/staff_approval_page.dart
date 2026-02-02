import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/model/peminjaman_approval.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_approval_cubit.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_approval_state.dart';

class StaffApprovalPage extends StatelessWidget {
  const StaffApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffApprovalCubit()..loadPendingRequests(),
      child: const _StaffApprovalPageContent(),
    );
  }
}

class _StaffApprovalPageContent extends StatefulWidget {
  const _StaffApprovalPageContent();

  @override
  State<_StaffApprovalPageContent> createState() =>
      _StaffApprovalPageContentState();
}

class _StaffApprovalPageContentState extends State<_StaffApprovalPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffApprovalCubit, StaffApprovalState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<StaffApprovalCubit>().loadPendingRequests();
          },
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Persetujuan Peminjaman',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Setujui atau tolak permintaan peminjaman',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(state),
                    ],
                  ),
                ),
              ),

              // Search & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBar(state),
                ),
              ),

              // Content
              if (state is StaffApprovalLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is StaffApprovalLoaded)
                _buildRequestList(state)
              else if (state is StaffApprovalError)
                _buildErrorState(state)
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Bottom padding for navbar
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, StaffApprovalState state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (state is StaffApprovalError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is StaffApprovalOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is StaffApprovalOperationLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(state.operation)),
            ],
          ),
          duration: const Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSummaryCard(StaffApprovalState state) {
    int totalRequests = 0;
    if (state is StaffApprovalLoaded) {
      totalRequests = state.allRequests.length;
    }

    return Container(
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
              Icons.pending_actions,
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
                  'Menunggu Persetujuan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRequests Permintaan',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(StaffApprovalState state) {
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
                  context.read<StaffApprovalCubit>().searchRequests('');
                },
              )
            : null,
      ),
      onChanged: (value) {
        context.read<StaffApprovalCubit>().searchRequests(value);
      },
    );
  }

  Widget _buildRequestList(StaffApprovalLoaded state) {
    if (state.filteredRequests.isEmpty) {
      return SliverFillRemaining(
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
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Tidak ada permintaan yang sesuai'
                    : 'Tidak ada permintaan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Coba kata kunci lain'
                    : 'Semua permintaan sudah diproses',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final request = state.filteredRequests[index];
            return _buildRequestCard(context, request);
          },
          childCount: state.filteredRequests.length,
        ),
      ),
    );
  }

  Widget _buildErrorState(StaffApprovalError state) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<StaffApprovalCubit>().loadPendingRequests();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, PeminjamanApproval request) {
    final stockWarning = !request.hasEnoughStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stockWarning
              ? AppColors.error.withOpacity(0.5)
              : AppColors.border,
          width: stockWarning ? 2 : 1,
        ),
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
                        request.kodePeminjaman,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd MMM yyyy').format(request.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stock Warning
                if (stockWarning) ...[
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
                        const Icon(Icons.warning,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Text(
                          'Stok tidak mencukupi! Tersedia: ${request.jumlahTersedia}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Alat Info
                Text(
                  request.namaAlat,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategori: ${request.kategoriAlat}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // Peminjam Info
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.namaUser,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tanggal
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('dd MMM').format(request.tanggalPinjam)} - ${DateFormat('dd MMM yyyy').format(request.tanggalKembaliRencana)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${request.durasiPinjam} hari)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
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
                    const SizedBox(width: 4),
                    Text(
                      'Jumlah: ${request.jumlahPinjam} unit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                if (request.keperluan != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Keperluan:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.keperluan!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  child: TextButton.icon(
                    onPressed: () => _showRejectDialog(context, request),
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.border,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: stockWarning
                        ? null
                        : () => _showApproveDialog(context, request),
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _showApproveDialog(
      BuildContext context, PeminjamanApproval request) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Setujui Peminjaman'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menyetujui peminjaman ini?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.kodePeminjaman,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Peminjam', request.namaUser),
                    _buildInfoRow('Alat', request.namaAlat),
                    _buildInfoRow('Jumlah', '${request.jumlahPinjam} unit'),
                    _buildInfoRow(
                      'Durasi',
                      '${request.durasiPinjam} hari',
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
                  hintText: 'Tambahkan catatan jika diperlukan...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stok alat akan berkurang sebanyak ${request.jumlahPinjam} unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StaffApprovalCubit>().approvePeminjaman(
                    idPeminjaman: request.idPeminjaman,
                    idAlat: request.idAlat,
                    jumlahPinjam: request.jumlahPinjam,
                    catatanAdmin: catatanController.text.isEmpty
                        ? null
                        : catatanController.text,
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

  void _showRejectDialog(BuildContext context, PeminjamanApproval request) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tolak Peminjaman'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menolak peminjaman ini?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.kodePeminjaman,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Peminjam', request.namaUser),
                    _buildInfoRow('Alat', request.namaAlat),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan',
                  hintText: 'Masukkan alasan penolakan...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StaffApprovalCubit>().rejectPeminjaman(
                    idPeminjaman: request.idPeminjaman,
                    catatanAdmin: catatanController.text.isEmpty
                        ? 'Peminjaman ditolak'
                        : catatanController.text,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
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
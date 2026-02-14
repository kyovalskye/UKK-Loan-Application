import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/auth/cubit/auth_cubit.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_pengembalian_cubit.dart';
import 'package:rentalify/features/home/dashboard/staff/cubit/staff_pengembalian_state.dart';

class StaffPengembalianPage extends StatelessWidget {
  const StaffPengembalianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffPengembalianCubit()..loadActiveBorrowings(),
      child: const _StaffPengembalianPageContent(),
    );
  }
}

class _StaffPengembalianPageContent extends StatefulWidget {
  const _StaffPengembalianPageContent();

  @override
  State<_StaffPengembalianPageContent> createState() =>
      _StaffPengembalianPageContentState();
}

class _StaffPengembalianPageContentState
    extends State<_StaffPengembalianPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pemantauan Peminjaman'), elevation: 0),
      body: BlocConsumer<StaffPengembalianCubit, StaffPengembalianState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await context
                  .read<StaffPengembalianCubit>()
                  .loadActiveBorrowings();
            },
            color: AppColors.primary,
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 3,
            child: Column(
              children: [
                _buildSearchBar(state),
                _buildSummaryCard(state),
                Expanded(child: _buildContent(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, StaffPengembalianState state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (state is StaffPengembalianError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is StaffPengembalianOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is StaffPengembalianOperationLoading) {
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

  Widget _buildSearchBar(StaffPengembalianState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari peminjaman...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<StaffPengembalianCubit>().searchBorrowings('');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          context.read<StaffPengembalianCubit>().searchBorrowings(value);
        },
      ),
    );
  }

  Widget _buildSummaryCard(StaffPengembalianState state) {
    int totalActive = 0;
    int totalLate = 0;

    if (state is StaffPengembalianLoaded) {
      totalActive = state.allBorrowings.length;

      // FIXED: Normalisasi tanggal untuk perhitungan keterlambatan yang akurat
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      totalLate = state.allBorrowings.where((p) {
        final tanggalKembali = DateTime.parse(p['tanggal_kembali_rencana']);
        final dueDate = DateTime(
          tanggalKembali.year,
          tanggalKembali.month,
          tanggalKembali.day,
        );
        return todayDate.isAfter(dueDate);
      }).length;
    }

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
              Icons.assignment_return,
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
                  'Peminjaman Aktif',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$totalActive Total',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    if (totalLate > 0) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalLate Terlambat',
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StaffPengembalianState state) {
    if (state is StaffPengembalianLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StaffPengembalianLoaded) {
      if (state.filteredBorrowings.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildEmptyState(state),
            ),
          ],
        );
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: state.filteredBorrowings.length,
        itemBuilder: (context, index) {
          final peminjaman = state.filteredBorrowings[index];
          return _buildPeminjamanCard(peminjaman);
        },
      );
    }

    if (state is StaffPengembalianError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildErrorState(state),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(StaffPengembalianLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty
                ? 'Tidak ada peminjaman yang sesuai'
                : 'Tidak ada peminjaman aktif',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.searchQuery.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Semua alat sudah dikembalikan',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(StaffPengembalianError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
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
              context.read<StaffPengembalianCubit>().loadActiveBorrowings();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeminjamanCard(Map<String, dynamic> peminjaman) {
    final user = peminjaman['users'];
    final alat = peminjaman['alat'];
    final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final tanggalKembaliRencana = DateTime.parse(
      peminjaman['tanggal_kembali_rencana'],
    );

    // FIXED: Normalisasi tanggal untuk perhitungan yang akurat
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(
      tanggalKembaliRencana.year,
      tanggalKembaliRencana.month,
      tanggalKembaliRencana.day,
    );

    final isLate = todayDate.isAfter(dueDate);
    final daysLate = isLate ? todayDate.difference(dueDate).inDays : 0;

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
                        peminjaman['kode_peminjaman'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(isLate),
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
                          Icons.warning,
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

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        (user['nama'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nama'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            user['email'] ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
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
                            alat['nama_alat'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alat['kategori']?['nama'] ?? '-'} • Jumlah: ${peminjaman['jumlah_pinjam']}',
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
                          'Jatuh Tempo',
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(tanggalKembaliRencana),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPengembalianDialog(peminjaman),
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Proses Pengembalian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

  Widget _buildStatusBadge(bool isLate) {
    final color = isLate ? AppColors.error : AppColors.success;
    final text = isLate ? 'Terlambat' : 'Dipinjam';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> peminjaman) {
    final user = peminjaman['users'];
    final alat = peminjaman['alat'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(peminjaman['kode_peminjaman']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Peminjam', user['nama'] ?? 'Unknown'),
              _buildDetailRow('Email', user['email'] ?? '-'),
              _buildDetailRow('Alat', alat['nama_alat'] ?? 'Unknown'),
              _buildDetailRow('Kategori', alat['kategori']?['nama'] ?? '-'),
              _buildDetailRow('Jumlah', '${peminjaman['jumlah_pinjam']} unit'),
              _buildDetailRow('Tanggal Pinjam', peminjaman['tanggal_pinjam']),
              _buildDetailRow(
                'Tanggal Kembali',
                peminjaman['tanggal_kembali_rencana'],
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPengembalianDialog(peminjaman);
            },
            child: const Text('Proses Pengembalian'),
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

  void _showPengembalianDialog(Map<String, dynamic> peminjaman) async {
    final cubit = context.read<StaffPengembalianCubit>();

    // Get setting denda
    final settingDenda = await cubit.getSettingDenda();

    if (!mounted) return;

    final tanggalKembaliRencana = DateTime.parse(
      peminjaman['tanggal_kembali_rencana'],
    );

    String selectedKondisi = 'baik';
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Calculate denda - INI AKAN RESPONSIF KARENA DIPANGGIL SETIAP REBUILD
          final dendaCalculation = cubit.calculateDenda(
            tanggalKembaliRencana: tanggalKembaliRencana,
            kondisi: selectedKondisi,
            settingDenda: settingDenda,
          );

          final keterlambatan = dendaCalculation['keterlambatan'] as int;
          final dendaKeterlambatan =
              dendaCalculation['denda_keterlambatan'] as double;
          final dendaKerusakan = dendaCalculation['denda_kerusakan'] as double;
          final totalDenda = dendaCalculation['total_denda'] as double;

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Proses Pengembalian'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peminjaman['kode_peminjaman'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kondisi Alat
                  const Text(
                    'Kondisi Alat Saat Dikembalikan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedKondisi,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.build_circle),
                    ),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: 'baik', child: Text('Baik')),
                      DropdownMenuItem(
                        value: 'rusak_ringan',
                        child: Text('Rusak Ringan'),
                      ),
                      DropdownMenuItem(
                        value: 'rusak_berat',
                        child: Text('Rusak Berat'),
                      ),
                      DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedKondisi = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Catatan
                  TextField(
                    controller: catatanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Pengembalian',
                      hintText: 'Tambahkan catatan jika diperlukan...',
                      prefixIcon: Icon(Icons.note),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Denda
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildDendaRow(
                          'Keterlambatan',
                          '$keterlambatan hari',
                          'Rp ${_formatCurrency(dendaKeterlambatan.toInt())}',
                        ),
                        if (dendaKerusakan > 0) ...[
                          const Divider(color: AppColors.border),
                          _buildDendaRow(
                            'Kerusakan',
                            selectedKondisi == 'hilang' ? 'Hilang' : 'Rusak',
                            'Rp ${_formatCurrency(dendaKerusakan.toInt())}',
                          ),
                        ],
                        const Divider(color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Denda',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(totalDenda.toInt())}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: totalDenda > 0
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (totalDenda > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Peminjam harus membayar denda sebelum bisa meminjam lagi',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  final authState = context.read<AuthCubit>().state;
                  final idPetugas = authState.userId;

                  if (idPetugas == null) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID tidak ditemukan'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  cubit.processPengembalian(
                    idPeminjaman: peminjaman['id_peminjaman'] as int,
                    idAlat: peminjaman['id_alat'] as int,
                    jumlahPinjam: peminjaman['jumlah_pinjam'] as int,
                    kondisiSaatKembali: selectedKondisi,
                    catatanPengembalian: catatanController.text.isEmpty
                        ? null
                        : catatanController.text,
                    keterlambatanHari: keterlambatan,
                    dendaKeterlambatan: dendaKeterlambatan,
                    dendaKerusakan: dendaKerusakan,
                    idPetugas: idPetugas,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Proses'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDendaRow(String label, String desc, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

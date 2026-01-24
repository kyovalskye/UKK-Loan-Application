import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/borrowing_cubit.dart';
import '../cubit/borrowing_state.dart';

class BorrowingPage extends StatefulWidget {
  final Map<String, dynamic>? alat;

  const BorrowingPage({
    super.key,
    this.alat,
  });

  @override
  State<BorrowingPage> createState() => _BorrowingPageState();
}

class _BorrowingPageState extends State<BorrowingPage> {
  final _keperluanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.alat != null) {
      context.read<BorrowingCubit>().selectAlat(widget.alat!);
    }
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BorrowingCubit, BorrowingState>(
      listener: (context, state) {
        if (state.status == BorrowingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state.status == BorrowingStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Berhasil'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == BorrowingStatus.submitting;
        final alat = state.selectedAlat;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Form Peminjaman'),
          ),
          body: alat == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Alat tidak ditemukan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Alat Info Card
                    _buildAlatInfoCard(context, alat),
                    const SizedBox(height: 24),

                    // Form Section
                    Text(
                      'Detail Peminjaman',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Pinjam
                    _buildDateField(
                      context,
                      label: 'Tanggal Pinjam',
                      value: state.tanggalPinjam,
                      onTap: () => _selectDate(
                        context,
                        isStartDate: true,
                        currentDate: state.tanggalPinjam,
                      ),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Kembali
                    _buildDateField(
                      context,
                      label: 'Tanggal Kembali (Rencana)',
                      value: state.tanggalKembali,
                      onTap: () => _selectDate(
                        context,
                        isStartDate: false,
                        currentDate: state.tanggalKembali,
                        minDate: state.tanggalPinjam,
                      ),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Pinjam
                    _buildJumlahField(
                      context,
                      state,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),

                    // Keperluan
                    TextField(
                      controller: _keperluanController,
                      enabled: !isSubmitting,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Keperluan (Opsional)',
                        hintText: 'Jelaskan keperluan peminjaman alat',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        context.read<BorrowingCubit>().setKeperluan(value);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Permintaan peminjaman akan diproses oleh petugas. Anda akan mendapat notifikasi setelah disetujui.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.info,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                context
                                    .read<BorrowingCubit>()
                                    .submitPeminjaman();
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Ajukan Peminjaman'),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAlatInfoCard(BuildContext context, Map<String, dynamic> alat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: alat['foto_alat'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: alat['foto_alat'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.build_circle,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.build_circle,
                    size: 40,
                    color: AppColors.textTertiary,
                  ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat['nama_alat'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (alat['kategori'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alat['kategori'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Stok: ${alat['jumlah_tersedia']} / ${alat['jumlah_total']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value != null
              ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(value)
              : 'Pilih tanggal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
        ),
      ),
    );
  }

  Widget _buildJumlahField(
    BuildContext context,
    BorrowingState state, {
    required bool enabled,
  }) {
    final maxJumlah = state.selectedAlat!['jumlah_tersedia'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Jumlah Pinjam',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              'Maks: $maxJumlah',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: enabled && state.jumlahPinjam > 1
                  ? () {
                      context
                          .read<BorrowingCubit>()
                          .setJumlahPinjam(state.jumlahPinjam - 1);
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${state.jumlahPinjam}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            IconButton(
              onPressed: enabled && state.jumlahPinjam < maxJumlah
                  ? () {
                      context
                          .read<BorrowingCubit>()
                          .setJumlahPinjam(state.jumlahPinjam + 1);
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
    DateTime? currentDate,
    DateTime? minDate,
  }) async {
    final now = DateTime.now();
    final firstDate = minDate ?? now;
    final initialDate = currentDate ?? (minDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      if (isStartDate) {
        context.read<BorrowingCubit>().setTanggalPinjam(picked);
      } else {
        context.read<BorrowingCubit>().setTanggalKembali(picked);
      }
    }
  }
}
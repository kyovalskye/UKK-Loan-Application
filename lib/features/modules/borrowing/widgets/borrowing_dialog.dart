import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/borrowing_cubit.dart';
import '../cubit/borrowing_state.dart';

class BorrowingDialog extends StatefulWidget {
  final Map<String, dynamic> alat;

  const BorrowingDialog({
    super.key,
    required this.alat,
  });

  @override
  State<BorrowingDialog> createState() => _BorrowingDialogState();
}

class _BorrowingDialogState extends State<BorrowingDialog> {
  final _keperluanController = TextEditingController();
  DateTime? _selectedDate;
  int _jumlahHari = 7; // Default 7 hari
  int _jumlahPinjam = 1;

  @override
  void initState() {
      super.initState();
    // Default tanggal mulai = besok
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }

  DateTime get _tanggalKembali {
    return _selectedDate!.add(Duration(days: _jumlahHari));
  }

  int get _maxJumlah => widget.alat['jumlah_tersedia'] as int;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: BlocConsumer<BorrowingCubit, BorrowingState>(
          listener: (context, state) {
            if (state.status == BorrowingStatus.success) {
              Navigator.pop(context, true); // Return true untuk refresh
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage ?? 'Berhasil mengajukan peminjaman'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state.status == BorrowingStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == BorrowingStatus.submitting;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Form Peminjaman',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: isSubmitting ? null : () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.alat['nama_alat'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tanggal Mulai Pinjam
                        Text(
                          'Tanggal Mulai Pinjam',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: isSubmitting ? null : () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE', 'id_ID').format(_selectedDate!),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Jumlah Hari Pinjam
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Durasi Peminjaman',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Max 7 hari',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$_jumlahHari Hari',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  Row(
                                    children: [
                                      _buildCounterButton(
                                        icon: Icons.remove,
                                        onTap: _jumlahHari > 1 && !isSubmitting
                                            ? () => setState(() => _jumlahHari--)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildCounterButton(
                                        icon: Icons.add,
                                        onTap: _jumlahHari < 7 && !isSubmitting
                                            ? () => setState(() => _jumlahHari++)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: AppColors.border,
                                  thumbColor: AppColors.primary,
                                  overlayColor: AppColors.primary.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _jumlahHari.toDouble(),
                                  min: 1,
                                  max: 7,
                                  divisions: 6,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) => setState(() => _jumlahHari = value.toInt()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tanggal Kembali (Auto Calculate)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.info.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal Kembali',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.info,
                                          ),
                                    ),
                                    Text(
                                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                          .format(_tanggalKembali),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.info,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Jumlah Alat yang Dipinjam
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah Alat',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Tersedia: $_maxJumlah',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _jumlahPinjam > 1 && !isSubmitting
                                  ? () => setState(() => _jumlahPinjam--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.card,
                                foregroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.card.withOpacity(0.5),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '$_jumlahPinjam',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _jumlahPinjam < _maxJumlah && !isSubmitting
                                  ? () => setState(() => _jumlahPinjam++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.card,
                                foregroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.card.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Keperluan (Optional)
                        Text(
                          'Keperluan (Opsional)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _keperluanController,
                          enabled: !isSubmitting,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Jelaskan keperluan peminjaman alat...',
                            filled: true,
                            fillColor: AppColors.card,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _handleSubmit,
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Ajukan Peminjaman'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: onTap != null ? AppColors.primary : AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final maxDate = DateTime(now.year, now.month + 1, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? tomorrow,
      firstDate: tomorrow, // Tidak bisa pilih kemarin atau hari ini
      lastDate: maxDate,
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai pinjam'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Submit peminjaman
    context.read<BorrowingCubit>().submitPeminjamanFromDialog(
          alat: widget.alat,
          tanggalPinjam: _selectedDate!,
          jumlahHari: _jumlahHari,
          jumlahPinjam: _jumlahPinjam,
          keperluan: _keperluanController.text.trim(),
        );
  }
}
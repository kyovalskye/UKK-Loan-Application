import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/models/pengembalian.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_pengembalian_detail_dialog.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_pengembalian_payment_dialog.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_pengembalian_delete_dialog.dart';

class PengembalianCard extends StatelessWidget {
  final Map<String, dynamic> pengembalianData;

  const PengembalianCard({
    super.key,
    required this.pengembalianData,
  });

  // Convert Map to Pengembalian model for easier access
  Pengembalian get pengembalian => Pengembalian.fromMap(pengembalianData);

  @override
  Widget build(BuildContext context) {
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
          onTap: () => _showDetailDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildUserAlatInfo(),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                _buildInfoCards(),
                if (pengembalian.hasLate || pengembalian.hasDamage) ...[
                  const SizedBox(height: 12),
                  _buildWarningBadges(),
                ],
                const SizedBox(height: 12),
                _buildDendaInfo(),
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            pengembalian.kodePeminjaman,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildUserAlatInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.info.withOpacity(0.2),
          child: Text(
            pengembalian.namaUser.isNotEmpty
                ? pengembalian.namaUser[0].toUpperCase()
                : 'U',
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
                pengembalian.namaUser,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                pengembalian.namaAlat,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.event_available,
            label: 'Kembali',
            value: pengembalian.tanggalKembaliActual,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            icon: Icons.build_circle,
            label: 'Kondisi',
            value: pengembalian.kondisiText,
            color: _getKondisiColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (pengembalian.hasLate)
          _WarningChip(
            icon: Icons.schedule,
            text: 'Terlambat ${pengembalian.keterlambatan} hari',
            color: AppColors.warning,
          ),
        if (pengembalian.hasDamage)
          const _WarningChip(
            icon: Icons.warning,
            text: 'Ada kerusakan',
            color: AppColors.error,
          ),
      ],
    );
  }

  Widget _buildDendaInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pengembalian.totalDenda > 0
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: pengembalian.totalDenda > 0
              ? AppColors.error.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Denda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Rp ${_formatCurrency(pengembalian.totalDenda)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pengembalian.totalDenda > 0
                  ? AppColors.error
                  : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (!pengembalian.isLunas) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showPaymentDialog(context),
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Konfirmasi Bayar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () => _showDetailDialog(context),
          icon: const Icon(Icons.visibility, size: 20),
          color: AppColors.info,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.info.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showDeleteDialog(context),
          icon: const Icon(Icons.delete, size: 20),
          color: AppColors.error,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = pengembalian.isLunas ? AppColors.success : AppColors.error;
    final text = pengembalian.isLunas ? 'Lunas' : 'Belum Bayar';

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

  Color _getKondisiColor() {
    switch (pengembalian.kondisiKembali) {
      case 'baik':
        return AppColors.success;
      case 'rusak_ringan':
        return AppColors.warning;
      case 'rusak_berat':
      case 'hilang':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PengembalianDetailDialog(
        pengembalian: pengembalian,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    // Ambil cubit sebelum dialog dibuka
    final cubit = context.read<PengembalianCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => PengembalianPaymentDialog(
        pengembalian: pengembalian,
        cubit: cubit, // Passing cubit ke dialog
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    // Ambil cubit sebelum dialog dibuka
    final cubit = context.read<PengembalianCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => PengembalianDeleteDialog(
        pengembalian: pengembalian,
        cubit: cubit, // Passing cubit ke dialog
      ),
    );
  }
}

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Warning Chip Widget
class _WarningChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _WarningChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
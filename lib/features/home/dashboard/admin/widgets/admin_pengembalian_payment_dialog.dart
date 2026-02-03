import 'package:flutter/material.dart';
import 'package:rentalify/core/models/pengembalian.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_cubit.dart';

class PengembalianPaymentDialog extends StatelessWidget {
  final Pengembalian pengembalian;
  final PengembalianCubit cubit; // Tambahkan parameter cubit

  const PengembalianPaymentDialog({
    super.key,
    required this.pengembalian,
    required this.cubit, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Konfirmasi Pembayaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Konfirmasi pembayaran denda untuk ${pengembalian.kodePeminjaman}?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total yang harus dibayar:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rp ${_formatCurrency(pengembalian.totalDenda)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Gunakan cubit yang di-passing dari parameter
            cubit.updatePaymentStatus(pengembalian.idPengembalian);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: const Text('Konfirmasi'),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
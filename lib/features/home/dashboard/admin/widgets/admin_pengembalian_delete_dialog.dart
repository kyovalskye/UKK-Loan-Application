import 'package:flutter/material.dart';
import 'package:rentalify/core/models/pengembalian.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_cubit.dart';

class PengembalianDeleteDialog extends StatelessWidget {
  final Pengembalian pengembalian;
  final PengembalianCubit cubit; // Tambahkan parameter cubit

  const PengembalianDeleteDialog({
    super.key,
    required this.pengembalian,
    required this.cubit, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Hapus Data Pengembalian'),
      content: Text(
          'Apakah Anda yakin ingin menghapus data pengembalian "${pengembalian.kodePeminjaman}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Gunakan cubit yang di-passing dari parameter
            cubit.deletePengembalian(
              pengembalian.idPengembalian,
              pengembalian.idPeminjaman,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
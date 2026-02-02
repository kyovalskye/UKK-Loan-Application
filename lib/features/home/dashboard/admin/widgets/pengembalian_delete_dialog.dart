import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/model/pengembalian.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_cubit.dart';

class PengembalianDeleteDialog extends StatelessWidget {
  final Pengembalian pengembalian;

  const PengembalianDeleteDialog({
    super.key,
    required this.pengembalian,
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
            context.read<PengembalianCubit>().deletePengembalian(
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
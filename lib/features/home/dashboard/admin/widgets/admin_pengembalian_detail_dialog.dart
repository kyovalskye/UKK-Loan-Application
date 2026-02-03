import 'package:flutter/material.dart';
import 'package:rentalify/core/models/pengembalian.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class PengembalianDetailDialog extends StatelessWidget {
  final Pengembalian pengembalian;

  const PengembalianDetailDialog({
    super.key,
    required this.pengembalian,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(pengembalian.kodePeminjaman),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Peminjam', pengembalian.namaUser),
            _buildDetailRow('Alat', pengembalian.namaAlat),
            _buildDetailRow('Tanggal Pinjam', pengembalian.tanggalPinjam),
            _buildDetailRow(
                'Tanggal Kembali', pengembalian.tanggalKembaliActual),
            _buildDetailRow('Kondisi', pengembalian.kondisiText),
            _buildDetailRow(
                'Keterlambatan', '${pengembalian.keterlambatan} hari'),
            const Divider(color: AppColors.border),
            _buildDetailRow('Denda Keterlambatan',
                'Rp ${_formatCurrency(pengembalian.dendaKeterlambatan)}'),
            _buildDetailRow('Denda Kerusakan',
                'Rp ${_formatCurrency(pengembalian.dendaKerusakan)}'),
            _buildDetailRow(
                'Total Denda', 'Rp ${_formatCurrency(pengembalian.totalDenda)}'),
            const Divider(color: AppColors.border),
            _buildDetailRow('Petugas', pengembalian.namaPetugas),
            const SizedBox(height: 8),
            const Text(
              'Catatan:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pengembalian.catatan.isEmpty ? '-' : pengembalian.catatan,
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
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
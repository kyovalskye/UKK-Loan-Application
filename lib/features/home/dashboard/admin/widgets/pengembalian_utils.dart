import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class PengembalianUtils {
  static String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  static String getKondisiText(String kondisi) {
    const kondisiMap = {
      'baik': 'Baik',
      'rusak_ringan': 'Rusak Ringan',
      'rusak_berat': 'Rusak Berat',
      'hilang': 'Hilang',
    };
    return kondisiMap[kondisi] ?? kondisi;
  }

  static Color getKondisiColor(String kondisi) {
    switch (kondisi) {
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

  static Color getStatusColor(String status) {
    return status == 'lunas' ? AppColors.success : AppColors.error;
  }

  static String getStatusText(String status) {
    return status == 'lunas' ? 'Lunas' : 'Belum Bayar';
  }
}
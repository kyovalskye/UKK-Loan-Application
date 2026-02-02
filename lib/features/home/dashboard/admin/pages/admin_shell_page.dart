import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/admin_dashboard.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_kategori_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_peminjaman_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_user_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/crud_alat_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/crud_kategori_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/crud_peminjaman_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/crud_pengembalian_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/crud_user_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/laporan_page.dart';
import 'package:rentalify/features/home/dashboard/admin/pages/log_aktivitas_page.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_drawer.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = [
    'Dashboard Admin',
    'Kelola Alat',
    'Kelola User',
    'Kelola Kategori',
    'Data Peminjaman',
    'Data Pengembalian',
    'Laporan',
    'Log Aktivitas',
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return AdminDashboard(
          statistics: {
            'totalAlat': 45,
            'totalTersedia': 32,
            'totalDipinjam': 10,
            'terlambat': 3,
            'totalPeminjaman': 156,
            'pendingApproval': 5,
            'activePeminjaman': 10,
          },
        );
      case 1:
        return const CrudAlatPage();
      case 2:
        return const CrudUserPage();
      case 3:
        return const CrudKategoriPage();
      case 4:
        return const CrudPeminjamanPage();
      case 5:
        return const CrudPengembalianPage();
      case 6:
        return const LaporanPage();
      case 7:
        return const LogAktivitasPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CrudKategoriCubit()..fetchKategori(),
        ),
        BlocProvider(
          create: (_) => CrudUserCubit(),
        ),
        BlocProvider(
          create: (_) => CrudPeminjamanCubit()..fetchPeminjaman(),
        ),
        // ✅ FIXED: Tidak ada parameter - PengembalianCubit sudah punya Supabase instance internal
        BlocProvider(
          create: (_) => PengembalianCubit()..loadPengembalian(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_selectedIndex]),
          elevation: 0,
          backgroundColor: AppColors.surface,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        drawer: AdminDrawer(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _buildPage(_selectedIndex),
      ),
    );
  }
}
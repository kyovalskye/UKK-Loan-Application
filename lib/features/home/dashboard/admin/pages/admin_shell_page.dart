import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/admin_dashboard.dart';
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

  final List<Widget> _pages = [
    AdminDashboard(
      statistics: {
        'totalAlat': 45,
        'totalTersedia': 32,
        'totalDipinjam': 10,
        'terlambat': 3,
        'totalPeminjaman': 156,
        'pendingApproval': 5,
        'activePeminjaman': 10,
      },
    ),
    const CrudAlatPage(),
    const CrudUserPage(),
    const CrudKategoriPage(),
    const CrudPeminjamanPage(),
    const CrudPengembalianPage(),
    const LaporanPage(),
    const LogAktivitasPage(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
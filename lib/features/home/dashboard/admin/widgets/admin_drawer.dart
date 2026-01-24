import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/auth/cubit/auth_cubit.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authState.userName ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.userEmail ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Administrator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuSection(
                  context,
                  title: 'DASHBOARD',
                  items: [
                    _MenuItem(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      index: 0,
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                _buildMenuSection(
                  context,
                  title: 'DATA MASTER',
                  items: [
                    _MenuItem(
                      icon: Icons.inventory_2,
                      title: 'Kelola Alat',
                      index: 1,
                    ),
                    _MenuItem(
                      icon: Icons.people,
                      title: 'Kelola User',
                      index: 2,
                    ),
                    _MenuItem(
                      icon: Icons.category,
                      title: 'Kelola Kategori',
                      index: 3,
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                _buildMenuSection(
                  context,
                  title: 'TRANSAKSI',
                  items: [
                    _MenuItem(
                      icon: Icons.assignment,
                      title: 'Data Peminjaman',
                      index: 4,
                    ),
                    _MenuItem(
                      icon: Icons.assignment_return,
                      title: 'Data Pengembalian',
                      index: 5,
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                _buildMenuSection(
                  context,
                  title: 'LAPORAN & LOG',
                  items: [
                    _MenuItem(
                      icon: Icons.assessment,
                      title: 'Laporan',
                      index: 6,
                    ),
                    _MenuItem(
                      icon: Icons.history,
                      title: 'Log Aktivitas',
                      index: 7,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthCubit>().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final isSelected = selectedIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          onItemSelected(item.index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final int index;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
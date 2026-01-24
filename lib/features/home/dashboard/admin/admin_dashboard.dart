import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  final Map<String, int> statistics;

  const AdminDashboard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic handled by parent
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Dashboard Admin',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola dan monitor semua aktivitas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Section
          Text(
            'Statistik Alat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Total Alat',
                  value: statistics['totalAlat']?.toString() ?? '0',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Tersedia',
                  value: statistics['totalTersedia']?.toString() ?? '0',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Dipinjam',
                  value: statistics['totalDipinjam']?.toString() ?? '0',
                  icon: Icons.shopping_bag,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Terlambat',
                  value: statistics['terlambat']?.toString() ?? '0',
                  icon: Icons.warning,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Peminjaman Section
          Text(
            'Statistik Peminjaman',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildLargeStatCard(
            context,
            title: 'Total Peminjaman',
            value: statistics['totalPeminjaman']?.toString() ?? '0',
            subtitle: 'Semua waktu',
            icon: Icons.assignment,
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pending',
                  value: statistics['pendingApproval']?.toString() ?? '0',
                  icon: Icons.pending,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Aktif',
                  value: statistics['activePeminjaman']?.toString() ?? '0',
                  icon: Icons.loop,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          // Text(
          //   'Menu Utama',
          //   style: Theme.of(context).textTheme.titleLarge,
          // ),
          // const SizedBox(height: 12),
          // _buildMenuCard(
          //   context,
          //   title: 'Kelola Alat',
          //   subtitle: 'Tambah, edit, hapus data alat',
          //   icon: Icons.settings,
          //   onTap: () {
          //     // Navigate to alat management
          //   },
          // ),
          // const SizedBox(height: 12),
          // _buildMenuCard(
          //   context,
          //   title: 'Kelola User',
          //   subtitle: 'Manajemen user dan hak akses',
          //   icon: Icons.people,
          //   onTap: () {
          //     // Navigate to user management
          //   },
          // ),
          // const SizedBox(height: 12),
          // _buildMenuCard(
          //   context,
          //   title: 'Laporan',
          //   subtitle: 'Generate dan lihat laporan',
          //   icon: Icons.assessment,
          //   onTap: () {
          //     // Navigate to reports
          //   },
          // ),
          // const SizedBox(height: 12),
          // _buildMenuCard(
          //   context,
          //   title: 'Log Aktivitas',
          //   subtitle: 'Monitor semua aktivitas sistem',
          //   icon: Icons.history,
          //   onTap: () {
          //     // Navigate to activity logs
          //   },
          // ),
          // const SizedBox(height: 80), // Bottom padding for navbar
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
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
      ),
    );
  }
}
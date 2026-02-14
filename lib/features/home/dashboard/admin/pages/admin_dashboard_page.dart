import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_dashboard_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_dashboard_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDashboardCubit()..loadDashboardStatistics(),
      child: const AdminDashboardView(),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminDashboardCubit>().refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminDashboardCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),

                  // Quick Stats Section
                  Text(
                    'Statistik Alat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAlatStats(context, state.statistics),
                  const SizedBox(height: 24),

                  // Peminjaman Stats
                  Text(
                    'Statistik Peminjaman',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPeminjamanStats(context, state.statistics),
                  const SizedBox(height: 24),

                  // User Stats
                  Text(
                    'Statistik Pengguna',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUserStats(context, state.statistics),
                  const SizedBox(height: 24),

                  // Alerts Section
                  if (state.statistics['terlambat'] > 0 ||
                      state.statistics['pendingApproval'] > 0)
                    _buildAlertsSection(context, state.statistics),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, Admin! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola sistem peminjaman alat dengan mudah',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.admin_panel_settings, size: 64, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAlatStats(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Total Alat',
          value: stats['totalAlat'].toString(),
          icon: Icons.inventory_2,
          color: AppColors.primary,
        ),
        _buildStatCard(
          context,
          title: 'Tersedia',
          value: stats['totalTersedia'].toString(),
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        _buildStatCard(
          context,
          title: 'Dipinjam',
          value: stats['totalDipinjam'].toString(),
          icon: Icons.shopping_bag,
          color: AppColors.warning,
        ),
        _buildStatCard(
          context,
          title: 'Maintenance',
          value: stats['totalMaintenance'].toString(),
          icon: Icons.build,
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildPeminjamanStats(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Total Peminjaman',
          value: stats['totalPeminjaman'].toString(),
          icon: Icons.assignment,
          color: AppColors.primary,
        ),
        _buildStatCard(
          context,
          title: 'Perlu Approval',
          value: stats['pendingApproval'].toString(),
          icon: Icons.pending_actions,
          color: AppColors.warning,
          showBadge: stats['pendingApproval'] > 0,
        ),
        _buildStatCard(
          context,
          title: 'Aktif Dipinjam',
          value: stats['activePeminjaman'].toString(),
          icon: Icons.timelapse,
          color: AppColors.info,
        ),
        _buildStatCard(
          context,
          title: 'Terlambat',
          value: stats['terlambat'].toString(),
          icon: Icons.warning,
          color: AppColors.error,
          showBadge: stats['terlambat'] > 0,
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Total Pengguna',
          value: stats['totalUsers'].toString(),
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _buildStatCard(
          context,
          title: 'Peminjam',
          value: stats['totalPeminjam'].toString(),
          icon: Icons.person,
          color: AppColors.info,
        ),
        _buildStatCard(
          context,
          title: 'Admin',
          value: stats['totalAdmin'].toString(),
          icon: Icons.admin_panel_settings,
          color: AppColors.primaryLight,
        ),
        _buildStatCard(
          context,
          title: 'Petugas',
          value: stats['totalPetugas'].toString(),
          icon: Icons.badge,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool showBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perhatian',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (stats['terlambat'] > 0)
          _buildAlertCard(
            context,
            icon: Icons.warning_amber,
            iconColor: AppColors.error,
            title: 'Peminjaman Terlambat',
            message:
                'Ada ${stats['terlambat']} peminjaman yang terlambat dikembalikan',
            actionLabel: 'Lihat Detail',
          ),
        if (stats['pendingApproval'] > 0) ...[
          if (stats['terlambat'] > 0) const SizedBox(height: 12),
          _buildAlertCard(
            context,
            icon: Icons.pending_actions,
            iconColor: AppColors.warning,
            title: 'Menunggu Approval',
            message:
                'Ada ${stats['pendingApproval']} peminjaman menunggu persetujuan',
            actionLabel: 'Proses',
          ),
        ],
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

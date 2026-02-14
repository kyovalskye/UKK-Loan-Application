import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/staff/pages/staff_approval_page.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../dashboard/admin/admin_dashboard.dart';
import '../dashboard/borrower/borrower_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final role = context.read<AuthCubit>().state.userRole;
    if (role != null) {
      context.read<HomeCubit>().refresh(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          // ⭐ PERUBAHAN: Admin tidak perlu AppBar di sini karena sudah ada di AdminShellPage
          appBar: authState.userRole == 'admin' 
              ? null 
              : AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        authState.userName ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRoleColor(authState.userRole).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getRoleColor(authState.userRole),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(authState.userRole),
                            size: 16,
                            color: _getRoleColor(authState.userRole),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getRoleLabel(authState.userRole),
                            style: TextStyle(
                              color: _getRoleColor(authState.userRole),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == HomeStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi Kesalahan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? 'Error',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              // Render berbeda berdasarkan role
              if (authState.isAdmin) {
                return AdminDashboard(statistics: state.statistics);
              } else if (authState.isPetugas) {
                // ✅ FIXED: StaffApprovalPage tidak perlu parameter requests
                // Karena sudah punya BlocProvider internal yang load data sendiri
                return const StaffApprovalPage();
              } else if (authState.isPeminjam) {
                return BorrowerDashboard(alatList: state.alatList);
              }

              return const Center(child: Text('Role tidak dikenali'));
            },
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'petugas':
        return 'Petugas';
      case 'peminjam':
        return 'Peminjam';
      default:
        return 'User';
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'petugas':
        return Icons.badge;
      case 'peminjam':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'petugas':
        return AppColors.info;
      case 'peminjam':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
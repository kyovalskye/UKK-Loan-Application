import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_state.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_pengembalian_card.dart';
import 'package:rentalify/features/home/dashboard/admin/widgets/admin_pengembalian_form_dialog.dart';
import 'package:rentalify/core/themes/app_colors.dart';

/// Main page - Tidak perlu BlocProvider lagi karena sudah ada di AdminShellPage
class CrudPengembalianPage extends StatelessWidget {
  const CrudPengembalianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CrudPengembalianPageContent();
  }
}

/// The actual page content
class _CrudPengembalianPageContent extends StatefulWidget {
  const _CrudPengembalianPageContent();

  @override
  State<_CrudPengembalianPageContent> createState() =>
      _CrudPengembalianPageContentState();
}

class _CrudPengembalianPageContentState
    extends State<_CrudPengembalianPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PengembalianCubit, PengembalianState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchAndFilter(state),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPengembalianDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Proses Pengembalian'),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PengembalianState state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (state is PengembalianError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PengembalianOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PengembalianOperationLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(state.operation)),
            ],
          ),
          duration: const Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSearchAndFilter(PengembalianState state) {
    String currentStatusFilter = 'Semua';

    if (state is PengembalianLoaded) {
      currentStatusFilter = state.statusFilter;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengembalian...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<PengembalianCubit>().searchPengembalian('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              context.read<PengembalianCubit>().searchPengembalian(value);
            },
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            label: 'Status Pembayaran',
            value: currentStatusFilter,
            items: const ['Semua', 'Belum Bayar', 'Lunas'],
            onChanged: (value) {
              if (value != null) {
                context.read<PengembalianCubit>().filterByStatus(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PengembalianState state) {
    if (state is PengembalianLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PengembalianLoaded) {
      final filteredList = state.filteredList;

      if (filteredList.isEmpty) {
        return _buildEmptyState(state);
      }

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<PengembalianCubit>().loadPengembalian();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final pengembalianMap = filteredList[index];
            return PengembalianCard(pengembalianData: pengembalianMap);
          },
        ),
      );
    }

    if (state is PengembalianError) {
      return _buildErrorState(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(PengembalianLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty || state.statusFilter != 'Semua'
                ? 'Tidak ada data yang sesuai'
                : 'Belum ada data pengembalian',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PengembalianError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PengembalianCubit>().loadPengembalian();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _showPengembalianDialog() async {
    try {
      final cubit = context.read<PengembalianCubit>();
      final activePeminjaman = await cubit.getActivePeminjaman();

      if (!mounted) return;

      if (activePeminjaman.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada peminjaman aktif'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (dialogContext) => PengembalianFormDialog(
          cubit: cubit,
          activePeminjaman: activePeminjaman,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
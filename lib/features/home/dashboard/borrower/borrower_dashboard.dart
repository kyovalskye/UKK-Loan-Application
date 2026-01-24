import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/modules/borrowing/cubit/borrowing_cubit.dart';
import 'package:rentalify/features/modules/borrowing/widgets/borrowing_dialog.dart';
import '../../cubit/home_cubit.dart';

class BorrowerDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> alatList;

  const BorrowerDashboard({
    super.key,
    required this.alatList,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic handled by parent
      },
      child: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alat Tersedia',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih alat yang ingin Anda pinjam',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Empty State
          if (alatList.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada alat tersedia',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua alat sedang dipinjam',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            // Alat List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final alat = alatList[index];
                    return _buildAlatCard(context, alat);
                  },
                  childCount: alatList.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Bottom padding for navbar
          ),
        ],
      ),
    );
  }

  Widget _buildAlatCard(BuildContext context, Map<String, dynamic> alat) {
    final jumlahTersedia = alat['jumlah_tersedia'] as int;
    final isAvailable = jumlahTersedia > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isAvailable ? AppColors.cardGradient : null,
        color: isAvailable ? null : AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? AppColors.border : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable
              ? () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => BlocProvider.value(
                      value: context.read<BorrowingCubit>(),
                      child: BorrowingDialog(alat: alat),
                    ),
                  );

                  // Refresh data if dialog returned true (success)
                  if (result == true && context.mounted) {
                    context.read<HomeCubit>().loadAlatTersedia();
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: alat['foto_alat'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: alat['foto_alat'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.build_circle,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.build_circle,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                    ),
                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat['nama_alat'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isAvailable
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (alat['kategori'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? AppColors.primary.withOpacity(0.2)
                                    : AppColors.textTertiary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                alat['kategori'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isAvailable
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isAvailable ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: isAvailable ? AppColors.success : AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable
                                    ? '$jumlahTersedia tersedia'
                                    : 'Stok habis',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isAvailable
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow or Lock Icon
                    Icon(
                      isAvailable ? Icons.arrow_forward_ios : Icons.lock_outline,
                      size: 16,
                      color: isAvailable ? AppColors.textTertiary : AppColors.error,
                    ),
                  ],
                ),
              ),

              // Overlay abu-abu kalau stok habis
              if (!isAvailable)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tidak Tersedia',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
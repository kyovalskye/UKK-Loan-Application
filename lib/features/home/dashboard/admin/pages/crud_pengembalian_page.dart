import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_pengembalian_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudPengembalianPage extends StatefulWidget {
  const CrudPengembalianPage({super.key});

  @override
  State<CrudPengembalianPage> createState() => _CrudPengembalianPageState();
}

class _CrudPengembalianPageState extends State<CrudPengembalianPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load pengembalian data on init
    context.read<PengembalianCubit>().loadPengembalian();
  }

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
        listener: (context, state) {
          if (state is PengembalianError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PengembalianOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PengembalianOperationLoading) {
            // Show loading indicator in snackbar
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
                    Text(state.operation),
                  ],
                ),
                duration: const Duration(seconds: 10),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search & Filter
              _buildSearchAndFilter(state),

              // List
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPengembalianDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Proses Pengembalian'),
      ),
    );
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
            items: ['Semua', 'Belum Bayar', 'Lunas'],
            onChanged: (value) {
              context.read<PengembalianCubit>().filterByStatus(value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PengembalianState state) {
    if (state is PengembalianLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PengembalianLoaded) {
      final filteredList = state.filteredList;

      if (filteredList.isEmpty) {
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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final pengembalian = filteredList[index];
          return _buildPengembalianCard(pengembalian);
        },
      );
    }

    if (state is PengembalianError) {
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
            Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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

    return const SizedBox.shrink();
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

  Widget _buildPengembalianCard(Map<String, dynamic> pengembalian) {
    final hasLate = pengembalian['keterlambatan'] > 0;
    final hasDamage = pengembalian['denda_kerusakan'] > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(pengembalian),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pengembalian['kode_peminjaman'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(pengembalian['status_pembayaran']),
                  ],
                ),
                const SizedBox(height: 12),

                // User & Alat Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        pengembalian['nama_user'][0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pengembalian['nama_user'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            pengembalian['nama_alat'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.event_available,
                        label: 'Kembali',
                        value: pengembalian['tanggal_kembali_actual'],
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.build_circle,
                        label: 'Kondisi',
                        value: _getKondisiText(pengembalian['kondisi_kembali']),
                        color: _getKondisiColor(pengembalian['kondisi_kembali']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Warning Badges
                if (hasLate || hasDamage) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasLate)
                        _buildWarningChip(
                          Icons.schedule,
                          'Terlambat ${pengembalian['keterlambatan']} hari',
                          AppColors.warning,
                        ),
                      if (hasDamage)
                        _buildWarningChip(
                          Icons.warning,
                          'Ada kerusakan',
                          AppColors.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Denda Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: pengembalian['total_denda'] > 0
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: pengembalian['total_denda'] > 0
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Denda',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(pengembalian['total_denda'])}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: pengembalian['total_denda'] > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (pengembalian['status_pembayaran'] == 'belum_bayar')
                      ElevatedButton.icon(
                        onPressed: () => _showPaymentDialog(pengembalian),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Konfirmasi Bayar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      )
                    else
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _showDetailDialog(pengembalian),
                            icon: const Icon(Icons.visibility, size: 20),
                            color: AppColors.info,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.info.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showDeleteDialog(pengembalian),
                            icon: const Icon(Icons.delete, size: 20),
                            color: AppColors.error,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.error.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    if (status == 'lunas') {
      color = AppColors.success;
      text = 'Lunas';
    } else {
      color = AppColors.error;
      text = 'Belum Bayar';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getKondisiText(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return 'Baik';
      case 'rusak_ringan':
        return 'Rusak Ringan';
      case 'rusak_berat':
        return 'Rusak Berat';
      case 'hilang':
        return 'Hilang';
      default:
        return kondisi;
    }
  }

  Color _getKondisiColor(String kondisi) {
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showPengembalianDialog() async {
    try {
      // Get active peminjaman
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

      showDialog(
        context: context,
        builder: (dialogContext) => _PengembalianFormDialog(
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

  void _showDetailDialog(Map<String, dynamic> pengembalian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(pengembalian['kode_peminjaman']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Peminjam', pengembalian['nama_user']),
              _buildDetailRow('Alat', pengembalian['nama_alat']),
              _buildDetailRow('Tanggal Pinjam', pengembalian['tanggal_pinjam']),
              _buildDetailRow('Tanggal Kembali', pengembalian['tanggal_kembali_actual']),
              _buildDetailRow('Kondisi', _getKondisiText(pengembalian['kondisi_kembali'])),
              _buildDetailRow('Keterlambatan', '${pengembalian['keterlambatan']} hari'),
              const Divider(color: AppColors.border),
              _buildDetailRow('Denda Keterlambatan', 'Rp ${_formatCurrency(pengembalian['denda_keterlambatan'])}'),
              _buildDetailRow('Denda Kerusakan', 'Rp ${_formatCurrency(pengembalian['denda_kerusakan'])}'),
              _buildDetailRow('Total Denda', 'Rp ${_formatCurrency(pengembalian['total_denda'])}'),
              const Divider(color: AppColors.border),
              _buildDetailRow('Petugas', pengembalian['nama_petugas'] ?? 'Unknown'),
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
                pengembalian['catatan'].isEmpty ? '-' : pengembalian['catatan'],
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
      ),
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

  void _showPaymentDialog(Map<String, dynamic> pengembalian) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfirmasi pembayaran denda untuk ${pengembalian['kode_peminjaman']}?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total yang harus dibayar:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Rp ${_formatCurrency(pengembalian['total_denda'])}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PengembalianCubit>().updatePaymentStatus(
                    pengembalian['id_pengembalian'],
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> pengembalian) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Data Pengembalian'),
        content: Text('Apakah Anda yakin ingin menghapus data pengembalian "${pengembalian['kode_peminjaman']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PengembalianCubit>().deletePengembalian(
                    pengembalian['id_pengembalian'],
                    pengembalian['id_peminjaman'],
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Form Dialog Widget
class _PengembalianFormDialog extends StatefulWidget {
  final List<Map<String, dynamic>> activePeminjaman;

  const _PengembalianFormDialog({
    required this.activePeminjaman,
  });

  @override
  State<_PengembalianFormDialog> createState() => _PengembalianFormDialogState();
}

class _PengembalianFormDialogState extends State<_PengembalianFormDialog> {
  Map<String, dynamic>? _selectedPeminjaman;
  String _selectedKondisi = 'baik';
  final TextEditingController _catatanController = TextEditingController();
  
  int _keterlambatan = 0;
  double _dendaKeterlambatan = 0;
  double _dendaKerusakan = 0;
  double _totalDenda = 0;
  
  bool _isCalculating = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _calculateDenda() async {
    if (_selectedPeminjaman == null) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      final tanggalKembaliRencana = DateTime.parse(_selectedPeminjaman!['tanggal_kembali_rencana']);
      
      final result = await context.read<PengembalianCubit>().calculateDenda(
            tanggalKembaliRencana: tanggalKembaliRencana,
            kondisi: _selectedKondisi,
          );

      setState(() {
        _keterlambatan = result['keterlambatan'];
        _dendaKeterlambatan = result['denda_keterlambatan'];
        _dendaKerusakan = result['denda_kerusakan'];
        _totalDenda = result['total_denda'];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghitung denda: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Proses Pengembalian'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Peminjaman',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedPeminjaman,
                  isExpanded: true,
                  hint: const Text('Pilih peminjaman'),
                  dropdownColor: AppColors.surface,
                  items: widget.activePeminjaman.map((peminjaman) {
                    return DropdownMenuItem(
                      value: peminjaman,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            peminjaman['kode_peminjaman'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${peminjaman['users']['nama']} - ${peminjaman['alat']['nama_alat']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeminjaman = value;
                    });
                    _calculateDenda();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kondisi Saat Kembali',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKondisi,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'baik', child: Text('Baik')),
                    DropdownMenuItem(value: 'rusak_ringan', child: Text('Rusak Ringan')),
                    DropdownMenuItem(value: 'rusak_berat', child: Text('Rusak Berat')),
                    DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedKondisi = value!;
                    });
                    _calculateDenda();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Masukkan catatan pengembalian (opsional)',
                alignLabelWithHint: true,
              ),
            ),
            if (_selectedPeminjaman != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              if (_isCalculating)
                const Center(child: CircularProgressIndicator())
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _totalDenda > 0
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _totalDenda > 0
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDendaRow('Keterlambatan', '$_keterlambatan hari'),
                      const SizedBox(height: 8),
                      _buildDendaRow('Denda Keterlambatan', 'Rp ${_formatCurrency(_dendaKeterlambatan.toInt())}'),
                      _buildDendaRow('Denda Kerusakan', 'Rp ${_formatCurrency(_dendaKerusakan.toInt())}'),
                      const Divider(color: AppColors.border),
                      _buildDendaRow(
                        'Total Denda',
                        'Rp ${_formatCurrency(_totalDenda.toInt())}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _selectedPeminjaman == null
              ? null
              : () async {
                  final currentUser = Supabase.instance.client.auth.currentUser;
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User tidak terautentikasi'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  context.read<PengembalianCubit>().createPengembalian(
                        idPeminjaman: _selectedPeminjaman!['id_peminjaman'],
                        kondisiSaatKembali: _selectedKondisi,
                        catatanPengembalian: _catatanController.text,
                        keterlambatanHari: _keterlambatan,
                        dendaKeterlambatan: _dendaKeterlambatan,
                        dendaKerusakan: _dendaKerusakan,
                        idPetugas: currentUser.id,
                      );
                },
          child: const Text('Proses'),
        ),
      ],
    );
  }

  Widget _buildDendaRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
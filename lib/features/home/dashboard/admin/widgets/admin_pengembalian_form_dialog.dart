import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_crud_pengembalian_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianFormDialog extends StatefulWidget {
  final PengembalianCubit cubit;
  final List<Map<String, dynamic>> activePeminjaman;

  const PengembalianFormDialog({
    super.key,
    required this.cubit,
    required this.activePeminjaman,
  });

  @override
  State<PengembalianFormDialog> createState() => _PengembalianFormDialogState();
}

class _PengembalianFormDialogState extends State<PengembalianFormDialog> {
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

    setState(() => _isCalculating = true);

    try {
      final tanggalKembaliRencana =
          DateTime.parse(_selectedPeminjaman!['tanggal_kembali_rencana']);

      final result = await widget.cubit.calculateDenda(
        tanggalKembaliRencana: tanggalKembaliRencana,
        kondisi: _selectedKondisi,
      );

      if (!mounted) return;

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
      if (mounted) {
        setState(() => _isCalculating = false);
      }
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
            _buildPeminjamanDropdown(),
            const SizedBox(height: 16),
            _buildKondisiDropdown(),
            const SizedBox(height: 16),
            _buildCatatanField(),
            if (_selectedPeminjaman != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              _buildDendaSummary(),
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
          onPressed: _selectedPeminjaman == null ? null : _handleSubmit,
          child: const Text('Proses'),
        ),
      ],
    );
  }

  Widget _buildPeminjamanDropdown() {
    return Column(
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
                        peminjaman['kode_peminjaman'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${peminjaman['users']?['nama'] ?? 'Unknown'} - ${peminjaman['alat']?['nama_alat'] ?? 'Unknown'}',
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
                setState(() => _selectedPeminjaman = value);
                _calculateDenda();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKondisiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                DropdownMenuItem(
                    value: 'rusak_ringan', child: Text('Rusak Ringan')),
                DropdownMenuItem(
                    value: 'rusak_berat', child: Text('Rusak Berat')),
                DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedKondisi = value);
                  _calculateDenda();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanField() {
    return TextField(
      controller: _catatanController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        hintText: 'Masukkan catatan pengembalian (opsional)',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildDendaSummary() {
    if (_isCalculating) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
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
          _buildDendaRow('Denda Keterlambatan',
              'Rp ${_formatCurrency(_dendaKeterlambatan.toInt())}'),
          _buildDendaRow('Denda Kerusakan',
              'Rp ${_formatCurrency(_dendaKerusakan.toInt())}'),
          const Divider(color: AppColors.border),
          _buildDendaRow(
            'Total Denda',
            'Rp ${_formatCurrency(_totalDenda.toInt())}',
            isBold: true,
          ),
        ],
      ),
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

  Future<void> _handleSubmit() async {
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

    if (_selectedPeminjaman == null) return;

    Navigator.pop(context);

    widget.cubit.createPengembalian(
      idPeminjaman: _selectedPeminjaman!['id_peminjaman'],
      kondisiSaatKembali: _selectedKondisi,
      catatanPengembalian: _catatanController.text,
      keterlambatanHari: _keterlambatan,
      dendaKeterlambatan: _dendaKeterlambatan,
      dendaKerusakan: _dendaKerusakan,
      idPetugas: currentUser.id,
    );
  }
}
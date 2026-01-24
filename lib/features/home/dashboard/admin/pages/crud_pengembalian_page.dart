import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudPengembalianPage extends StatefulWidget {
  const CrudPengembalianPage({super.key});

  @override
  State<CrudPengembalianPage> createState() => _CrudPengembalianPageState();
}

class _CrudPengembalianPageState extends State<CrudPengembalianPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Semua';

  // Dummy data
  final List<Map<String, dynamic>> _pengembalianList = [
    {
      'id': 1,
      'kode_peminjaman': 'PMJ-2024-001',
      'nama_user': 'John Doe',
      'nama_alat': 'OBD2 Scanner Launch X431 Pro',
      'kategori': 'Diagnostic Tools',
      'jumlah': 1,
      'tanggal_pinjam': '2024-01-10',
      'tanggal_kembali_rencana': '2024-01-17',
      'tanggal_kembali_actual': '2024-01-20',
      'kondisi_kembali': 'baik',
      'keterlambatan': 3,
      'denda_keterlambatan': 15000,
      'denda_kerusakan': 0,
      'total_denda': 15000,
      'status_pembayaran': 'belum_bayar',
      'catatan': 'Dikembalikan dalam kondisi baik',
    },
    {
      'id': 2,
      'kode_peminjaman': 'PMJ-2024-005',
      'nama_user': 'Jane Smith',
      'nama_alat': 'Hydraulic Jack 3 Ton',
      'kategori': 'Hand Tools',
      'jumlah': 2,
      'tanggal_pinjam': '2024-01-15',
      'tanggal_kembali_rencana': '2024-01-22',
      'tanggal_kembali_actual': '2024-01-22',
      'kondisi_kembali': 'rusak_ringan',
      'keterlambatan': 0,
      'denda_keterlambatan': 0,
      'denda_kerusakan': 50000,
      'total_denda': 50000,
      'status_pembayaran': 'lunas',
      'catatan': 'Ada sedikit kerusakan pada handle',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search & Filter
          Container(
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
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _buildFilterDropdown(
                  label: 'Status Pembayaran',
                  value: _selectedStatusFilter,
                  items: ['Semua', 'Belum Bayar', 'Lunas'],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pengembalianList.length,
              itemBuilder: (context, index) {
                final pengembalian = _pengembalianList[index];
                return _buildPengembalianCard(pengembalian);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPengembalianDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Proses Pengembalian'),
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

  void _showPengembalianDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Proses Pengembalian'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Form pengembalian akan ditampilkan di sini'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengembalian berhasil diproses'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Proses'),
          ),
        ],
      ),
    );
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
                pengembalian['catatan'],
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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran berhasil dikonfirmasi'),
                  backgroundColor: AppColors.success,
                ),
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Data Pengembalian'),
        content: Text('Apakah Anda yakin ingin menghapus data pengembalian "${pengembalian['kode_peminjaman']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data pengembalian berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class StaffPengembalianPage extends StatefulWidget {
  const StaffPengembalianPage({super.key});

  @override
  State<StaffPengembalianPage> createState() => _StaffPengembalianPageState();
}

class _StaffPengembalianPageState extends State<StaffPengembalianPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Semua';

  // Dummy data - peminjaman yang sedang dipinjam
  final List<Map<String, dynamic>> _peminjamanAktif = [
    {
      'id_peminjaman': 1,
      'kode_peminjaman': 'PMJ-2024-001',
      'user': {
        'nama': 'John Doe',
        'email': 'john@example.com',
      },
      'alat': {
        'nama_alat': 'OBD2 Scanner Launch X431 Pro',
        'kategori': 'Diagnostic Tools',
        'foto_alat': null,
      },
      'jumlah_pinjam': 1,
      'tanggal_pinjam': '2024-01-15',
      'tanggal_kembali_rencana': '2024-01-22',
      'status_peminjaman': 'dipinjam',
      'keperluan': 'Untuk diagnosis kendaraan pelanggan',
      'created_at': '2024-01-15T08:00:00',
    },
    {
      'id_peminjaman': 2,
      'kode_peminjaman': 'PMJ-2024-003',
      'user': {
        'nama': 'Jane Smith',
        'email': 'jane@example.com',
      },
      'alat': {
        'nama_alat': 'Hydraulic Jack 3 Ton',
        'kategori': 'Hand Tools',
        'foto_alat': null,
      },
      'jumlah_pinjam': 2,
      'tanggal_pinjam': '2024-01-10',
      'tanggal_kembali_rencana': '2024-01-17',
      'status_peminjaman': 'terlambat',
      'keperluan': 'Untuk servis kendaraan',
      'created_at': '2024-01-10T09:30:00',
    },
    {
      'id_peminjaman': 3,
      'kode_peminjaman': 'PMJ-2024-005',
      'user': {
        'nama': 'Bob Wilson',
        'email': 'bob@example.com',
      },
      'alat': {
        'nama_alat': 'Impact Wrench Makita',
        'kategori': 'Power Tools',
        'foto_alat': null,
      },
      'jumlah_pinjam': 1,
      'tanggal_pinjam': '2024-01-18',
      'tanggal_kembali_rencana': '2024-01-25',
      'status_peminjaman': 'dipinjam',
      'keperluan': 'Untuk pemasangan ban',
      'created_at': '2024-01-18T14:00:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pemantauan Pengembalian'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh
        },
        child: Column(
          children: [
            // Search & Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari peminjaman...',
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
                  // Filter
                  _buildFilterDropdown(
                    label: 'Status',
                    value: _selectedStatusFilter,
                    items: ['Semua', 'Dipinjam', 'Terlambat'],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_return,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peminjaman Aktif',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${_peminjamanAktif.length} Total',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_peminjamanAktif.where((p) => p['status_peminjaman'] == 'terlambat').length} Terlambat',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _peminjamanAktif.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada peminjaman aktif',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Semua alat sudah dikembalikan',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _peminjamanAktif.length,
                      itemBuilder: (context, index) {
                        final peminjaman = _peminjamanAktif[index];
                        return _buildPeminjamanCard(peminjaman);
                      },
                    ),
            ),
          ],
        ),
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

  Widget _buildPeminjamanCard(Map<String, dynamic> peminjaman) {
    final user = peminjaman['user'];
    final alat = peminjaman['alat'];
    final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final tanggalKembaliRencana = DateTime.parse(peminjaman['tanggal_kembali_rencana']);
    final isLate = peminjaman['status_peminjaman'] == 'terlambat';
    final today = DateTime.now();
    final daysLate = isLate ? today.difference(tanggalKembaliRencana).inDays : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLate ? AppColors.error.withOpacity(0.5) : AppColors.border,
          width: isLate ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(peminjaman),
          borderRadius: BorderRadius.circular(16),
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
                        peminjaman['kode_peminjaman'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(peminjaman['status_peminjaman']),
                  ],
                ),
                
                if (isLate) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Text(
                          'Terlambat $daysLate hari',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        user['nama'][0].toUpperCase(),
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
                            user['nama'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            user['email'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
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

                // Alat Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat['nama_alat'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alat['kategori']} • Jumlah: ${peminjaman['jumlah_pinjam']}',
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

                // Date Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          Icons.calendar_today,
                          'Dipinjam',
                          DateFormat('dd MMM yyyy').format(tanggalPinjam),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _buildDateInfo(
                          Icons.event,
                          'Jatuh Tempo',
                          DateFormat('dd MMM yyyy').format(tanggalKembaliRencana),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPengembalianDialog(peminjaman),
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Proses Pengembalian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
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
          date,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    if (status == 'terlambat') {
      color = AppColors.error;
      text = 'Terlambat';
    } else {
      color = AppColors.success;
      text = 'Dipinjam';
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

  void _showDetailDialog(Map<String, dynamic> peminjaman) {
    final user = peminjaman['user'];
    final alat = peminjaman['alat'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(peminjaman['kode_peminjaman']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Peminjam', user['nama']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Alat', alat['nama_alat']),
              _buildDetailRow('Kategori', alat['kategori']),
              _buildDetailRow('Jumlah', '${peminjaman['jumlah_pinjam']} unit'),
              _buildDetailRow('Tanggal Pinjam', peminjaman['tanggal_pinjam']),
              _buildDetailRow('Tanggal Kembali', peminjaman['tanggal_kembali_rencana']),
              const Divider(color: AppColors.border),
              const Text(
                'Keperluan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                peminjaman['keperluan'] ?? '-',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPengembalianDialog(peminjaman);
            },
            child: const Text('Proses Pengembalian'),
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
            width: 120,
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

  void _showPengembalianDialog(Map<String, dynamic> peminjaman) {
    final tanggalKembaliRencana = DateTime.parse(peminjaman['tanggal_kembali_rencana']);
    final today = DateTime.now();
    final keterlambatan = today.isAfter(tanggalKembaliRencana) 
        ? today.difference(tanggalKembaliRencana).inDays 
        : 0;
    
    String selectedKondisi = 'baik';
    final catatanController = TextEditingController();
    final dendaPerHari = 5000; // Dummy setting
    final dendaKeterlambatan = keterlambatan * dendaPerHari;
    int dendaKerusakan = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Calculate denda kerusakan based on kondisi
          switch (selectedKondisi) {
            case 'rusak_ringan':
              dendaKerusakan = 50000;
              break;
            case 'rusak_berat':
              dendaKerusakan = 200000;
              break;
            case 'hilang':
              dendaKerusakan = 500000; // Dummy price
              break;
            default:
              dendaKerusakan = 0;
          }
          
          final totalDenda = dendaKeterlambatan + dendaKerusakan;
          
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Proses Pengembalian'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peminjaman['kode_peminjaman'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kondisi Alat
                  const Text(
                    'Kondisi Alat Saat Dikembalikan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedKondisi,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.build_circle),
                    ),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: 'baik', child: Text('Baik')),
                      DropdownMenuItem(value: 'rusak_ringan', child: Text('Rusak Ringan')),
                      DropdownMenuItem(value: 'rusak_berat', child: Text('Rusak Berat')),
                      DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedKondisi = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Catatan
                  TextField(
                    controller: catatanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Pengembalian',
                      hintText: 'Tambahkan catatan jika diperlukan...',
                      prefixIcon: Icon(Icons.note),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Denda
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildDendaRow('Keterlambatan', '$keterlambatan hari', 'Rp ${_formatCurrency(dendaKeterlambatan)}'),
                        if (dendaKerusakan > 0) ...[
                          const Divider(color: AppColors.border),
                          _buildDendaRow('Kerusakan', selectedKondisi == 'hilang' ? 'Hilang' : 'Rusak', 'Rp ${_formatCurrency(dendaKerusakan)}'),
                        ],
                        const Divider(color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Denda',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(totalDenda)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: totalDenda > 0 ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  if (totalDenda > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Peminjam harus membayar denda sebelum bisa meminjam lagi',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
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
                onPressed: () {
                  // TODO: Implement save pengembalian
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengembalian berhasil diproses'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Proses'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDendaRow(String label, String desc, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  String _selectedTableFilter = 'Semua';
  String _selectedOperasiFilter = 'Semua';

  // Dummy data
  final List<Map<String, dynamic>> _logList = [
    {
      'id': 1,
      'user_nama': 'Admin User',
      'user_email': 'admin@example.com',
      'nama_tabel': 'peminjaman',
      'operasi': 'INSERT',
      'waktu': '2024-01-22 14:30:00',
      'data_baru': {
        'kode_peminjaman': 'PMJ-2024-015',
        'nama_alat': 'OBD2 Scanner Launch X431 Pro',
        'jumlah': 1,
        'tanggal_pinjam': '2024-01-22',
        'tanggal_kembali': '2024-01-29',
        'keperluan': 'Untuk diagnosis kendaraan',
      },
    },
    {
      'id': 2,
      'user_nama': 'Petugas 1',
      'user_email': 'petugas@example.com',
      'nama_tabel': 'peminjaman',
      'operasi': 'UPDATE',
      'waktu': '2024-01-22 13:15:00',
      'data_lama': {
        'status': 'diajukan',
      },
      'data_baru': {
        'status': 'disetujui',
        'catatan_admin': 'Peminjaman disetujui',
      },
    },
    {
      'id': 3,
      'user_nama': 'Admin User',
      'user_email': 'admin@example.com',
      'nama_tabel': 'alat',
      'operasi': 'UPDATE',
      'waktu': '2024-01-22 12:00:00',
      'data_lama': {
        'jumlah_tersedia': 5,
        'status': 'tersedia',
      },
      'data_baru': {
        'jumlah_tersedia': 4,
        'status': 'dipinjam',
      },
    },
    {
      'id': 4,
      'user_nama': 'Admin User',
      'user_email': 'admin@example.com',
      'nama_tabel': 'users',
      'operasi': 'INSERT',
      'waktu': '2024-01-22 10:30:00',
      'data_baru': {
        'nama': 'John Doe',
        'email': 'john@example.com',
        'role': 'peminjam',
      },
    },
    {
      'id': 5,
      'user_nama': 'Petugas 1',
      'user_email': 'petugas@example.com',
      'nama_tabel': 'pengembalian',
      'operasi': 'INSERT',
      'waktu': '2024-01-22 09:45:00',
      'data_baru': {
        'kode_peminjaman': 'PMJ-2024-012',
        'kondisi_kembali': 'baik',
        'keterlambatan': 2,
        'denda_keterlambatan': 10000,
        'total_denda': 10000,
      },
    },
    {
      'id': 6,
      'user_nama': 'Admin User',
      'user_email': 'admin@example.com',
      'nama_tabel': 'alat',
      'operasi': 'DELETE',
      'waktu': '2024-01-21 16:20:00',
      'data_lama': {
        'nama_alat': 'Old Tool (Broken)',
        'kategori': 'Hand Tools',
        'status': 'rusak_berat',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Tabel',
                        value: _selectedTableFilter,
                        items: [
                          'Semua',
                          'Alat',
                          'Users',
                          'Peminjaman',
                          'Pengembalian',
                          'Kategori'
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTableFilter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Operasi',
                        value: _selectedOperasiFilter,
                        items: ['Semua', 'INSERT', 'UPDATE', 'DELETE'],
                        onChanged: (value) {
                          setState(() {
                            _selectedOperasiFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeline List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logList.length,
              itemBuilder: (context, index) {
                final log = _logList[index];
                final isLast = index == _logList.length - 1;
                return _buildTimelineItem(log, isLast);
              },
            ),
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

  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getOperasiColor(log['operasi']).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getOperasiColor(log['operasi']),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getOperasiIcon(log['operasi']),
                  color: _getOperasiColor(log['operasi']),
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildLogCard(log),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(log),
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
                      child: Row(
                        children: [
                          _buildOperasiBadge(log['operasi']),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log['nama_tabel'].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        log['user_nama'][0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['user_nama'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            log['user_email'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log['waktu'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Preview Data
                if (log['operasi'] == 'INSERT' || log['operasi'] == 'UPDATE') ...[
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  _buildDataPreview(log),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperasiBadge(String operasi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getOperasiColor(operasi).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        operasi,
        style: TextStyle(
          color: _getOperasiColor(operasi),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDataPreview(Map<String, dynamic> log) {
    final dataBaru = log['data_baru'] as Map<String, dynamic>?;
    if (dataBaru == null || dataBaru.isEmpty) return const SizedBox.shrink();

    final entries = dataBaru.entries.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Data:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      TextSpan(
                        text: entry.value.toString(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
        if (dataBaru.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${dataBaru.length - 3} data lainnya',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Color _getOperasiColor(String operasi) {
    switch (operasi) {
      case 'INSERT':
        return AppColors.success;
      case 'UPDATE':
        return AppColors.info;
      case 'DELETE':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getOperasiIcon(String operasi) {
    switch (operasi) {
      case 'INSERT':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.circle;
    }
  }

  void _showDetailDialog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            _buildOperasiBadge(log['operasi']),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                log['nama_tabel'].toUpperCase(),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection('User', log['user_nama']),
              _buildDetailSection('Email', log['user_email']),
              _buildDetailSection('Waktu', log['waktu']),
              const Divider(color: AppColors.border),
              
              if (log['data_lama'] != null) ...[
                const Text(
                  'Data Lama:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                _buildJsonData(log['data_lama']),
                const SizedBox(height: 12),
              ],
              
              if (log['data_baru'] != null) ...[
                Text(
                  log['operasi'] == 'INSERT' ? 'Data:' : 'Data Baru:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                _buildJsonData(log['data_baru']),
              ],
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

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonData(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}:',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
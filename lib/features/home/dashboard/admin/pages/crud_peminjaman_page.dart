import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudPeminjamanPage extends StatefulWidget {
  const CrudPeminjamanPage({super.key});

  @override
  State<CrudPeminjamanPage> createState() => _CrudPeminjamanPageState();
}

class _CrudPeminjamanPageState extends State<CrudPeminjamanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Semua';

  // Dummy data
  final List<Map<String, dynamic>> _peminjamanList = [
    {
      'id': 1,
      'kode': 'PMJ-2024-001',
      'nama_user': 'John Doe',
      'email_user': 'john@example.com',
      'nama_alat': 'OBD2 Scanner Launch X431 Pro',
      'kategori': 'Diagnostic Tools',
      'jumlah': 1,
      'tanggal_pinjam': '2024-01-15',
      'tanggal_kembali': '2024-01-22',
      'status': 'dipinjam',
      'keperluan': 'Untuk diagnosis mobil pelanggan',
    },
    {
      'id': 2,
      'kode': 'PMJ-2024-002',
      'nama_user': 'Jane Smith',
      'email_user': 'jane@example.com',
      'nama_alat': 'Hydraulic Jack 3 Ton',
      'kategori': 'Hand Tools',
      'jumlah': 2,
      'tanggal_pinjam': '2024-01-18',
      'tanggal_kembali': '2024-01-25',
      'status': 'diajukan',
      'keperluan': 'Untuk servis kendaraan',
    },
    {
      'id': 3,
      'kode': 'PMJ-2024-003',
      'nama_user': 'Bob Wilson',
      'email_user': 'bob@example.com',
      'nama_alat': 'Impact Wrench Makita',
      'kategori': 'Power Tools',
      'jumlah': 1,
      'tanggal_pinjam': '2024-01-10',
      'tanggal_kembali': '2024-01-17',
      'status': 'terlambat',
      'keperluan': 'Untuk pemasangan ban',
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
                _buildFilterDropdown(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  items: ['Semua', 'Diajukan', 'Disetujui', 'Dipinjam', 'Terlambat', 'Ditolak'],
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
              itemCount: _peminjamanList.length,
              itemBuilder: (context, index) {
                final peminjaman = _peminjamanList[index];
                return _buildPeminjamanCard(peminjaman);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPeminjamanDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Peminjaman'),
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
          onTap: () => _showDetailDialog(peminjaman),
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
                        peminjaman['kode'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(peminjaman['status']),
                  ],
                ),
                const SizedBox(height: 12),

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        peminjaman['nama_user'][0].toUpperCase(),
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
                            peminjaman['nama_user'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            peminjaman['email_user'],
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
                            peminjaman['nama_alat'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${peminjaman['kategori']} • Jumlah: ${peminjaman['jumlah']}',
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
                          'Pinjam',
                          peminjaman['tanggal_pinjam'],
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
                          'Kembali',
                          peminjaman['tanggal_kembali'],
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
                    if (peminjaman['status'] == 'diajukan') ...[
                      TextButton.icon(
                        onPressed: () => _showApprovalDialog(peminjaman, false),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Tolak'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showApprovalDialog(peminjaman, true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Setujui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () => _showPeminjamanDialog(peminjaman: peminjaman),
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppColors.info,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.info.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showDeleteDialog(peminjaman),
                        icon: const Icon(Icons.delete, size: 20),
                        color: AppColors.error,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ],
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
    switch (status) {
      case 'diajukan':
        color = AppColors.warning;
        text = 'Diajukan';
        break;
      case 'disetujui':
        color = AppColors.info;
        text = 'Disetujui';
        break;
      case 'dipinjam':
        color = AppColors.success;
        text = 'Dipinjam';
        break;
      case 'terlambat':
        color = AppColors.error;
        text = 'Terlambat';
        break;
      case 'ditolak':
        color = AppColors.error;
        text = 'Ditolak';
        break;
      default:
        color = AppColors.textTertiary;
        text = status;
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

  void _showPeminjamanDialog({Map<String, dynamic>? peminjaman}) {
    final isEdit = peminjaman != null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isEdit ? 'Edit Peminjaman' : 'Tambah Peminjaman'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Form peminjaman akan ditampilkan di sini'),
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
                SnackBar(
                  content: Text(
                    isEdit
                        ? 'Peminjaman berhasil diupdate'
                        : 'Peminjaman berhasil ditambahkan',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isEdit ? 'Update' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(peminjaman['kode']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Peminjam', peminjaman['nama_user']),
              _buildDetailRow('Alat', peminjaman['nama_alat']),
              _buildDetailRow('Jumlah', '${peminjaman['jumlah']}'),
              _buildDetailRow('Tanggal Pinjam', peminjaman['tanggal_pinjam']),
              _buildDetailRow('Tanggal Kembali', peminjaman['tanggal_kembali']),
              _buildDetailRow('Status', peminjaman['status']),
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
                peminjaman['keperluan'],
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

  void _showApprovalDialog(Map<String, dynamic> peminjaman, bool approve) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(approve ? 'Setujui Peminjaman' : 'Tolak Peminjaman'),
        content: Text(
          approve
              ? 'Apakah Anda yakin ingin menyetujui peminjaman ini?'
              : 'Apakah Anda yakin ingin menolak peminjaman ini?',
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
                SnackBar(
                  content: Text(
                    approve
                        ? 'Peminjaman berhasil disetujui'
                        : 'Peminjaman berhasil ditolak',
                  ),
                  backgroundColor: approve ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.success : AppColors.error,
            ),
            child: Text(approve ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Peminjaman'),
        content: Text('Apakah Anda yakin ingin menghapus peminjaman "${peminjaman['kode']}"?'),
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
                  content: Text('Peminjaman berhasil dihapus'),
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
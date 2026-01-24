import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudAlatPage extends StatefulWidget {
  const CrudAlatPage({super.key});

  @override
  State<CrudAlatPage> createState() => _CrudAlatPageState();
}

class _CrudAlatPageState extends State<CrudAlatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _selectedKategori = 'Semua';

  // Dummy data
  final List<Map<String, dynamic>> _alatList = [
    {
      'id': 1,
      'nama': 'OBD2 Scanner Launch X431 Pro',
      'kategori': 'Diagnostic Tools',
      'kondisi': 'baik',
      'status': 'tersedia',
      'jumlah_total': 5,
      'jumlah_tersedia': 3,
    },
    {
      'id': 2,
      'nama': 'Hydraulic Jack 3 Ton',
      'kategori': 'Hand Tools',
      'kondisi': 'baik',
      'status': 'dipinjam',
      'jumlah_total': 10,
      'jumlah_tersedia': 7,
    },
    {
      'id': 3,
      'nama': 'Impact Wrench Makita',
      'kategori': 'Power Tools',
      'kondisi': 'rusak_ringan',
      'status': 'maintenance',
      'jumlah_total': 8,
      'jumlah_tersedia': 0,
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
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari alat...',
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
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Status',
                        value: _selectedFilter,
                        items: ['Semua', 'Tersedia', 'Dipinjam', 'Maintenance'],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Kategori',
                        value: _selectedKategori,
                        items: ['Semua', 'Diagnostic Tools', 'Hand Tools', 'Power Tools'],
                        onChanged: (value) {
                          setState(() {
                            _selectedKategori = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alatList.length,
              itemBuilder: (context, index) {
                final alat = _alatList[index];
                return _buildAlatCard(alat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAlatDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat'),
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

  Widget _buildAlatCard(Map<String, dynamic> alat) {
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
          onTap: () => _showAlatDialog(alat: alat),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat['nama'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alat['kategori'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(alat['status']),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.inventory,
                        'Total: ${alat['jumlah_total']}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.check_circle,
                        'Tersedia: ${alat['jumlah_tersedia']}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.build,
                        _getKondisiText(alat['kondisi']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showAlatDialog(alat: alat),
                      icon: const Icon(Icons.edit, size: 20),
                      color: AppColors.info,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.info.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showDeleteDialog(alat),
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'tersedia':
        color = AppColors.success;
        text = 'Tersedia';
        break;
      case 'dipinjam':
        color = AppColors.warning;
        text = 'Dipinjam';
        break;
      case 'maintenance':
        color = AppColors.error;
        text = 'Maintenance';
        break;
      default:
        color = AppColors.textTertiary;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
      default:
        return kondisi;
    }
  }

  void _showAlatDialog({Map<String, dynamic>? alat}) {
    final isEdit = alat != null;
    final namaController = TextEditingController(text: alat?['nama'] ?? '');
    final kategoriController = TextEditingController(text: alat?['kategori'] ?? '');
    final jumlahController = TextEditingController(
      text: alat?['jumlah_total']?.toString() ?? '1',
    );
    String selectedKondisi = alat?['kondisi'] ?? 'baik';
    String selectedStatus = alat?['status'] ?? 'tersedia';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(isEdit ? 'Edit Alat' : 'Tambah Alat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Alat',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Total',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedKondisi,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi',
                    prefixIcon: Icon(Icons.build),
                  ),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'baik', child: Text('Baik')),
                    DropdownMenuItem(value: 'rusak_ringan', child: Text('Rusak Ringan')),
                    DropdownMenuItem(value: 'rusak_berat', child: Text('Rusak Berat')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedKondisi = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                    DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
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
                // TODO: Implement save logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Alat berhasil diupdate' : 'Alat berhasil ditambahkan'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> alat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Alat'),
        content: Text('Apakah Anda yakin ingin menghapus "${alat['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alat berhasil dihapus'),
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
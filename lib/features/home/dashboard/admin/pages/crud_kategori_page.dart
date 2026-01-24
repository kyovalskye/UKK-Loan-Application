import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudKategoriPage extends StatefulWidget {
  const CrudKategoriPage({super.key});

  @override
  State<CrudKategoriPage> createState() => _CrudKategoriPageState();
}

class _CrudKategoriPageState extends State<CrudKategoriPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data
  final List<Map<String, dynamic>> _kategoriList = [
    {
      'id': 1,
      'nama': 'Diagnostic Tools',
      'deskripsi': 'Alat untuk diagnosis kendaraan',
      'jumlah_alat': 15,
      'icon': Icons.car_repair,
    },
    {
      'id': 2,
      'nama': 'Hand Tools',
      'deskripsi': 'Alat tangan manual',
      'jumlah_alat': 45,
      'icon': Icons.build,
    },
    {
      'id': 3,
      'nama': 'Power Tools',
      'deskripsi': 'Alat bertenaga listrik/pneumatic',
      'jumlah_alat': 28,
      'icon': Icons.power,
    },
    {
      'id': 4,
      'nama': 'Measuring Tools',
      'deskripsi': 'Alat ukur dan pengukuran',
      'jumlah_alat': 20,
      'icon': Icons.straighten,
    },
  ];

  final List<IconData> _availableIcons = [
    Icons.car_repair,
    Icons.build,
    Icons.power,
    Icons.straighten,
    Icons.settings,
    Icons.handyman,
    Icons.hardware,
    Icons.construction,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
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
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriList[index];
                return _buildKategoriCard(kategori);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showKategoriDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Widget _buildKategoriCard(Map<String, dynamic> kategori) {
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
          onTap: () => _showKategoriDialog(kategori: kategori),
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
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        kategori['icon'],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kategori['nama'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kategori['deskripsi'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${kategori['jumlah_alat']} Alat',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showKategoriDialog(kategori: kategori),
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppColors.info,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.info.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showDeleteDialog(kategori),
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

  void _showKategoriDialog({Map<String, dynamic>? kategori}) {
    final isEdit = kategori != null;
    final namaController = TextEditingController(text: kategori?['nama'] ?? '');
    final deskripsiController = TextEditingController(text: kategori?['deskripsi'] ?? '');
    IconData selectedIcon = kategori?['icon'] ?? Icons.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Icon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableIcons.map((icon) {
                          final isSelected = selectedIcon == icon;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = icon;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                    content: Text(
                      isEdit
                          ? 'Kategori berhasil diupdate'
                          : 'Kategori berhasil ditambahkan',
                    ),
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

  void _showDeleteDialog(Map<String, dynamic> kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus kategori "${kategori['nama']}"?'),
            const SizedBox(height: 8),
            Text(
              'Kategori ini memiliki ${kategori['jumlah_alat']} alat yang terkait.',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 12,
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
              // TODO: Implement delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kategori berhasil dihapus'),
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
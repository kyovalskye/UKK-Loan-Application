import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/crud_kategori_cubit.dart';

class CrudKategoriPage extends StatefulWidget {
  const CrudKategoriPage({super.key});

  @override
  State<CrudKategoriPage> createState() => _CrudKategoriPageState();
}

class _CrudKategoriPageState extends State<CrudKategoriPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger fetch saat page pertama kali dibuka
    context.read<CrudKategoriCubit>().fetchKategori();
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
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            // ✅ BlocListener untuk menangkap state Success & Error untuk snackbar
            child: BlocListener<CrudKategoriCubit, CrudKategoriState>(
              listener: (context, state) {
                if (state is CrudKategoriSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                }
                if (state is CrudKategoriError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: BlocBuilder<CrudKategoriCubit, CrudKategoriState>(
                builder: (context, state) {
                  if (state is CrudKategoriLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CrudKategoriLoaded) {
                    final list = state.kategori.where((k) {
                      final keyword = _searchController.text.toLowerCase();
                      return k['nama'].toString().toLowerCase().contains(
                        keyword,
                      );
                    }).toList();

                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'Kategori tidak ditemukan',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildKategoriCard(list[index]);
                      },
                    );
                  }

                  if (state is CrudKategoriError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
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

  Widget _buildSearchBar() {
    return Container(
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
        onChanged: (_) => setState(() {}),
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
                    // Container(
                    //   padding: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(
                    //     gradient: AppColors.primaryGradient,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: const Icon(
                    //     Icons.category,
                    //     color: Colors.white,
                    //     size: 28,
                    //   ),
                    // ),
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
                            kategori['deskripsi'] ?? '-',
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
                      children: [
                        IconButton(
                          onPressed: () =>
                              _showKategoriDialog(kategori: kategori),
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

  // ✅ Gunakan `context` langsung — tidak perlu `pageContext`
  void _showKategoriDialog({Map<String, dynamic>? kategori}) {
    final isEdit = kategori != null;
    final namaController = TextEditingController(text: kategori?['nama'] ?? '');
    final deskripsiController = TextEditingController(
      text: kategori?['deskripsi'] ?? '',
    );
    // Capture context dari StatefulWidget sebelum showDialog
    final currentContext = context;

    showDialog(
      context: currentContext,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Kategori'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deskripsiController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(currentContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(currentContext);
              final cubit = currentContext.read<CrudKategoriCubit>();

              if (isEdit) {
                cubit.updateKategori(
                  id: kategori!['id'],
                  nama: namaController.text,
                  deskripsi: deskripsiController.text,
                );
              } else {
                cubit.addKategori(
                  nama: namaController.text,
                  deskripsi: deskripsiController.text,
                );
              }
            },
            child: Text(isEdit ? 'Update' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> kategori) {
    final currentContext = context;

    showDialog(
      context: currentContext,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${kategori['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(currentContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(currentContext);
              currentContext.read<CrudKategoriCubit>().deleteKategori(
                kategori['id'],
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

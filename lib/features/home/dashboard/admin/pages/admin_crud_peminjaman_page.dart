import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/models/peminjaman_model.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../cubit/admin_crud_peminjaman_cubit.dart';

class CrudPeminjamanPage extends StatefulWidget {
  const CrudPeminjamanPage({super.key});

  @override
  State<CrudPeminjamanPage> createState() => _CrudPeminjamanPageState();
}

class _CrudPeminjamanPageState extends State<CrudPeminjamanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Semua';
  String? _currentUserRole; // Tambahan untuk menyimpan role user

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Load role user saat init
    context.read<CrudPeminjamanCubit>().fetchPeminjaman();
  }

  // Method untuk load user role
  Future<void> _loadUserRole() async {
    final role = await context.read<CrudPeminjamanCubit>().getCurrentUserRole();
    setState(() {
      _currentUserRole = role;
    });
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
          _buildSearchAndFilter(),
          Expanded(child: _buildPeminjamanList()),
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

  Widget _buildSearchAndFilter() {
    return Container(
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
          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatusFilter,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          items: [
            'Semua',
            'Diajukan',
            'Disetujui',
            'Dipinjam',
            'Dikembalikan',
            'Terlambat',
            'Ditolak'
          ].map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedStatusFilter = value!);
            context.read<CrudPeminjamanCubit>().fetchPeminjaman(
                  statusFilter: value,
                );
          },
        ),
      ),
    );
  }

  Widget _buildPeminjamanList() {
    return BlocListener<CrudPeminjamanCubit, CrudPeminjamanState>(
      listener: (context, state) {
        if (state is CrudPeminjamanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<CrudPeminjamanCubit>().fetchPeminjaman();
        }
        if (state is CrudPeminjamanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CrudPeminjamanCubit, CrudPeminjamanState>(
        builder: (context, state) {
          if (state is CrudPeminjamanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CrudPeminjamanLoaded) {
            final list = state.peminjaman.where((p) {
              final keyword = _searchController.text.toLowerCase();
              return p.kode.toLowerCase().contains(keyword) ||
                  p.namaUser.toLowerCase().contains(keyword) ||
                  p.namaAlat.toLowerCase().contains(keyword);
            }).toList();

            if (list.isEmpty) {
              return const Center(
                child: Text('Peminjaman tidak ditemukan'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) =>
                  _buildPeminjamanCard(list[index]),
            );
          }

          if (state is CrudPeminjamanError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPeminjamanCard(PeminjamanModel peminjaman) {
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
                _buildCardHeader(peminjaman),
                const SizedBox(height: 12),
                _buildUserInfo(peminjaman),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                _buildAlatInfo(peminjaman),
                const SizedBox(height: 12),
                _buildDateInfo(peminjaman),
                const SizedBox(height: 12),
                _buildCardActions(peminjaman),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(PeminjamanModel peminjaman) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            peminjaman.kode,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        _buildStatusBadge(peminjaman.status),
      ],
    );
  }

  Widget _buildUserInfo(PeminjamanModel peminjaman) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.info.withOpacity(0.2),
          child: Text(
            peminjaman.namaUser[0].toUpperCase(),
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
                peminjaman.namaUser,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                peminjaman.emailUser,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlatInfo(PeminjamanModel peminjaman) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                peminjaman.namaAlat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${peminjaman.kategori} • Jumlah: ${peminjaman.jumlah}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(PeminjamanModel peminjaman) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateColumn(
              Icons.calendar_today,
              'Pinjam',
              peminjaman.tanggalPinjam,
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.border),
          Expanded(
            child: _buildDateColumn(
              Icons.event,
              'Kembali',
              peminjaman.tanggalKembali,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(IconData icon, String label, String date) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(PeminjamanModel peminjaman) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tombol Approve/Reject HANYA untuk PETUGAS dan status DIAJUKAN
        if (peminjaman.status == 'diajukan' && _currentUserRole == 'petugas') ...[
          TextButton.icon(
            onPressed: () => _showApprovalDialog(peminjaman, false),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Tolak'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        ] 
        // Tombol Edit/Delete untuk ADMIN dan PETUGAS (tapi tidak untuk status diajukan jika petugas)
        else if (_currentUserRole == 'admin' || 
                (_currentUserRole == 'petugas' && peminjaman.status != 'diajukan')) ...[
          IconButton(
            onPressed: () => _showPeminjamanDialog(peminjaman: peminjaman),
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showDeleteDialog(peminjaman),
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.error,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusConfig = {
      'diajukan': (AppColors.warning, 'Diajukan'),
      'disetujui': (AppColors.info, 'Disetujui'),
      'dipinjam': (AppColors.success, 'Dipinjam'),
      'terlambat': (AppColors.error, 'Terlambat'),
      'ditolak': (AppColors.error, 'Ditolak'),
      'dikembalikan': (Colors.grey, 'Dikembalikan'),
    };

    final config = statusConfig[status] ?? (AppColors.textTertiary, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.$2,
        style: TextStyle(
          color: config.$1,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showPeminjamanDialog({PeminjamanModel? peminjaman}) {
    final isEdit = peminjaman != null;
    final formKey = GlobalKey<FormState>();

    final keperluanController = TextEditingController(
      text: peminjaman?.keperluan ?? '',
    );
    final jumlahController = TextEditingController(
      text: peminjaman?.jumlah.toString() ?? '1',
    );

    String? selectedUserId = peminjaman?.userId;
    int? selectedAlatId = peminjaman?.idAlat;
    int? currentStok;
    DateTime tanggalPinjam = peminjaman != null
        ? DateTime.parse(peminjaman.tanggalPinjam)
        : DateTime.now();
    DateTime tanggalKembali = peminjaman != null
        ? DateTime.parse(peminjaman.tanggalKembali)
        : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stfContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(isEdit ? 'Edit Peminjaman' : 'Tambah Peminjaman'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserDropdown(selectedUserId, (value) {
                      setDialogState(() => selectedUserId = value);
                    }),
                    const SizedBox(height: 16),
                    _buildAlatDropdown(selectedAlatId, (value) async {
                      setDialogState(() => selectedAlatId = value);
                      if (value != null) {
                        final stok = await context
                            .read<CrudPeminjamanCubit>()
                            .getjumlah_totalAlat(value);
                        setDialogState(() => currentStok = stok);
                      }
                    }),
                    if (currentStok != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Stok tersedia: $currentStok',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: jumlahController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        final jumlah = int.tryParse(value);
                        if (jumlah == null || jumlah <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        if (currentStok != null && jumlah > currentStok!) {
                          return 'Jumlah melebihi stok ($currentStok)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      'Tanggal Pinjam',
                      tanggalPinjam,
                      Icons.calendar_today,
                      (picked) {
                        setDialogState(() => tanggalPinjam = picked);
                      },
                      stfContext,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      'Tanggal Kembali (Rencana)',
                      tanggalKembali,
                      Icons.event,
                      (picked) {
                        setDialogState(() => tanggalKembali = picked);
                      },
                      stfContext,
                      firstDate: tanggalPinjam,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: keperluanController,
                      decoration: const InputDecoration(
                        labelText: 'Keperluan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext);

                    final cubit = context.read<CrudPeminjamanCubit>();
                    final formattedPinjam = _formatDate(tanggalPinjam);
                    final formattedKembali = _formatDate(tanggalKembali);

                    if (isEdit) {
                      cubit.updatePeminjaman(
                        id: peminjaman!.id,
                        idUser: selectedUserId!,
                        idAlat: selectedAlatId!,
                        tanggalPinjam: formattedPinjam,
                        tanggalKembali: formattedKembali,
                        jumlah: int.parse(jumlahController.text),
                        keperluan: keperluanController.text.isEmpty
                            ? null
                            : keperluanController.text,
                      );
                    } else {
                      cubit.addPeminjaman(
                        idUser: selectedUserId!,
                        idAlat: selectedAlatId!,
                        tanggalPinjam: formattedPinjam,
                        tanggalKembali: formattedKembali,
                        jumlah: int.parse(jumlahController.text),
                        keperluan: keperluanController.text.isEmpty
                            ? null
                            : keperluanController.text,
                      );
                    }
                  }
                },
                child: Text(isEdit ? 'Update' : 'Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserDropdown(String? selectedUserId, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Peminjam',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<UserModel>>(
          future: context.read<CrudPeminjamanCubit>().fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Tidak ada user tersedia');
            }

            return DropdownButtonFormField<String>(
              value: selectedUserId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Pilih User'),
              items: snapshot.data!.map((user) {
                return DropdownMenuItem<String>(
                  value: user.userId,
                  child: Text('${user.nama} (${user.email})'),
                );
              }).toList(),
              onChanged: onChanged,
              validator: (value) =>
                  value == null ? 'Pilih user terlebih dahulu' : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlatDropdown(int? selectedAlatId, Function(int?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Alat',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<AlatModel>>(
          future: context.read<CrudPeminjamanCubit>().fetchAlat(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Tidak ada alat tersedia');
            }

            return DropdownButtonFormField<int>(
              value: selectedAlatId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Pilih Alat'),
              items: snapshot.data!.map((alat) {
                return DropdownMenuItem<int>(
                  value: alat.idAlat,
                  child: Text(alat.namaAlat),
                );
              }).toList(),
              onChanged: onChanged,
              validator: (value) =>
                  value == null ? 'Pilih alat terlebih dahulu' : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime selectedDate,
    IconData icon,
    Function(DateTime) onDateSelected,
    BuildContext context, {
    DateTime? firstDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 12),
                Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(PeminjamanModel peminjaman) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(peminjaman.kode),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Peminjam', peminjaman.namaUser),
              _buildDetailRow('Email', peminjaman.emailUser),
              _buildDetailRow('Alat', peminjaman.namaAlat),
              _buildDetailRow('Kategori', peminjaman.kategori),
              _buildDetailRow('Jumlah', '${peminjaman.jumlah}'),
              _buildDetailRow('Tanggal Pinjam', peminjaman.tanggalPinjam),
              _buildDetailRow('Tanggal Kembali', peminjaman.tanggalKembali),
              _buildDetailRow('Status', peminjaman.status),
              if (peminjaman.catatanAdmin != null) ...[
                const Divider(),
                const Text('Catatan Admin:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(peminjaman.catatanAdmin!),
              ],
              const Divider(),
              const Text('Keperluan:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(peminjaman.keperluan),
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
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showApprovalDialog(PeminjamanModel peminjaman, bool approve) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(approve ? 'Setujui Peminjaman' : 'Tolak Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(approve
                ? 'Apakah Anda yakin ingin menyetujui peminjaman ini?'
                : 'Apakah Anda yakin ingin menolak peminjaman ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              context.read<CrudPeminjamanCubit>().approvePeminjaman(
                    id: peminjaman.id,
                    approve: approve,
                    catatan: catatanController.text.isEmpty
                        ? null
                        : catatanController.text,
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

  void _showDeleteDialog(PeminjamanModel peminjaman) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Peminjaman'),
        content: Text('Apakah Anda yakin ingin menghapus peminjaman "${peminjaman.kode}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CrudPeminjamanCubit>().deletePeminjaman(peminjaman.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
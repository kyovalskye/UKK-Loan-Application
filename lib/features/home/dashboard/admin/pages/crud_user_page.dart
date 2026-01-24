import 'package:flutter/material.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class CrudUserPage extends StatefulWidget {
  const CrudUserPage({super.key});

  @override
  State<CrudUserPage> createState() => _CrudUserPageState();
}

class _CrudUserPageState extends State<CrudUserPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'Semua';

  // Dummy data
  final List<Map<String, dynamic>> _userList = [
    {
      'id': '1',
      'nama': 'John Doe',
      'email': 'john@example.com',
      'role': 'admin',
      'created_at': '2024-01-15',
    },
    {
      'id': '2',
      'nama': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'petugas',
      'created_at': '2024-01-20',
    },
    {
      'id': '3',
      'nama': 'Bob Wilson',
      'email': 'bob@example.com',
      'role': 'peminjam',
      'created_at': '2024-02-01',
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
                    hintText: 'Cari user...',
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
                  label: 'Role',
                  value: _selectedRoleFilter,
                  items: ['Semua', 'Admin', 'Petugas', 'Peminjam'],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleFilter = value!;
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
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                final user = _userList[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
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

  Widget _buildUserCard(Map<String, dynamic> user) {
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
          onTap: () => _showUserDialog(user: user),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        user['nama'][0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRoleBadge(user['role']),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Terdaftar: ${user['created_at']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showUserDialog(user: user),
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppColors.info,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.info.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showDeleteDialog(user),
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

  Widget _buildRoleBadge(String role) {
    Color color;
    String text;
    IconData icon;
    
    switch (role) {
      case 'admin':
        color = AppColors.error;
        text = 'Admin';
        icon = Icons.admin_panel_settings;
        break;
      case 'petugas':
        color = AppColors.info;
        text = 'Petugas';
        icon = Icons.badge;
        break;
      case 'peminjam':
        color = AppColors.success;
        text = 'Peminjam';
        icon = Icons.person;
        break;
      default:
        color = AppColors.textTertiary;
        text = role;
        icon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final namaController = TextEditingController(text: user?['nama'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?['role'] ?? 'peminjam';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(isEdit ? 'Edit User' : 'Tambah User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isEdit)
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                if (!isEdit) const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                    DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
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
                    content: Text(isEdit ? 'User berhasil diupdate' : 'User berhasil ditambahkan'),
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

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus user "${user['nama']}"?'),
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
                  content: Text('User berhasil dihapus'),
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
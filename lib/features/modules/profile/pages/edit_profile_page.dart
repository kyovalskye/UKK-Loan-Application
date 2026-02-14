import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/auth/cubit/auth_state.dart';
import 'package:rentalify/features/modules/profile/cubit/profile_cubit.dart';
import 'package:rentalify/features/modules/profile/cubit/profile_state.dart';
import '../../../auth/cubit/auth_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    _nameController = TextEditingController(text: authState.userName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

      if (imageBytes != null) {
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        if (mounted) {
          context.read<ProfileCubit>().updateProfilePhoto(
            imageBytes: imageBytes,
            fileName: fileName,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Foto Profil'),
        content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<ProfileCubit>().deleteProfilePhoto();
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      context.read<ProfileCubit>().updateUsername(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return TextButton.icon(
                onPressed: state.status == ProfileStatus.loading
                    ? null
                    : _saveProfile,
                icon: state.status == ProfileStatus.loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Simpan'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Berhasil'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ProfileCubit>().resetState();
          } else if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, profileState) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final photoUrl = authState.userData?['foto_url'];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Photo Section
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: photoUrl != null && photoUrl.isNotEmpty
                                  ? Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar(authState.userName);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    )
                                  : _buildDefaultAvatar(authState.userName),
                            ),
                          ),
                          if (profileState.isUploading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: PopupMenuButton(
                              color: AppColors.surface,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: _pickImage,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.photo_library, size: 20),
                                      SizedBox(width: 12),
                                      Text('Pilih dari Galeri'),
                                    ],
                                  ),
                                ),
                                if (photoUrl != null && photoUrl.isNotEmpty)
                                  PopupMenuItem(
                                    onTap: _deletePhoto,
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, 
                                          size: 20, 
                                          color: AppColors.error
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Hapus Foto',
                                          style: TextStyle(color: AppColors.error),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Masukkan username Anda',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Username minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field (Read-only)
                      TextFormField(
                        initialValue: authState.userEmail ?? '',
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Role Field (Read-only)
                      TextFormField(
                        initialValue: _getRoleLabel(authState.userRole),
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(_getRoleIcon(authState.userRole)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String? name) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(name ?? 'User'),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'petugas':
        return 'Petugas';
      case 'peminjam':
        return 'Peminjam';
      default:
        return 'User';
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'petugas':
        return Icons.badge;
      case 'peminjam':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }
}
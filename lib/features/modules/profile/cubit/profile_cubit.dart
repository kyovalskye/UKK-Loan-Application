import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/services/supabase_service.dart';
import 'package:rentalify/features/auth/cubit/auth_cubit.dart';
import 'dart:typed_data';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SupabaseService _supabaseService;
  final AuthCubit _authCubit;

  ProfileCubit(this._supabaseService, this._authCubit)
      : super(const ProfileState());

  Future<void> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Username tidak boleh kosong',
      ));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final userId = _authCubit.state.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Update username di database
      await _supabaseService.updateUserProfile(
        userId: userId,
        nama: newUsername,
      );

      // Log aktivitas
      _supabaseService.createLogAktivitas(
        namaTabel: 'users',
        operasi: 'UPDATE',
        dataBaru: {'nama': newUsername},
      );

      // Reload user data di AuthCubit
      await _reloadUserData(userId);

      emit(state.copyWith(
        status: ProfileStatus.success,
        successMessage: 'Username berhasil diperbarui',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Gagal memperbarui username: ${e.toString()}',
      ));
    }
  }

  Future<void> updateProfilePhoto({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    emit(state.copyWith(isUploading: true, status: ProfileStatus.loading));

    try {
      final userId = _authCubit.state.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Upload foto ke Supabase Storage
      final photoUrl = await _supabaseService.uploadProfilePhoto(
        userId: userId,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      // Update foto profil di database
      await _supabaseService.updateUserProfile(
        userId: userId,
        fotoUrl: photoUrl,
      );

      // Log aktivitas
      _supabaseService.createLogAktivitas(
        namaTabel: 'users',
        operasi: 'UPDATE',
        dataBaru: {'foto_url': photoUrl},
      );

      // Reload user data di AuthCubit
      await _reloadUserData(userId);

      emit(state.copyWith(
        status: ProfileStatus.success,
        successMessage: 'Foto profil berhasil diperbarui',
        isUploading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Gagal memperbarui foto profil: ${e.toString()}',
        isUploading: false,
      ));
    }
  }

  Future<void> deleteProfilePhoto() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final userId = _authCubit.state.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      final currentPhotoUrl = _authCubit.state.userData?['foto_url'];
      
      // Delete foto dari storage jika ada
      if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
        await _supabaseService.deleteProfilePhoto(userId: userId);
      }

      // Update database (set foto_url ke null)
      await _supabaseService.updateUserProfile(
        userId: userId,
        fotoUrl: null,
      );

      // Log aktivitas
      _supabaseService.createLogAktivitas(
        namaTabel: 'users',
        operasi: 'UPDATE',
        dataBaru: {'foto_url': null},
      );

      // Reload user data di AuthCubit
      await _reloadUserData(userId);

      emit(state.copyWith(
        status: ProfileStatus.success,
        successMessage: 'Foto profil berhasil dihapus',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Gagal menghapus foto profil: ${e.toString()}',
      ));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.trim().isEmpty || newPassword.trim().isEmpty) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Password tidak boleh kosong',
      ));
      return;
    }

    if (newPassword.length < 6) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Password minimal 6 karakter',
      ));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final userEmail = _authCubit.state.userEmail;
      if (userEmail == null) {
        throw Exception('Email tidak ditemukan');
      }

      // Verify current password dengan mencoba login
      await _supabaseService.signInWithEmail(
        email: userEmail,
        password: currentPassword,
      );

      // Update password
      await _supabaseService.updatePassword(newPassword);

      // Log aktivitas
      _supabaseService.createLogAktivitas(
        namaTabel: 'users',
        operasi: 'UPDATE',
        dataBaru: {'password': 'changed'},
      );

      emit(state.copyWith(
        status: ProfileStatus.success,
        successMessage: 'Password berhasil diubah',
      ));
    } catch (e) {
      String errorMessage = 'Gagal mengubah password';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Password lama tidak sesuai';
      }
      
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _reloadUserData(String userId) async {
    final userData = await _supabaseService.getUserData(userId);
    if (userData != null) {
      _authCubit.emit(_authCubit.state.copyWith(userData: userData));
    }
  }

  void resetState() {
    emit(const ProfileState());
  }
}
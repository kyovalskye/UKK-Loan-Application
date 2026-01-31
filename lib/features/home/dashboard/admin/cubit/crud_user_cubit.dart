// crud_user_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_user_state.dart';

class CrudUserCubit extends Cubit<CrudUserState> {
  final _supabase = Supabase.instance.client;

  CrudUserCubit() : super(CrudUserInitial());

  Future<void> loadUsers() async {
    emit(CrudUserLoading());
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      emit(CrudUserLoaded(List<Map<String, dynamic>>.from(response)));
    } catch (e) {
      emit(CrudUserError('Error loading users: $e'));
    }
  }

  Future<void> createUser({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Validasi input
      if (nama.trim().isEmpty) {
        emit(const CrudUserError('Nama tidak boleh kosong'));
        return;
      }
      
      if (email.trim().isEmpty || !email.contains('@')) {
        emit(const CrudUserError('Email tidak valid'));
        return;
      }
      
      if (password.length < 6) {
        emit(const CrudUserError('Password minimal 6 karakter'));
        return;
      }

      // Panggil RPC function
      final response = await _supabase.rpc('admin_create_user', params: {
        'p_email': email.trim(),
        'p_password': password,
        'p_nama': nama.trim(),
        'p_role': role.toLowerCase(),
      });

      // Parse response
      if (response != null && response is Map) {
        if (response['success'] == true) {
          emit(const CrudUserSuccess('User berhasil ditambahkan'));
          await loadUsers();
        } else {
          emit(CrudUserError(response['message'] ?? 'Gagal membuat user'));
        }
      } else {
        emit(const CrudUserError('Response tidak valid dari server'));
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        emit(const CrudUserError('Email sudah terdaftar'));
      } else {
        emit(CrudUserError('Error creating user: ${e.toString()}'));
      }
    }
  }

  Future<void> updateUser({
    required String userId,
    required String nama,
    required String role,
  }) async {
    try {
      // Validasi input
      if (nama.trim().isEmpty) {
        emit(const CrudUserError('Nama tidak boleh kosong'));
        return;
      }

      final response = await _supabase.rpc('admin_update_user', params: {
        'p_user_id': userId,
        'p_nama': nama.trim(),
        'p_role': role.toLowerCase(),
      });

      // Parse response
      if (response != null && response is Map) {
        if (response['success'] == true) {
          emit(const CrudUserSuccess('User berhasil diupdate'));
          await loadUsers();
        } else {
          emit(CrudUserError(response['message'] ?? 'Gagal update user'));
        }
      } else {
        emit(const CrudUserError('Response tidak valid dari server'));
      }
    } catch (e) {
      emit(CrudUserError('Error updating user: ${e.toString()}'));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _supabase.rpc('admin_delete_user', params: {
        'p_user_id': userId,
      });

      // Parse response
      if (response != null && response is Map) {
        if (response['success'] == true) {
          emit(const CrudUserSuccess('User berhasil dihapus'));
          await loadUsers();
        } else {
          emit(CrudUserError(response['message'] ?? 'Gagal menghapus user'));
        }
      } else {
        emit(const CrudUserError('Response tidak valid dari server'));
      }
    } catch (e) {
      emit(CrudUserError('Error deleting user: ${e.toString()}'));
    }
  }
}
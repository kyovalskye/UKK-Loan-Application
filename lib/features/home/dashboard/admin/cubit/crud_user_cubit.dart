// crud_user_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'crud_user_state.dart';

class CrudUserCubit extends Cubit<CrudUserState> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _realtimeChannel;
  StreamSubscription<List<Map<String, dynamic>>>? _userSubscription;

  CrudUserCubit() : super(CrudUserInitial()) {
    _initRealtimeWithStream();
  }

  void _initRealtimeWithStream() {
    // Gunakan stream untuk auto-update realtime
    _userSubscription = _supabase
        .from('users')
        .stream(primaryKey: ['user_id'])
        .order('created_at', ascending: false)
        .listen(
          (data) {
            if (!isClosed) {
              print('Stream data received: ${data.length} users');
              emit(CrudUserLoaded(List<Map<String, dynamic>>.from(data)));
            }
          },
          onError: (error) {
            if (!isClosed) {
              print('Stream error: $error');
              emit(CrudUserError('Error: $error'));
            }
          },
        );
  }

  Future<void> loadUsers() async {
    try {
      // Tampilkan loading hanya jika belum ada data
      if (state is CrudUserInitial) {
        emit(CrudUserLoading());
      }

      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      if (!isClosed) {
        emit(CrudUserLoaded(List<Map<String, dynamic>>.from(response)));
      }
    } catch (e) {
      if (!isClosed) {
        print('Load users error: $e');
        emit(CrudUserError('Error loading users: $e'));
      }
    }
  }

  Future<void> createUser({
    required String nama,
    required String email,
    required String password,
    required String role,
    String? nomorHp,
    String? alamat,
  }) async {
    try {
      // Validasi input
      if (nama.trim().isEmpty) {
        emit(const CrudUserError('Nama tidak boleh kosong'));
        return;
      }
      if (email.trim().isEmpty) {
        emit(const CrudUserError('Email tidak boleh kosong'));
        return;
      }
      if (password.isEmpty) {
        emit(const CrudUserError('Password tidak boleh kosong'));
        return;
      }
      if (password.length < 6) {
        emit(const CrudUserError('Password minimal 6 karakter'));
        return;
      }

      // Validasi email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email.trim())) {
        emit(const CrudUserError('Format email tidak valid'));
        return;
      }

      // Cek duplikat email
      final existingUser = await _supabase
          .from('users')
          .select('email')
          .eq('email', email.trim())
          .maybeSingle();

      if (existingUser != null) {
        emit(const CrudUserError('Email sudah terdaftar'));
        return;
      }

      // Create user - trigger akan otomatis insert ke public.users
      final authResponse = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama': nama.trim(),
          'role': role.toLowerCase(),
          'nomor_hp': nomorHp?.trim(),
          'alamat': alamat?.trim(),
        },
      );

      if (authResponse.user == null) {
        emit(const CrudUserError('Gagal membuat user'));
        return;
      }

      // Emit success - stream akan otomatis update
      if (!isClosed) {
        emit(const CrudUserSuccess('User berhasil ditambahkan'));
      }
    } on AuthException catch (e) {
      if (!isClosed) {
        if (e.message.contains('already registered') ||
            e.message.contains('already exists') ||
            e.message.contains('User already registered')) {
          emit(const CrudUserError('Email sudah terdaftar'));
        } else if (e.message.contains('Invalid email')) {
          emit(const CrudUserError('Format email tidak valid'));
        } else if (e.message.contains('Password')) {
          emit(const CrudUserError('Password tidak valid (min 6 karakter)'));
        } else {
          emit(CrudUserError('Error: ${e.message}'));
        }
      }
    } on PostgrestException catch (e) {
      if (!isClosed) {
        if (e.message.contains('duplicate key') ||
            e.message.contains('unique constraint')) {
          emit(const CrudUserError('Email sudah terdaftar'));
        } else {
          emit(CrudUserError('Error database: ${e.message}'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CrudUserError('Error: ${e.toString()}'));
      }
    }
  }

  Future<void> updateUser({
    required String userId,
    required String nama,
    required String role,
    String? nomorHp,
    String? alamat,
  }) async {
    try {
      if (nama.trim().isEmpty) {
        emit(const CrudUserError('Nama tidak boleh kosong'));
        return;
      }

      final response = await _supabase.rpc('admin_update_user', params: {
        'p_user_id': userId,
        'p_nama': nama.trim(),
        'p_role': role.toLowerCase(),
        'p_nomor_hp': nomorHp?.trim(),
        'p_alamat': alamat?.trim(),
      });

      if (response != null && response is Map) {
        if (response['success'] == true) {
          if (!isClosed) {
            emit(const CrudUserSuccess('User berhasil diupdate'));
          }
        } else {
          if (!isClosed) {
            emit(CrudUserError(response['message'] ?? 'Gagal update user'));
          }
        }
      } else {
        if (!isClosed) {
          emit(const CrudUserError('Response tidak valid dari server'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CrudUserError('Error: ${e.toString()}'));
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _supabase.rpc('admin_delete_user', params: {
        'p_user_id': userId,
      });

      if (response == null || response is! Map) {
        if (!isClosed) {
          emit(const CrudUserError('Response tidak valid dari server'));
        }
        return;
      }

      if (response['success'] == true) {
        if (!isClosed) {
          emit(const CrudUserSuccess('User berhasil dihapus'));
        }
      } else {
        if (!isClosed) {
          emit(CrudUserError(response['message'] ?? 'Gagal menghapus user'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CrudUserError('Error: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _realtimeChannel?.unsubscribe();
    return super.close();
  }
}
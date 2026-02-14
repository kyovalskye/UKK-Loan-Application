import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/services/supabase_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseService _supabaseService;
  StreamSubscription? _authSubscription;

  AuthCubit(this._supabaseService) : super(const AuthState()) {
    // Listen to auth state changes
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _supabaseService.authStateChanges.listen((event) {
      final user = event.session?.user;
      if (user != null && state.status != AuthStatus.authenticated) {
        // User logged in
        _loadUserData(user.id);
      } else if (user == null && state.status != AuthStatus.unauthenticated) {
        // User logged out
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final userData = await _supabaseService.getUserData(userId);
      if (userData != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userData: userData,
        ));
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final user = _supabaseService.currentUser;
      
      if (user != null) {
        final userData = await _supabaseService.getUserData(user.id);
        
        if (userData != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            userData: userData,
          ));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _supabaseService.getUserData(response.user!.id);
        
        // Log aktivitas login (non-blocking)
        _supabaseService.createLogAktivitas(
          namaTabel: 'users',
          operasi: 'LOGIN',
          idRecord: null,
        );
        
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userData: userData,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login gagal',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseErrorMessage(e.toString()),
      ));
    }
  }

  Future<void> signUp({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      // Sign up dengan Supabase Auth
      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        data: {'nama': nama},
      );

      if (response.user != null) {
        // Create user data di table users
        await _supabaseService.createUser(
          userId: response.user!.id,
          nama: nama,
          email: email,
          role: role,
        );

        // Log aktivitas (non-blocking)
        _supabaseService.createLogAktivitas(
          namaTabel: 'users',
          operasi: 'INSERT',
          idRecord: null,
          dataBaru: {'nama': nama, 'email': email, 'role': role},
        );

        final userData = await _supabaseService.getUserData(response.user!.id);
        
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userData: userData,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseErrorMessage(e.toString()),
      ));
    }
  }

  Future<void> signOut() async {
    try {
      // Log aktivitas logout (non-blocking)
      _supabaseService.createLogAktivitas(
        namaTabel: 'users',
        operasi: 'LOGOUT',
        idRecord: null,
      );
      
      await _supabaseService.signOut();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum diverifikasi';
    } else if (error.contains('User already registered')) {
      return 'Email sudah terdaftar';
    } else if (error.contains('Network')) {
      return 'Tidak ada koneksi internet';
    }
    return 'Terjadi kesalahan, silakan coba lagi';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
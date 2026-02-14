import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // ============================================================================
  // AUTH METHODS
  // ============================================================================
  
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================================================
  // USER METHODS
  // ============================================================================
  
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  Future<void> createUser({
    required String userId,
    required String nama,
    required String email,
    required String role,
  }) async {
    await _client.from('users').insert({
      'user_id': userId,
      'nama': nama,
      'email': email,
      'role': role,
    });
  }

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('users')
        .update(data)
        .eq('user_id', userId);
  }

  // ============================================================================
  // PROFILE MANAGEMENT METHODS
  // ============================================================================
  
  /// Upload profile photo ke Supabase Storage
  Future<String> uploadProfilePhoto({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final String filePath = '$userId/$fileName';

      // Delete old photo if exists
      try {
        final existingFiles = await _client.storage
            .from('profile-image')
            .list(path: userId);
        
        for (var file in existingFiles) {
          await _client.storage
              .from('profile-image')
              .remove(['$userId/${file.name}']);
        }
      } catch (e) {
        // Ignore if no files exist
        print('No existing files to delete: $e');
      }

      // Upload new photo using uploadBinary for Uint8List
      await _client.storage.from('profile-image').uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final String publicUrl = _client.storage
          .from('profile-image')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal mengupload foto: ${e.toString()}');
    }
  }

  /// Delete profile photo from storage
  Future<void> deleteProfilePhoto({required String userId}) async {
    try {
      final existingFiles = await _client.storage
          .from('profile-image')
          .list(path: userId);

      if (existingFiles.isNotEmpty) {
        final List<String> filesToDelete = existingFiles
            .map((file) => '$userId/${file.name}')
            .toList();

        await _client.storage
            .from('profile-image')
            .remove(filesToDelete);
      }
    } catch (e) {
      throw Exception('Gagal menghapus foto: ${e.toString()}');
    }
  }

  /// Update user profile data (nama dan/atau foto_url)
 /// Update user profile data (nama dan/atau foto_url)
Future<void> updateUserProfile({
  required String userId,
  String? nama,
  String? fotoUrl,
}) async {
  try {
    final Map<String, dynamic> updateData = {};

    // Update nama jika provided
    if (nama != null) {
      updateData['nama'] = nama;
    }

    // Update foto_url
    // Jika fotoUrl provided (bukan null), update dengan URL baru
    // Jika fotoUrl adalah null DAN nama juga null, berarti hapus foto
    if (fotoUrl != null) {
      updateData['foto_url'] = fotoUrl;
    } else if (nama == null) {
      // Jika hanya fotoUrl yang null (tanpa nama), berarti hapus foto
      updateData['foto_url'] = null;
    }

    // Hanya update jika ada data yang berubah
    if (updateData.isNotEmpty) {
      await _client.from('users').update(updateData).eq('user_id', userId);
    }
  } catch (e) {
    throw Exception('Gagal update profil: ${e.toString()}');
  }
}

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Gagal update password: ${e.toString()}');
    }
  }

  // ============================================================================
  // ALAT METHODS
  // ============================================================================
  
  Future<List<Map<String, dynamic>>> getAlat({
    String? status,
    String? kategori,
  }) async {
    var query = _client.from('alat').select();
    
    if (status != null) {
      query = query.eq('status', status);
    }
    if (kategori != null) {
      query = query.eq('kategori', kategori);
    }
    
    return await query;
  }

  Future<Map<String, dynamic>> getAlatById(int idAlat) async {
    return await _client
        .from('alat')
        .select()
        .eq('id_alat', idAlat)
        .single();
  }

  Future<void> createAlat(Map<String, dynamic> data) async {
    await _client.from('alat').insert(data);
  }

  Future<void> updateAlat({
    required int idAlat,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('alat')
        .update(data)
        .eq('id_alat', idAlat);
  }

  Future<void> deleteAlat(int idAlat) async {
    await _client.from('alat').delete().eq('id_alat', idAlat);
  }

  // ============================================================================
  // PEMINJAMAN METHODS
  // ============================================================================
  
  Future<List<Map<String, dynamic>>> getPeminjaman({
    String? userId,
    String? status,
  }) async {
    var query = _client.from('peminjaman').select('''
      *,
      users!peminjaman_id_user_fkey(user_id, nama, email),
      alat(id_alat, nama_alat, kategori, foto_alat)
    ''');
    
    if (userId != null) {
      query = query.eq('id_user', userId);
    }
    if (status != null) {
      query = query.eq('status_peminjaman', status);
    }
    
    return await query.order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> getPeminjamanById(int idPeminjaman) async {
    return await _client
        .from('peminjaman')
        .select('''
          *,
          users!peminjaman_id_user_fkey(user_id, nama, email),
          alat(id_alat, nama_alat, kategori, foto_alat)
        ''')
        .eq('id_peminjaman', idPeminjaman)
        .single();
  } 

  Future<void> createPeminjaman(Map<String, dynamic> data) async {
    await _client.from('peminjaman').insert(data);
  }

  Future<void> updatePeminjaman({
    required int idPeminjaman,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('peminjaman')
        .update(data)
        .eq('id_peminjaman', idPeminjaman);
  }

  // ============================================================================
  // PENGEMBALIAN METHODS
  // ============================================================================
  
  Future<void> createPengembalian(Map<String, dynamic> data) async {
    await _client.from('pengembalian').insert(data);
  }

  Future<List<Map<String, dynamic>>> getPengembalian({
    String? statusPembayaran,
  }) async {
    var query = _client.from('pengembalian').select('''
      *,
      peminjaman!pengembalian_id_peminjaman_fkey(
        *,
        users!peminjaman_id_user_fkey(nama),
        alat(nama_alat)
      )
    ''');
    
    if (statusPembayaran != null) {
      query = query.eq('status_pembayaran', statusPembayaran);
    }
    
    return await query.order('created_at', ascending: false);
  }

  // ============================================================================
  // SETTING DENDA METHODS
  // ============================================================================
  
  Future<Map<String, dynamic>> getSettingDenda() async {
    final response = await _client
        .from('setting_denda')
        .select()
        .single();
    return response;
  }

  Future<void> updateSettingDenda({
    required int idSetting,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('setting_denda')
        .update(data)
        .eq('id_setting', idSetting);
  }

  // ============================================================================
  // LOG AKTIVITAS METHODS
  // ============================================================================
  
  Future<void> createLogAktivitas({
    required String namaTabel,
    required String operasi,
    int? idRecord,
    Map<String, dynamic>? dataLama,
    Map<String, dynamic>? dataBaru,
  }) async {
    try {
      await _client.from('log_aktivitas').insert({
        'nama_tabel': namaTabel,
        'operasi': operasi,
        'id_record': idRecord,
        'data_lama': dataLama,
        'data_baru': dataBaru,
        'user_id': currentUserId,
      });
    } catch (e) {
      // Silently fail log aktivitas jika RLS belum setup
      // Ini tidak menghalangi operasi utama
      print('Warning: Failed to log activity - ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getLogAktivitas({
    String? namaTabel,
    int? limit = 100,
  }) async {
    var query = _client.from('log_aktivitas').select('''
      *,
      users(nama)
    ''');
    
    if (namaTabel != null) {
      query = query.eq('nama_tabel', namaTabel);
    }
    
    return await query
        .order('waktu_operasi', ascending: false)
        .limit(limit!);
  }
}
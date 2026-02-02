import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatImageService {
  static final _supabase = Supabase.instance.client;
  static const _bucket = 'alat-image';

  static Future<String> upload({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from(_bucket).getPublicUrl(path);
  }
}

import 'dart:io';
import 'package:uuid/uuid.dart';

class StorageService {
  final _uuid = const Uuid();

  Future<String> uploadPostImage(File imageFile) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final ext = imageFile.path.split('.').last;
    return 'https://picsum.photos/900/500?mock=${_uuid.v4()}.$ext';
  }

  Future<void> deleteImage(String publicUrl) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}

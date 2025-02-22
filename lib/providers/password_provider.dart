import 'package:flutter/foundation.dart';
import '../models/password_entry.dart';
import '../services/encryption_service.dart';
import 'package:msgpack_dart/msgpack_dart.dart' show serialize, deserialize;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PasswordProvider extends ChangeNotifier {
  final List<PasswordEntry> _passwords = [];
  final EncryptionService _encryptionService = EncryptionService();
  bool _isInitialized = false;

  List<PasswordEntry> get passwords => List.unmodifiable(_passwords);
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String masterPassword) async {
    await _encryptionService.initializeWithPassword(masterPassword);
    await _loadPasswords();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadPasswords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/passwords.db');
      
      if (await file.exists()) {
        final encrypted = await file.readAsBytes();
        final decrypted = await _encryptionService.decrypt(encrypted);
        final data = deserialize(Uint8List.fromList(decrypted)) as List;
        
        _passwords.clear();
        for (var item in data) {
          _passwords.add(PasswordEntry.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    } catch (e) {
      debugPrint('Error loading passwords: $e');
    }
  }

  Future<void> _savePasswords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/passwords.db');
      
      final data = _passwords.map((p) => p.toMap()).toList();
      final packed = serialize(data);
      final encrypted = await _encryptionService.encrypt(packed);
      
      await file.writeAsBytes(encrypted);
    } catch (e) {
      debugPrint('Error saving passwords: $e');
    }
  }

  Future<void> addPassword(PasswordEntry password) async {
    _passwords.add(password);
    await _savePasswords();
    notifyListeners();
  }

  Future<void> updatePassword(String id, PasswordEntry newPassword) async {
    final index = _passwords.indexWhere((p) => p.id == id);
    if (index != -1) {
      _passwords[index] = newPassword;
      await _savePasswords();
      notifyListeners();
    }
  }

  Future<void> deletePassword(String id) async {
    _passwords.removeWhere((p) => p.id == id);
    await _savePasswords();
    notifyListeners();
  }
}

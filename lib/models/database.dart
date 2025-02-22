import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/encryption_service.dart';
import 'password_entry.dart';
import 'package:msgpack_dart/msgpack_dart.dart' show serialize, deserialize;
import 'dart:typed_data';

class PasswordDatabase {
  static const String _databaseFileName = 'passwords.db';
  final EncryptionService _encryptionService;
  List<PasswordEntry> _passwords = [];
  bool _isDirty = false;

  PasswordDatabase(this._encryptionService);

  List<PasswordEntry> get passwords => List.unmodifiable(_passwords);

  Future<void> load() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_databaseFileName');

      if (await file.exists()) {
        final encryptedData = await file.readAsBytes();
        final decryptedData = await _encryptionService.decrypt(encryptedData);
        final unpacked = deserialize(Uint8List.fromList(decryptedData)) as List;
        
        _passwords = unpacked.map((item) => 
          PasswordEntry.fromMap(Map<String, dynamic>.from(item))
        ).toList();
      }
    } catch (e) {
      throw DatabaseException('Error al cargar la base de datos: $e');
    }
  }

  Future<void> save() async {
    if (!_isDirty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_databaseFileName');
      
      final data = _passwords.map((p) => p.toMap()).toList();
      final packed = serialize(data);
      final encrypted = await _encryptionService.encrypt(packed);
      
      await file.writeAsBytes(encrypted);
      _isDirty = false;
    } catch (e) {
      throw DatabaseException('Error al guardar la base de datos: $e');
    }
  }

  Future<void> addPassword(PasswordEntry password) async {
    _passwords.add(password);
    _isDirty = true;
    await save();
  }

  Future<void> updatePassword(String id, PasswordEntry newPassword) async {
    final index = _passwords.indexWhere((p) => p.id == id);
    if (index != -1) {
      _passwords[index] = newPassword;
      _isDirty = true;
      await save();
    }
  }

  Future<void> deletePassword(String id) async {
    _passwords.removeWhere((p) => p.id == id);
    _isDirty = true;
    await save();
  }

  Future<void> exportDatabase(String path, String password) async {
    final data = _passwords.map((p) => p.toMap()).toList();
    final packed = serialize(data);
    
    final tempEncryptionService = EncryptionService();
    await tempEncryptionService.initializeWithPassword(password);
    
    final encrypted = await tempEncryptionService.encrypt(packed);
    await File(path).writeAsBytes(encrypted);
  }

  Future<void> importDatabase(String path, String password) async {
    try {
      final encryptedData = await File(path).readAsBytes();
      
      final tempEncryptionService = EncryptionService();
      await tempEncryptionService.initializeWithPassword(password);
      
      final decryptedData = await tempEncryptionService.decrypt(encryptedData);
      final unpacked = deserialize(Uint8List.fromList(decryptedData)) as List;
      
      _passwords = unpacked.map((item) => 
        PasswordEntry.fromMap(Map<String, dynamic>.from(item))
      ).toList();
      
      _isDirty = true;
      await save();
    } catch (e) {
      throw DatabaseException('Error al importar la base de datos: $e');
    }
  }

  Future<void> clear() async {
    _passwords.clear();
    _isDirty = true;
    await save();
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => message;
}

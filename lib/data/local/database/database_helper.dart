import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const String _databaseName = 'expense_manager.sqlite';
  static const String _keyName = 'expense_database_encryption_key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();

      final databaseFile = File(p.join(directory.path, _databaseName));

      final encryptionKey = await _getOrCreateEncryptionKey();

      return NativeDatabase.createInBackground(
        databaseFile,
        setup: (rawDatabase) {
          // Check SQLiteMC availability.
          final cipherInfo = rawDatabase.select('PRAGMA cipher;');

          if (cipherInfo.isEmpty) {
            throw UnsupportedError('SQLiteMC encryption is not available.');
          }

          // Apply the encryption key before database access.
          final escapedKey = encryptionKey.replaceAll("'", "''");

          rawDatabase.execute("PRAGMA key = '$escapedKey'");

          // Verify that the database can be opened.
          rawDatabase.select('SELECT count(*) FROM sqlite_master');

          // Enable foreign key constraints.
          rawDatabase.execute('PRAGMA foreign_keys = ON');
        },
      );
    });
  }

  static Future<String> _getOrCreateEncryptionKey() async {
    String? encryptionKey = await _secureStorage.read(key: _keyName);

    if (encryptionKey != null && encryptionKey.isNotEmpty) {
      return encryptionKey;
    }

    // Generate a secure 256-bit random key.
    final random = Random.secure();

    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));

    encryptionKey = keyBytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    await _secureStorage.write(key: _keyName, value: encryptionKey);

    return encryptionKey;
  }
}

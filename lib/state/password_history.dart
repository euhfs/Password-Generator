import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// PasswordHistory
/// Manages the secure storage, retrieval, and manipulation of password history.
/// Uses FlutterSecureStorage for encrypted storage.
class PasswordHistory {
  final storage = FlutterSecureStorage();
  List<String> history = [];

  /// Loads password history from secure storage.
  Future<void> load() async {
    String? data = await storage.read(key: 'password_history');
    if (data != null) {
      history = List<String>.from(jsonDecode(data));
    }
  }

  /// Saves the current password history to secure storage.
  Future<void> save() async {
    await storage.write(
      key: 'password_history',
      value: jsonEncode(history),
    );
  }

  /// Adds a password to the history (most recent first, max 20 entries).
  void add(String password) {
    history.insert(0, password);
    if (history.length > 20) history.length = 20;
    save();
  }

  /// Deletes a password at the given index from history.
  void delete(int index) {
    history.removeAt(index);
    save();
  }

  /// Clears all password history.
  void clear() {
    history.clear();
    save();
  }

  /// Copies the given password to the clipboard.
  void copyToClipboard(String password) {
    Clipboard.setData(ClipboardData(text: password));
  }
}
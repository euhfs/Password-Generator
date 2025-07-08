import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SymbolController
/// Manages the symbol input field and persists its value using SharedPreferences.
class SymbolController {
  /// The TextEditingController for the symbols input.
  final TextEditingController controller = TextEditingController(
    text: '!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~',
  );

  /// Saves the current symbols to persistent storage.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('symbols', controller.text);
  }

  /// Loads the saved symbols from persistent storage.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('symbols');
    if (saved != null) {
      controller.text = saved;
    }
  }
}
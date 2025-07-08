import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_generator/constants/app_constants.dart';
import 'package:password_generator/utils/password_utils.dart';

class PasswordController {
  /// Generates a password based on the provided options.
  /// Returns the generated password as a String.
  String generatePassword({
    required int length,
    required bool useUppercase,
    required bool useLowercase,
    required bool useNumbers,
    required bool useSymbols,
    required String symbols,
    required bool excludeAmbiguous,
    required bool noRepeats,
    required bool noSequences,
  }) {
    String uppercase = useUppercase ? uppercaseChars : '';
    String lowercase = useLowercase ? lowercaseChars : '';
    String numbers = useNumbers ? numberChars : '';
    String symbolSet = useSymbols ? symbols : '';

    if (excludeAmbiguous) {
      uppercase = filterAmbiguous(uppercase);
      lowercase = filterAmbiguous(lowercase);
      numbers = filterAmbiguous(numbers);
      symbolSet = filterAmbiguous(symbolSet);
    }

    String allChars = uppercase + lowercase + numbers + symbolSet;
    if (allChars.isEmpty) return '';

    Random random = Random.secure();
    List<String> requiredChars = [];
    if (useUppercase) requiredChars.add(uppercaseChars[random.nextInt(uppercaseChars.length)]);
    if (useLowercase) requiredChars.add(lowercaseChars[random.nextInt(lowercaseChars.length)]);
    if (useNumbers) requiredChars.add(numberChars[random.nextInt(numberChars.length)]);
    if (useSymbols && symbols.isNotEmpty) {
      requiredChars.add(symbols[random.nextInt(symbols.length)]);
    }

    List<String> passwordChars = List.from(requiredChars);
    int maxAttempts = 1000;
    int attempts = 0;

    // Fill the password with random characters, respecting options
    while (passwordChars.length < length && attempts < maxAttempts) {
      String nextChar = allChars[random.nextInt(allChars.length)];
      if (noRepeats && passwordChars.contains(nextChar)) {
        attempts++;
        continue;
      }
      if (noSequences && passwordChars.isNotEmpty) {
        if (containsSequence(passwordChars, nextChar, length: 3)) {
          attempts++;
          continue;
        }
      }
      passwordChars.add(nextChar);
      attempts = 0;
    }

    if (passwordChars.length < length) return '';
    passwordChars.shuffle(random);
    return passwordChars.join();
  }

  /// Calculates password entropy and returns a map with entropy, label, and color.
  Map<String, dynamic> getPasswordStrength(String password, int charsetLength) {
    double entropy = password.length * (log(charsetLength) / log(2));
    String label;
    Color color;
    if (entropy < 28) {
      label = 'Very Weak';
      color = Colors.red;
    } else if (entropy < 37) {
      label = 'Weak';
      color = Colors.orange;
    } else if (entropy < 61) {
      label = 'Moderate';
      color = Colors.yellow;
    } else if (entropy < 81) {
      label = 'Strong';
      color = Colors.green;
    } else if (entropy < 128) {
      label = 'Very Strong';
      color = Colors.blue;
    } else {
      label = 'Exceptional';
      color = Colors.purple;
    }
    return {
      'entropy': entropy,
      'label': label,
      'color': color,
    };
  }

  /// Generates a passphrase using the provided word list and options.
  String generatePassphrase({
    required List<String> wordList,
    required int wordCount,
    required String separator,
    required bool capitalizeWords,
    required bool includeNumber,
    required bool includeSymbol,
  }) {
    if (wordList.isEmpty) return '';
    
    final random = Random.secure();
    List<String> words = [];
    Set<int> usedIndexes = {};
    for (int i = 0; i < wordCount; i++) {
      int idx;
      do {
        idx = random.nextInt(wordList.length);
      } while (usedIndexes.contains(idx));
      usedIndexes.add(idx);
      String word = wordList[idx];
      if (capitalizeWords) {
        word = word[0].toUpperCase() + word.substring(1);
      }
      words.add(word);
    }
    if (includeNumber && words.isNotEmpty) {
      int pos = random.nextInt(words.length);
      words[pos] = words[pos] + (random.nextInt(90) + 10).toString();
    }
    if (includeSymbol && words.isNotEmpty) {
      const symbols = '!@#\$%^&*';
      int pos = random.nextInt(words.length);
      words[pos] = words[pos] + symbols[random.nextInt(symbols.length)];
    }
    return words.join(separator);
  }

  /// Calculates passphrase entropy and returns a map with entropy, label, and color.
  Map<String, dynamic> getPassphraseStrength({
    required int wordCount,
    required int wordListLength,
    required bool includeNumber,
    required bool includeSymbol,
  }) {
    double entropy = wordCount * (log(wordListLength) / log(2));
    if (includeNumber) entropy += (log(90) / log(2));
    if (includeSymbol) entropy += (log(8) / log(2));
    String label;
    Color color;
    if (wordCount < 3) {
      label = 'Weak';
      color = Colors.red;
    } else if (wordCount < 5) {
      label = 'Strong';
      color = Colors.green;
    } else if (wordCount < 7) {
      label = 'Very Strong';
      color = Colors.blue;
    } else {
      label = 'Exceptional';
      color = Colors.purple;
    }
    return {
      'entropy': entropy,
      'label': label,
      'color': color,
    };
  }

  // --- Persistent settings helpers ---

  /// Loads passphrase switches (capitalize, number, symbol) from storage.
  Future<Map<String, bool>> loadPassphraseSwitches() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'capitalizeWords': prefs.getBool('capitalizeWords') ?? false,
      'includeNumber': prefs.getBool('includeNumber') ?? false,
      'includeSymbol': prefs.getBool('includeSymbol') ?? false,
    };
  }

  /// Saves passphrase switches (capitalize, number, symbol) to storage.
  Future<void> savePassphraseSwitches({
    required bool capitalizeWords,
    required bool includeNumber,
    required bool includeSymbol,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('capitalizeWords', capitalizeWords);
    prefs.setBool('includeNumber', includeNumber);
    prefs.setBool('includeSymbol', includeSymbol);
  }

  /// Loads password switches (uppercase, lowercase, numbers, symbols) from storage.
  Future<Map<String, bool>> loadPasswordSwitches() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'useUppercase': prefs.getBool('useUppercase') ?? true,
      'useLowercase': prefs.getBool('useLowercase') ?? true,
      'useNumbers': prefs.getBool('useNumbers') ?? true,
      'useSymbols': prefs.getBool('useSymbols') ?? true,
    };
  }

  /// Saves password switches (uppercase, lowercase, numbers, symbols) to storage.
  Future<void> savePasswordSwitches({
    required bool useUppercase,
    required bool useLowercase,
    required bool useNumbers,
    required bool useSymbols,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useUppercase', useUppercase);
    prefs.setBool('useLowercase', useLowercase);
    prefs.setBool('useNumbers', useNumbers);
    prefs.setBool('useSymbols', useSymbols);
  }

  /// Loads the passphrase separator from storage.
  Future<String> loadPassphraseSeparator() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('passphraseSeparator') ?? '-';
  }

  /// Saves the passphrase separator to storage.
  Future<void> savePassphraseSeparator(String separator) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('passphraseSeparator', separator);
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_generator/widgets/popup_menu_button.dart';
import 'package:password_generator/pages/feature_info_page.dart';
import 'package:password_generator/controllers/password_controller.dart';

class HomePage extends StatefulWidget {
  // Props passed from parent (global state, controllers, callbacks)
  final ValueChanged<int> onTab;
  final bool twelveCharsEnabled;
  final ValueChanged<bool> onTwelveCharsChanged;
  final TextEditingController symbolController;
  final bool excludeAmbiguous;
  final ValueChanged<bool> onExcludeAmbiguousChanged;
  final bool hideGeneratedPassword;
  final ValueChanged<bool> onHideGeneratedPasswordChanged;
  final List<String> passwordHistory;
  final bool hidePasswords;
  final void Function(String) copyToClipboard;
  final void Function(int) deleteFromHistory;
  final VoidCallback clearHistory;
  final VoidCallback toggleHidePasswords;
  final void Function(String) addToHistory;
  final bool noRepeats;
  final ValueChanged<bool> onNoRepeatsChanged;
  final bool noSequences;
  final ValueChanged<bool> onNoSequencesChanged;
  final bool isPasswordHistoryOn;
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const HomePage({
    super.key,
    required this.onTab,
    required this.twelveCharsEnabled,
    required this.onTwelveCharsChanged,
    required this.symbolController,
    required this.excludeAmbiguous,
    required this.onExcludeAmbiguousChanged,
    required this.hideGeneratedPassword,
    required this.onHideGeneratedPasswordChanged,
    required this.passwordHistory,
    required this.hidePasswords,
    required this.copyToClipboard,
    required this.deleteFromHistory,
    required this.clearHistory,
    required this.toggleHidePasswords,
    required this.addToHistory,
    required this.noRepeats,
    required this.onNoRepeatsChanged,
    required this.noSequences,
    required this.onNoSequencesChanged,
    required this.isPasswordHistoryOn,
    required this.themeMode,
    required this.setThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller for all password/passphrase logic
  final passwordController = PasswordController();

  // --- UI State ---
  bool useUppercase = true;
  bool useLowercase = true;
  bool useNumbers = true;
  bool useSymbols = true;
  bool capitalizeWords = false;
  bool includeNumber = false;
  bool includeSymbol = false;
  int selectedType = 0; // 0 = Password, 1 = Passphrase
  int passphraseWordCount = 4;
  String passphraseSeparator = '-';
  List<String> wordList = [];
  final TextEditingController lengthController = TextEditingController(
    text: '12',
  );
  final TextEditingController resultController = TextEditingController();
  final TextEditingController passphraseController = TextEditingController();
  final TextEditingController customSeparatorController =
      TextEditingController();

  // Strength info for password/passphrase
  double passwordEntropy = 0;
  String passwordStrengthLabel = '';
  Color passwordStrengthColor = Colors.red;
  double passphraseEntropy = 0;
  String passphraseStrengthLabel = '';
  Color passphraseStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    customSeparatorController.text = '-';
    passphraseSeparator = '-';
    _loadWordList();
    _loadSwitchesAndSeparator();
  }

  /// Loads the word list for passphrase generation from assets.
  Future<void> _loadWordList() async {
    final words = await rootBundle.loadString('assets/passphraselist.txt');
    if (!mounted) return;
    setState(() {
      wordList = words
          .split('\n')
          .map((line) => line.trim().split('\t').last)
          .where((w) => w.isNotEmpty)
          .toList();
    });
  }

  /// Loads saved switches and separator from persistent storage.
  Future<void> _loadSwitchesAndSeparator() async {
    final passwordSwitches = await passwordController.loadPasswordSwitches();
    final passphraseSwitches = await passwordController
        .loadPassphraseSwitches();
    final sep = await passwordController.loadPassphraseSeparator();
    if (!mounted) return;
    setState(() {
      useUppercase = passwordSwitches['useUppercase']!;
      useLowercase = passwordSwitches['useLowercase']!;
      useNumbers = passwordSwitches['useNumbers']!;
      useSymbols = passwordSwitches['useSymbols']!;
      capitalizeWords = passphraseSwitches['capitalizeWords']!;
      includeNumber = passphraseSwitches['includeNumber']!;
      includeSymbol = passphraseSwitches['includeSymbol']!;
      passphraseSeparator = sep;
      customSeparatorController.text = sep;
    });
  }

  /// Generates a password using the controller and updates UI state.
  void generatePassword() {
    int length = int.tryParse(lengthController.text) ?? 12;

    // Adjust length based on specific conditions
    if (widget.twelveCharsEnabled && length < 12) length = 12;
    if (!widget.twelveCharsEnabled && length < 5) length = 5;

    final password = passwordController.generatePassword(
      length: length,
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useNumbers: useNumbers,
      useSymbols: useSymbols,
      symbols: widget.symbolController.text,
      excludeAmbiguous: widget.excludeAmbiguous,
      noRepeats: widget.noRepeats,
      noSequences: widget.noSequences,
    );
    resultController.text = password;

    if (widget.isPasswordHistoryOn && password.isNotEmpty) {
      widget.addToHistory(password);
    }

    // Calculate available unique characters based on the selected options
    final charsetLength =
        (useUppercase ? 26 : 0) +
        (useLowercase ? 26 : 0) +
        (useNumbers ? 10 : 0) +
        (useSymbols ? widget.symbolController.text.length : 0);

    // Show toast if noRepeats setting is on and its not avaiable to create loger passwords
    if (widget.noRepeats && length > charsetLength) {
      Fluttertoast.showToast(
        msg: 'Disable "No Repeating Characters" for longer passwords',
        toastLength: Toast.LENGTH_LONG,
      );
    }
    final strength = passwordController.getPasswordStrength(
      password,
      charsetLength,
    );
    setState(() {
      passwordEntropy = strength['entropy'];
      passwordStrengthLabel = strength['label'];
      passwordStrengthColor = strength['color'];
    });
  }

  /// Generates a passphrase using the controller and updates UI state.
  void generatePassphrase() {
    if (wordList.isEmpty) {
      Fluttertoast.showToast(
        msg: "Word list not loaded",
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }
    final passphrase = passwordController.generatePassphrase(
      wordList: wordList,
      wordCount: passphraseWordCount,
      separator: passphraseSeparator,
      capitalizeWords: capitalizeWords,
      includeNumber: includeNumber,
      includeSymbol: includeSymbol,
    );
    passphraseController.text = passphrase;

    if (widget.isPasswordHistoryOn && passphrase.isNotEmpty) {
      widget.addToHistory(passphrase);
    }

    final strength = passwordController.getPassphraseStrength(
      wordCount: passphraseWordCount,
      wordListLength: wordList.length,
      includeNumber: includeNumber,
      includeSymbol: includeSymbol,
    );
    setState(() {
      passphraseEntropy = strength['entropy'];
      passphraseStrengthLabel = strength['label'];
      passphraseStrengthColor = strength['color'];
    });
  }

  /// Saves password switches using the controller.
  void savePasswordSwitches() {
    passwordController.savePasswordSwitches(
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useNumbers: useNumbers,
      useSymbols: useSymbols,
    );
  }

  /// Saves passphrase switches using the controller.
  void savePassphraseSwitches() {
    passwordController.savePassphraseSwitches(
      capitalizeWords: capitalizeWords,
      includeNumber: includeNumber,
      includeSymbol: includeSymbol,
    );
  }

  /// Saves passphrase separator using the controller.
  void savePassphraseSeparator() {
    passwordController.savePassphraseSeparator(passphraseSeparator);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 600) {
      return buildFullDesktopScaffold(context);
    } else {
      return buildFullMobileScaffold(context);
    }
  }

  // Mobile UI
  Widget buildFullMobileScaffold(BuildContext context) {
    final theme = Theme.of(context);

    // Main scaffold for the page
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text('Password Generator'),
        actions: [
          // Info button
          IconButton(
            icon: Icon(Icons.info_outline),
            color: theme.iconTheme.color,
            splashColor: Colors.transparent,
            tooltip: 'How this works',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FeatureInfoPage()),
              );
            },
          ),
          // Popup menu for symbols/history/theme
          ResetSymbolsMenu(
            symbolController: widget.symbolController,
            passwordHistory: widget.passwordHistory,
            copyToClipboard: widget.copyToClipboard,
            deleteFromHistory: widget.deleteFromHistory,
            clearHistory: widget.clearHistory,
            setThemeMode: widget.setThemeMode,
            themeMode: widget.themeMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Tab Switcher (Password/Passphrase) ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      // Password tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedType = 0);
                            generatePassword();
                          },
                          child: Padding(
                            padding: selectedType == 0
                                ? EdgeInsets.all(5.5)
                                : EdgeInsets.zero,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              curve: Curves.ease,
                              height: 54,
                              decoration: BoxDecoration(
                                color: selectedType == 0
                                    ? theme.scaffoldBackgroundColor
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: selectedType == 0 ? 8 : 0,
                              ),
                              child: Center(
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Passphrase tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedType = 1);
                            generatePassphrase();
                          },
                          child: Padding(
                            padding: selectedType == 1
                                ? EdgeInsets.all(4)
                                : EdgeInsets.zero,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              curve: Curves.ease,
                              height: 56,
                              decoration: BoxDecoration(
                                color: selectedType == 1
                                    ? theme.scaffoldBackgroundColor
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: selectedType == 1 ? 8 : 0,
                              ),
                              child: Center(
                                child: Text(
                                  'Passphrase',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Password UI ---
              selectedType == 0
                  ? buildPasswordUI(theme)
                  : buildPassphraseUI(theme),
            ],
          ),
        ),
      ),
    );
  }

  // Password UI section, fully theme-adaptive
  Widget buildPasswordUI(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Spacer
        const SizedBox(height: 5),

        // Output field for password
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              maxLines: widget.hideGeneratedPassword ? 1 : null,
              readOnly: widget.hideGeneratedPassword,
              obscureText: widget.hideGeneratedPassword,
              controller: resultController,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: theme.textTheme.bodyMedium?.color,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ),

        // Password strength bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 4),
          child: LinearProgressIndicator(
            value: (passwordEntropy / 128).clamp(0.0, 1.0),
            backgroundColor: theme.dividerColor,
            minHeight: 4,
            valueColor: AlwaysStoppedAnimation<Color>(passwordStrengthColor),
          ),
        ),

        // Spacer
        const SizedBox(height: 4),

        // Strength label
        Center(
          child: Text(
            '$passwordStrengthLabel (${passwordEntropy.toStringAsFixed(1)} bits)',
            style: TextStyle(
              color: passwordStrengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Generate and Copy buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Generate Button
              SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: generatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      elevation: 0,
                    ),
                    child: Text(
                      'Generate Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),

              // Spacer
              const SizedBox(height: 10),

              // Copy Button
              SizedBox(
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: resultController.text),
                      ).then((_) {
                        Fluttertoast.showToast(
                          msg: "Password was copied to your clipboard",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      elevation: 0,
                    ),
                    child: Text(
                      'Copy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Password length selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Length:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 24,
                  ),
                ),
                SizedBox(width: 14),

                // Length input field
                Container(
                  width: 70,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    controller: lengthController,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 3,
                    onSubmitted: (value) {
                      int? length = int.tryParse(value);
                      int min = widget.twelveCharsEnabled ? 12 : 5;
                      if (length == null || length < min) {
                        lengthController.text = min.toString();
                      }
                      generatePassword();
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: theme.textTheme.bodyMedium?.color,
                      decoration: TextDecoration.none,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: 'Tap',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodySmall?.color == null
                            ? null
                            : theme.textTheme.bodySmall!.color!.withAlpha(
                                (0.5 * 255).toInt(),
                              ),
                        fontSize: 18,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    autofillHints: null,
                  ),
                ),

                // Spacer
                Spacer(),

                // Decrement button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 22),
                    color: theme.textTheme.bodyMedium?.color,
                    onPressed: () {
                      String text = lengthController.text;
                      int? value = int.tryParse(text);
                      int min = widget.twelveCharsEnabled ? 12 : 5;
                      if (value != null && value > min) {
                        lengthController.text = (value - 1).toString();
                        generatePassword();
                      }
                    },
                  ),
                ),

                // Spacer
                const SizedBox(width: 8),

                // Increment button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.add, size: 22),
                    color: theme.textTheme.bodyMedium?.color,
                    onPressed: () {
                      String text = lengthController.text;
                      int? value = int.tryParse(text);
                      if (value != null && value < 999) {
                        lengthController.text = (value + 1).toString();
                        generatePassword();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Password switches (A-Z, a-z, 0-9, Symbols)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              children: [
                // Uppercase switch
                SwitchListTile(
                  value: useUppercase,
                  onChanged: (val) {
                    setState(() => useUppercase = val);
                    generatePassword();
                    savePasswordSwitches();
                  },
                  title: Text(
                    'A-Z',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Divider
                Divider(color: theme.dividerColor),

                // Lowercase switch
                SwitchListTile(
                  value: useLowercase,
                  onChanged: (val) {
                    setState(() => useLowercase = val);
                    generatePassword();
                    savePasswordSwitches();
                  },
                  title: Text(
                    'a-z',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Divider
                Divider(color: theme.dividerColor),

                // Numbers switch
                SwitchListTile(
                  value: useNumbers,
                  onChanged: (val) {
                    setState(() => useNumbers = val);
                    generatePassword();
                    savePasswordSwitches();
                  },
                  title: Text(
                    '0-9',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Divider
                Divider(color: theme.dividerColor),

                // Symbols switch
                SwitchListTile(
                  value: useSymbols,
                  onChanged: (val) {
                    setState(() {
                      useSymbols = val;
                      if (widget.twelveCharsEnabled == true) {
                        lengthController.text = '12';
                      }
                    });
                    generatePassword();
                    savePasswordSwitches();
                    if (val && widget.symbolController.text.trim().isEmpty) {
                      Fluttertoast.showToast(
                        msg:
                            "Symbols switch is ON but no symbols are provided.",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  },
                  title: Text(
                    'Symbols',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Spacer
        const SizedBox(height: 20),
      ],
    );
  }

  // Passphrase UI section, fully theme-adaptive
  Widget buildPassphraseUI(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Spacer
        SizedBox(height: 5),

        // Output field for passphrase
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              maxLines: null,
              controller: passphraseController,
              readOnly: widget.hideGeneratedPassword,
              obscureText: widget.hideGeneratedPassword,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: theme.textTheme.bodyMedium?.color,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
              ),
              cursorColor: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),

        // Passphrase strength bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 4),
          child: LinearProgressIndicator(
            value: (passphraseEntropy / 128).clamp(0.0, 1.0),
            backgroundColor: theme.dividerColor,
            minHeight: 4,
            valueColor: AlwaysStoppedAnimation<Color>(passphraseStrengthColor),
          ),
        ),

        // Spacer
        const SizedBox(height: 4),

        // Strength label
        Center(
          child: Text(
            passphraseStrengthLabel,
            style: TextStyle(
              color: passphraseStrengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Generate and Copy buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: generatePassphrase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      elevation: 0,
                    ),
                    child: Text(
                      'Generate Passphrase',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: passphraseController.text),
                      ).then((_) {
                        Fluttertoast.showToast(
                          msg: 'Passphrase was copied to your clipboard.',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      elevation: 0,
                    ),
                    child: Text(
                      'Copy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Passphrase word count selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Words:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 24,
                  ),
                ),
                SizedBox(width: 18),
                // Word count input field
                Container(
                  width: 70,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: passphraseWordCount.toString(),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 2,
                    onSubmitted: (value) {
                      int? count = int.tryParse(value);
                      if (count != null && count > 1 && count < 21) {
                        setState(() => passphraseWordCount = count);
                        generatePassphrase();
                      }

                      if (count! < 2) {
                        passphraseWordCount = 2;
                        generatePassphrase();
                      } else if (count > 20) {
                        passphraseWordCount = 20;
                        generatePassphrase();
                      }
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: theme.textTheme.bodyMedium?.color,
                      decoration: TextDecoration.none,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: '4',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodySmall?.color == null
                            ? null
                            : theme.textTheme.bodySmall!.color!.withAlpha(
                                (0.5 * 255).toInt(),
                              ),
                        fontSize: 18,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    autofillHints: null,
                  ),
                ),

                // Spacer
                Spacer(),

                // Decrement button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 22),
                    color: theme.textTheme.bodyMedium?.color,
                    onPressed: () {
                      if (passphraseWordCount > 2) {
                        setState(() => passphraseWordCount--);
                        generatePassphrase();
                      }
                    },
                  ),
                ),

                // Spacer
                const SizedBox(width: 8),

                // Increment button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.add, size: 22),
                    color: theme.textTheme.bodyMedium?.color,
                    onPressed: () {
                      if (passphraseWordCount < 20) {
                        setState(() => passphraseWordCount++);
                        generatePassphrase();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Separator input
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  'Separator:',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Spacer
                const SizedBox(width: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () async {
                    String? newSep = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        String tempSep = passphraseSeparator;
                        return StatefulBuilder(
                          builder: (context, setDialogState) => AlertDialog(
                            backgroundColor: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'Choose Separator',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var s in [' ', '-', '_', '.'])
                                      GestureDetector(
                                        onTap: () {
                                          setDialogState(() => tempSep = s);
                                          Navigator.of(context).pop(s);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            color: tempSep == s
                                                ? const Color.fromARGB(
                                                    255,
                                                    84,
                                                    172,
                                                    255,
                                                  )
                                                : const Color.fromARGB(
                                                    255,
                                                    207,
                                                    207,
                                                    207,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            s == ' ' ? 'Space' : s,
                                            style: TextStyle(
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Spacer
                                const SizedBox(height: 16),

                                // Textfield
                                TextField(
                                  autofocus: true,
                                  maxLength: 2,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontSize: 22,
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color.fromARGB(
                                          255,
                                          128,
                                          128,
                                          128,
                                        ),
                                        width: 1.0,
                                      ),
                                    ),
                                    counterText: '',
                                    hintText: 'Type any char',
                                    hintStyle: TextStyle(
                                      color:
                                          theme.textTheme.bodySmall?.color !=
                                              null
                                          ? theme.textTheme.bodySmall!.color!
                                                .withAlpha((0.38 * 255).toInt())
                                          : Colors.grey.withAlpha(
                                              (0.38 * 255).toInt(),
                                            ),
                                    ),
                                    filled: true,
                                    fillColor: theme.scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.tealAccent,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    if (val.isNotEmpty) {
                                      setDialogState(() => tempSep = val);
                                    }
                                  },
                                  onSubmitted: (val) {
                                    if (val.isNotEmpty) {
                                      Navigator.of(context).pop(val);
                                    }
                                  },
                                ),
                              ],
                            ),

                            // Actions
                            actions: [
                              // Cancel TextButton
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // OK TextButton
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(tempSep),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    if (newSep != null && newSep.isNotEmpty) {
                      setState(() {
                        passphraseSeparator = newSep;
                        customSeparatorController.text = newSep;
                        generatePassphrase();
                      });
                      savePassphraseSeparator();
                    }
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    curve: Curves.ease,
                    height: 48,
                    width: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      passphraseSeparator == ' ' ? '␣' : passphraseSeparator,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Passphrase switches (Capitalize, Include Number, Include Symbol)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              children: [
                // Capitalize Words switch
                SwitchListTile(
                  value: capitalizeWords,
                  onChanged: (val) {
                    setState(() => capitalizeWords = val);
                    generatePassphrase();
                    savePassphraseSwitches();
                  },
                  title: Text(
                    'Capitalize Words',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Divider
                Divider(color: theme.dividerColor),

                // Include Number switch
                SwitchListTile(
                  value: includeNumber,
                  onChanged: (val) {
                    setState(() => includeNumber = val);
                    generatePassphrase();
                    savePassphraseSwitches();
                  },
                  title: Text(
                    'Include Number',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Divider
                Divider(color: theme.dividerColor),

                // Include Symbol switch
                SwitchListTile(
                  value: includeSymbol,
                  onChanged: (val) {
                    setState(() => includeSymbol = val);
                    generatePassphrase();
                    savePassphraseSwitches();
                  },
                  title: Text(
                    'Include Symbol',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Spacer
        const SizedBox(height: 20),
      ],
    );
  }
}

// Desktop UI
Widget buildFullDesktopScaffold(BuildContext context) {
  // ignore: unused_local_variable
  final theme = Theme.of(context);

  return Scaffold(backgroundColor: theme.scaffoldBackgroundColor);
}

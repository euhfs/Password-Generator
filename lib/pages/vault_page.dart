import 'package:flutter/material.dart';
import 'package:password_generator/pages/feature_info_page.dart';
import 'package:password_generator/widgets/popup_menu_button.dart';

/// VaultPage
/// Placeholder page for a future password vault feature.
/// Uses only theme colors for backgrounds, text, and icons.
class VaultPage extends StatefulWidget {
  final ValueChanged<int> onTab;
  final List<String> passwordHistory;
  final bool hidePasswords;
  final void Function(String) copyToClipboard;
  final void Function(int) deleteFromHistory;
  final VoidCallback clearHistory;
  final VoidCallback toggleHidePasswords;
  final TextEditingController symbolController;
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const VaultPage({
    super.key,
    required this.onTab,
    required this.passwordHistory,
    required this.hidePasswords,
    required this.copyToClipboard,
    required this.deleteFromHistory,
    required this.clearHistory,
    required this.toggleHidePasswords,
    required this.symbolController,
    required this.themeMode,
    required this.setThemeMode,
  });

  @override
  State<VaultPage> createState() => VaultPageState();
}

class VaultPageState extends State<VaultPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Main scaffold for the vault page
    return Scaffold(
      appBar: AppBar(
        title: Text('Vault'),
        centerTitle: false,
        actions: [
          // Info button
          IconButton(
            icon: Icon(Icons.info_outline),
            color: theme.iconTheme.color,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          //TODO: make this page
          'Coming soon!',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 46,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

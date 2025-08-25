import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_generator/pages/feature_info_page.dart';
import 'package:password_generator/widgets/popup_menu_button.dart';

/// SettingsPage
/// UI for app-wide settings and options.
/// Uses only theme colors for backgrounds, text, and switches.
class SettingsPage extends StatelessWidget {
  // Callbacks and state for all settings
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
  final bool noRepeats;
  final ValueChanged<bool> onNoRepeatsChanged;
  final bool noSequences;
  final ValueChanged<bool> onNoSequencesChanged;
  final bool isPasswordHistoryOn;
  final ValueChanged<bool> onPasswordHistoryChanged;
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const SettingsPage({
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
    required this.noRepeats,
    required this.onNoRepeatsChanged,
    required this.noSequences,
    required this.onNoSequencesChanged,
    required this.isPasswordHistoryOn,
    required this.onPasswordHistoryChanged,
    required this.themeMode,
    required this.setThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme colors for backgrounds and text
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text('Settings'),
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
            symbolController: symbolController,
            passwordHistory: passwordHistory,
            copyToClipboard: copyToClipboard,
            deleteFromHistory: deleteFromHistory,
            clearHistory: clearHistory,
            setThemeMode: setThemeMode,
            themeMode: themeMode,
          ),
        ],
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main settings container
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    // Rounded settings box
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          // 12 Characters Minimum switch
                          SwitchListTile(
                            value: twelveCharsEnabled,
                            onChanged: onTwelveCharsChanged,
                            title: Text(
                              '12 Characters Minimum',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(color: theme.dividerColor),
                          // No Repeating Characters switch
                          SwitchListTile(
                            value: noRepeats,
                            onChanged: onNoRepeatsChanged,
                            title: Text(
                              'No Repeating Characters',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(color: theme.dividerColor),
                          // No Sequential Characters switch
                          SwitchListTile(
                            value: noSequences,
                            onChanged: onNoSequencesChanged,
                            title: Text(
                              'No Sequential Characters',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(color: theme.dividerColor),
                          // Exclude Ambiguous Characters switch
                          SwitchListTile(
                            value: excludeAmbiguous,
                            onChanged: onExcludeAmbiguousChanged,
                            title: Text(
                              'Exclude Ambiguous Characters (O0l1I)',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(color: theme.dividerColor),
                          // Symbols input field
                          ListTile(
                            title: Row(
                              children: [
                                Text(
                                  'Symbols',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 170,
                              child: TextField(
                                controller: symbolController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(
                                      r'''[!"#\$%&'()*+,\-./:;<=>?@\[\]^_`{|}~]''',
                                    ),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Enter symbols',
                                  filled: true,
                                  fillColor: theme.cardColor.withAlpha(
                                    (0.9 * 255).toInt(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacer
                    SizedBox(height: 15),

                    // Password history switch
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: isPasswordHistoryOn,
                            onChanged: onPasswordHistoryChanged,
                            title: Text(
                              'Password History',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(color: theme.dividerColor),

                          // Hide generated password switch
                          SwitchListTile(
                            onChanged: onHideGeneratedPasswordChanged,
                            value: hideGeneratedPassword,
                            title: Text(
                              'Hide generated password',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          /*Divider(color: theme.dividerColor),
                          SwitchListTile(
                            value: false,
                            onChanged: (value) {
                              // TODO Handle the switch change
                            },
                            title: Text(
                              'Lock Password History',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ), */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

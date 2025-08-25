import 'package:flutter/material.dart';
import 'package:password_generator/pages/about_page.dart';

/// ResetSymbolsMenu
/// Popup menu for resetting the symbols field to default and managing password history.
/// Includes options for resetting symbols, viewing/copying/deleting password history,
/// and revealing/hiding passwords in the history.
class ResetSymbolsMenu extends StatefulWidget {
  final TextEditingController symbolController;
  final List<String> passwordHistory;
  final void Function(String) copyToClipboard;
  final void Function(int) deleteFromHistory;
  final VoidCallback clearHistory;
  final void Function(ThemeMode) setThemeMode;
  final ThemeMode themeMode;

  const ResetSymbolsMenu({
    super.key,
    required this.symbolController,
    required this.passwordHistory,
    required this.copyToClipboard,
    required this.deleteFromHistory,
    required this.clearHistory,
    required this.setThemeMode,
    required this.themeMode,
  });

  @override
  State<ResetSymbolsMenu> createState() => _ResetSymbolsMenuState();
}

class _ResetSymbolsMenuState extends State<ResetSymbolsMenu> {
  Set<int> revealedIndices = {};
  bool revealAll = false;

  @override
  Widget build(BuildContext context) {
    // Main popup menu button
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: IconTheme.of(context).color),
      color: Theme.of(context).scaffoldBackgroundColor,
      onSelected: (value) async {
        // Handle menu actions
        if (value == 'reset_symbols') {
          // Confirm reset symbols
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Reset Symbols?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to reset the symbols to default?',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.tealAccent, fontSize: 20),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Reset',
                    style: TextStyle(color: Colors.redAccent, fontSize: 20),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            widget.symbolController.text =
                '!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';
          }
        } else if (value == 'password_history') {
          // Show password history modal
          showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            builder: (ctx) => StatefulBuilder(
              builder: (modalContext, setModalState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 8, bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header row with actions
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Text(
                          'Password History',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // Reveal/hide all passwords
                        IconButton(
                          icon: Icon(
                            revealAll ? Icons.visibility_off : Icons.visibility,
                            color: Colors.tealAccent,
                            size: 24,
                          ),
                          onPressed: () {
                            setModalState(() {
                              if (revealAll) {
                                revealedIndices.clear();
                                revealAll = false;
                              } else {
                                revealedIndices = Set.from(
                                  List.generate(
                                    widget.passwordHistory.length,
                                    (i) => i,
                                  ),
                                );
                                revealAll = true;
                              }
                            });
                          },
                          tooltip: revealAll ? 'Hide All' : 'Reveal All',
                        ),
                        // Delete all passwords
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.red[300],
                            size: 24,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                title: Text(
                                  'Delete All Passwords?',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  'Are you sure you want to delete all password history? This cannot be undone.',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 20,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 20,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              widget.clearHistory();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                          },
                          tooltip: 'Delete All',
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[800]),
                  // Password history list
                  Expanded(
                    child: widget.passwordHistory.isEmpty
                        ? Center(
                            child: Text(
                              'No passwords yet.',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.passwordHistory.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey[800]),
                            itemBuilder: (context, index) {
                              final password = widget.passwordHistory[index];
                              final isRevealed = revealedIndices.contains(
                                index,
                              );
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                title: Text(
                                  isRevealed ? password : '•' * 10,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Copy password
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          widget.copyToClipboard(password),
                                      tooltip: 'Copy',
                                    ),
                                    // Delete password
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[300],
                                        size: 24,
                                      ),
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                            title: Text(
                                              'Delete Password?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete this password?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.tealAccent,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                              ),
                                              TextButton(
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          widget.deleteFromHistory(index);
                                        }
                                      },
                                      tooltip: 'Delete',
                                    ),
                                    // Reveal/hide password
                                    IconButton(
                                      icon: Icon(
                                        isRevealed
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          if (revealedIndices.contains(index)) {
                                            revealedIndices.remove(index);
                                          } else {
                                            revealedIndices.add(index);
                                          }
                                        });
                                      },
                                      tooltip: isRevealed ? 'Hide' : 'Reveal',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        } else if (value == 'app_theme') {
          // Show a dialog to select the app theme (System, Dark, Light)
          String selectedTheme = widget.themeMode == ThemeMode.system
              ? 'system'
              : widget.themeMode == ThemeMode.dark
              ? 'dark'
              : 'light';

          showDialog(
            context: context,
            builder: (ctx) {
              return StatefulBuilder(
                builder: (context, setDialogState) => AlertDialog(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Choose App Theme',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // System Theme option
                      _ThemeRadioTile(
                        value: 'system',
                        groupValue: selectedTheme,
                        icon: Icons.brightness_auto,
                        label: 'System Theme',
                        onChanged: (val) {
                          setDialogState(() => selectedTheme = val!);
                          widget.setThemeMode(ThemeMode.system);
                        },
                      ),
                      // Dark Theme option
                      _ThemeRadioTile(
                        value: 'dark',
                        groupValue: selectedTheme,
                        icon: Icons.dark_mode,
                        label: 'Dark Theme',
                        onChanged: (val) {
                          setDialogState(() => selectedTheme = val!);
                          widget.setThemeMode(ThemeMode.dark);
                        },
                      ),
                      // Light Theme option
                      _ThemeRadioTile(
                        value: 'light',
                        groupValue: selectedTheme,
                        icon: Icons.light_mode,
                        label: 'Light Theme',
                        onChanged: (val) {
                          setDialogState(() => selectedTheme = val!);
                          widget.setThemeMode(ThemeMode.light);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (value == 'about_page') {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AboutPage()));
        }
      },
      // Menu items
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'reset_symbols',
          child: Text(
            'Reset symbols to default',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuItem(
          value: 'password_history',
          child: Text(
            'Password History',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuItem(
          value: 'app_theme',
          child: Text(
            'App Theme',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuItem(
          value: 'about_page',
          child: Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Custom radio tile for theme selection dialog.
/// Shows a circular radio button, an icon, and a label.
class _ThemeRadioTile extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final ValueChanged<String?> onChanged;

  const _ThemeRadioTile({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isSelected = value == groupValue;

    // Get the current theme (light or dark)
    final theme = Theme.of(context);

    // Determine the text color based on the current theme
    Color textColor;
    if (theme.brightness == Brightness.dark) {
      textColor = Colors.white; // Dark theme, text should be white
    } else {
      textColor = Colors.black; // Light theme, text should be black
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value), // Select this option when tapped
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // The radio button (circle)
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.grey[400], // Light gray when selected
              fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.grey[400]; // Active color
                }
                return Colors.grey[700]; // Inactive color
              }),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            // The icon for the theme
            Icon(icon, color: theme.iconTheme.color),
            SizedBox(width: 12),
            // The label for the theme
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor, // Apply the dynamic text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

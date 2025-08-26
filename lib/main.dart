import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_generator/pages/settings_page.dart';
import 'package:password_generator/pages/home_page.dart';
import 'package:password_generator/pages/vault_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'state/app_settings.dart';
import 'state/password_history.dart';
import 'controllers/symbol_controller.dart';
import 'constants/app_themes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentIndex = 1;
  ThemeMode themeMode = ThemeMode.system;

  final appSettings = AppSettings();
  final passwordHistory = PasswordHistory();
  final symbolController = SymbolController();

  @override
  void initState() {
    super.initState();
    appSettings.load().then((_) {
      setState(() {
        themeMode = appSettings.themeMode;
      });
    });
    passwordHistory.load().then((_) => setState(() {}));
    symbolController.load().then((_) => setState(() {}));
    symbolController.controller.addListener(() {
      symbolController.save();
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      themeMode = mode;
      appSettings.setThemeMode(mode);
    });
  }

  void _onTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness effectiveBrightness = MediaQuery.of(
      context,
    ).platformBrightness;

    final darkNavBarColor = const Color.fromARGB(255, 30, 30, 30);
    final lightNavBarColor = const Color.fromARGB(255, 255, 255, 255);

    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            effectiveBrightness == Brightness.dark);

    final navBarColor = isDark ? darkNavBarColor : lightNavBarColor;
    final navBarIconBrightness = isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness: navBarIconBrightness,
      ),
      child: MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            final width = MediaQuery.of(context).size.width;

            if (width >= 850) {
              return [
                VaultPage(
                  onTab: _onTab,
                  passwordHistory: passwordHistory.history,
                  hidePasswords: appSettings.hidePasswords,
                  copyToClipboard: passwordHistory.copyToClipboard,
                  deleteFromHistory: passwordHistory.delete,
                  symbolController: symbolController.controller,
                  clearHistory: passwordHistory.clear,
                  toggleHidePasswords: () {
                    setState(() {
                      appSettings.hidePasswords = !appSettings.hidePasswords;
                      appSettings.save();
                    });
                  },
                  themeMode: themeMode,
                  setThemeMode: setThemeMode,
                ),
                HomePage(
                  onTab: _onTab,
                  twelveCharsEnabled: appSettings.twelveCharsEnabled,
                  onTwelveCharsChanged: (val) {
                    setState(() {
                      appSettings.twelveCharsEnabled = val;
                      appSettings.save();
                    });
                  },
                  symbolController: symbolController.controller,
                  excludeAmbiguous: appSettings.excludeAmbiguous,
                  onExcludeAmbiguousChanged: (val) {
                    setState(() {
                      appSettings.excludeAmbiguous = val;
                      appSettings.save();
                    });
                  },
                  hideGeneratedPassword: appSettings.hideGeneratedPassword,
                  onHideGeneratedPasswordChanged: (val) {
                    setState(() {
                      appSettings.hideGeneratedPassword = val;
                      appSettings.save();
                    });
                  },
                  passwordHistory: passwordHistory.history,
                  hidePasswords: appSettings.hidePasswords,
                  copyToClipboard: passwordHistory.copyToClipboard,
                  deleteFromHistory: passwordHistory.delete,
                  clearHistory: passwordHistory.clear,
                  toggleHidePasswords: () {
                    setState(() {
                      appSettings.hidePasswords = !appSettings.hidePasswords;
                      appSettings.save();
                    });
                  },
                  addToHistory: passwordHistory.add,
                  noRepeats: appSettings.noRepeats,
                  onNoRepeatsChanged: (val) {
                    setState(() {
                      appSettings.noRepeats = val;
                      appSettings.save();
                    });
                  },
                  noSequences: appSettings.noSequences,
                  onNoSequencesChanged: (val) {
                    setState(() {
                      appSettings.noSequences = val;
                      appSettings.save();
                    });
                  },
                  isPasswordHistoryOn: appSettings.isPasswordHistoryOn,
                  themeMode: themeMode,
                  setThemeMode: setThemeMode,
                ),
                SettingsPage(
                  onTab: _onTab,
                  twelveCharsEnabled: appSettings.twelveCharsEnabled,
                  onTwelveCharsChanged: (val) {
                    setState(() {
                      appSettings.twelveCharsEnabled = val;
                      appSettings.save();
                    });
                  },
                  symbolController: symbolController.controller,
                  excludeAmbiguous: appSettings.excludeAmbiguous,
                  onExcludeAmbiguousChanged: (val) {
                    setState(() {
                      appSettings.excludeAmbiguous = val;
                      appSettings.save();
                    });
                  },
                  hideGeneratedPassword: appSettings.hideGeneratedPassword,
                  onHideGeneratedPasswordChanged: (val) {
                    setState(() {
                      appSettings.hideGeneratedPassword = val;
                      appSettings.save();
                    });
                  },
                  passwordHistory: passwordHistory.history,
                  hidePasswords: appSettings.hidePasswords,
                  copyToClipboard: passwordHistory.copyToClipboard,
                  deleteFromHistory: passwordHistory.delete,
                  clearHistory: passwordHistory.clear,
                  toggleHidePasswords: () {
                    setState(() {
                      appSettings.hidePasswords = !appSettings.hidePasswords;
                      appSettings.save();
                    });
                  },
                  noRepeats: appSettings.noRepeats,
                  onNoRepeatsChanged: (val) {
                    setState(() {
                      appSettings.noRepeats = val;
                      appSettings.save();
                    });
                  },
                  noSequences: appSettings.noSequences,
                  onNoSequencesChanged: (val) {
                    setState(() {
                      appSettings.noSequences = val;
                      appSettings.save();
                    });
                  },
                  isPasswordHistoryOn: appSettings.isPasswordHistoryOn,
                  onPasswordHistoryChanged: (val) {
                    setState(() {
                      appSettings.isPasswordHistoryOn = val;
                      appSettings.save();
                    });
                  },
                  setThemeMode: setThemeMode,
                  themeMode: themeMode,
                ),
              ][currentIndex];
            }

            return MediaQuery.removePadding(
              context: context,
              removeBottom: false,
              child: Scaffold(
                extendBody: false,
                backgroundColor: navBarColor,
                body: [
                  VaultPage(
                    onTab: _onTab,
                    passwordHistory: passwordHistory.history,
                    hidePasswords: appSettings.hidePasswords,
                    copyToClipboard: passwordHistory.copyToClipboard,
                    deleteFromHistory: passwordHistory.delete,
                    symbolController: symbolController.controller,
                    clearHistory: passwordHistory.clear,
                    toggleHidePasswords: () {
                      setState(() {
                        appSettings.hidePasswords = !appSettings.hidePasswords;
                        appSettings.save();
                      });
                    },
                    themeMode: themeMode,
                    setThemeMode: setThemeMode,
                  ),
                  HomePage(
                    onTab: _onTab,
                    twelveCharsEnabled: appSettings.twelveCharsEnabled,
                    onTwelveCharsChanged: (val) {
                      setState(() {
                        appSettings.twelveCharsEnabled = val;
                        appSettings.save();
                      });
                    },
                    symbolController: symbolController.controller,
                    excludeAmbiguous: appSettings.excludeAmbiguous,
                    onExcludeAmbiguousChanged: (val) {
                      setState(() {
                        appSettings.excludeAmbiguous = val;
                        appSettings.save();
                      });
                    },
                    hideGeneratedPassword: appSettings.hideGeneratedPassword,
                    onHideGeneratedPasswordChanged: (val) {
                      setState(() {
                        appSettings.hideGeneratedPassword = val;
                        appSettings.save();
                      });
                    },
                    passwordHistory: passwordHistory.history,
                    hidePasswords: appSettings.hidePasswords,
                    copyToClipboard: passwordHistory.copyToClipboard,
                    deleteFromHistory: passwordHistory.delete,
                    clearHistory: passwordHistory.clear,
                    toggleHidePasswords: () {
                      setState(() {
                        appSettings.hidePasswords = !appSettings.hidePasswords;
                        appSettings.save();
                      });
                    },
                    addToHistory: passwordHistory.add,
                    noRepeats: appSettings.noRepeats,
                    onNoRepeatsChanged: (val) {
                      setState(() {
                        appSettings.noRepeats = val;
                        appSettings.save();
                      });
                    },
                    noSequences: appSettings.noSequences,
                    onNoSequencesChanged: (val) {
                      setState(() {
                        appSettings.noSequences = val;
                        appSettings.save();
                      });
                    },
                    isPasswordHistoryOn: appSettings.isPasswordHistoryOn,
                    themeMode: themeMode,
                    setThemeMode: setThemeMode,
                  ),
                  SettingsPage(
                    onTab: _onTab,
                    twelveCharsEnabled: appSettings.twelveCharsEnabled,
                    onTwelveCharsChanged: (val) {
                      setState(() {
                        appSettings.twelveCharsEnabled = val;
                        appSettings.save();
                      });
                    },
                    symbolController: symbolController.controller,
                    excludeAmbiguous: appSettings.excludeAmbiguous,
                    onExcludeAmbiguousChanged: (val) {
                      setState(() {
                        appSettings.excludeAmbiguous = val;
                        appSettings.save();
                      });
                    },
                    hideGeneratedPassword: appSettings.hideGeneratedPassword,
                    onHideGeneratedPasswordChanged: (val) {
                      setState(() {
                        appSettings.hideGeneratedPassword = val;
                        appSettings.save();
                      });
                    },
                    passwordHistory: passwordHistory.history,
                    hidePasswords: appSettings.hidePasswords,
                    copyToClipboard: passwordHistory.copyToClipboard,
                    deleteFromHistory: passwordHistory.delete,
                    clearHistory: passwordHistory.clear,
                    toggleHidePasswords: () {
                      setState(() {
                        appSettings.hidePasswords = !appSettings.hidePasswords;
                        appSettings.save();
                      });
                    },
                    noRepeats: appSettings.noRepeats,
                    onNoRepeatsChanged: (val) {
                      setState(() {
                        appSettings.noRepeats = val;
                        appSettings.save();
                      });
                    },
                    noSequences: appSettings.noSequences,
                    onNoSequencesChanged: (val) {
                      setState(() {
                        appSettings.noSequences = val;
                        appSettings.save();
                      });
                    },
                    isPasswordHistoryOn: appSettings.isPasswordHistoryOn,
                    onPasswordHistoryChanged: (val) {
                      setState(() {
                        appSettings.isPasswordHistoryOn = val;
                        appSettings.save();
                      });
                    },
                    setThemeMode: setThemeMode,
                    themeMode: themeMode,
                  ),
                ][currentIndex],
                bottomNavigationBar: Container(
                  color: navBarColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: SafeArea(
                    top: false,
                    child: GNav(
                      mainAxisAlignment: MainAxisAlignment.center,
                      gap: 8,
                      backgroundColor: navBarColor,
                      color: isDark ? Colors.grey[800] : Colors.grey,
                      activeColor: isDark ? Colors.grey : Colors.grey[800],
                      tabBackgroundColor: isDark
                          ? const Color.fromARGB(255, 40, 40, 40)
                          : const Color.fromARGB(255, 245, 245, 245),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      selectedIndex: currentIndex,
                      onTabChange: _onTab,
                      rippleColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      tabs: [
                        GButton(
                          icon: Icons.lock,
                          text: 'Vault',
                          textStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                          iconSize: 32,
                        ),
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                          textStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                          iconSize: 32,
                        ),
                        GButton(
                          icon: Icons.settings,
                          text: 'Settings',
                          textStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

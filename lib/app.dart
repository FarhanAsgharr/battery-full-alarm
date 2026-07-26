import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';

/// Router instance kept in a provider so it survives theme and locale changes
/// (rebuilding it would reset the navigation stack every time a setting changes).
final routerProvider = Provider<GoRouter>((ref) => createRouter());

class BatteryAlarmApp extends ConsumerWidget {
  const BatteryAlarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Battery Full Alarm',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      themeMode: settings.themeChoice.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: settings.language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

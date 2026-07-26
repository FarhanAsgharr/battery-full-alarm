import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/alarm/presentation/alarm_sound_screen.dart';
import '../../features/battery/presentation/home_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/voice/presentation/voice_screen.dart';
import '../../l10n/app_localizations.dart';

/// Route paths, referenced by name everywhere else so a rename is a one-line change.
class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const history = '/history';
  static const statistics = '/statistics';
  static const settings = '/settings';
  static const voice = '/settings/voice';
  static const sound = '/settings/sound';
  static const about = '/settings/about';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'voice',
                    builder: (context, state) => const VoiceScreen(),
                  ),
                  GoRoute(
                    path: 'sound',
                    builder: (context, state) => const AlarmSoundScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Bottom navigation wrapper. Each branch keeps its own navigation stack, so pushing
/// the voice screen from Settings and switching tabs does not lose the user's place.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.battery_charging_full_outlined),
            selectedIcon: const Icon(Icons.battery_charging_full),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:word_riders/features/ui/screens/game_screen.dart';

import 'features/ui/screens/campaign_progress_screen.dart';
import 'features/ui/screens/loading_start_screen.dart';
import 'features/ui/screens/menu_game_screen.dart';
import 'features/ui/screens/settings_screen.dart';
import 'features/ui/screens/main_scaffold.dart';
import 'features/ui/screens/store_screen.dart';
import 'features/ui/screens/trophies_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoadingStartScreen()),
    GoRoute(path: '/menu', builder: (context, state) => const MenuGameScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branche 0: Store
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/store',
              builder: (context, state) => const StoreScreen(),
            ),
          ],
        ),
        // Branch 1: Campaign
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/campaign',
              builder: (context, state) => const CampaignProgressScreen(),
            ),
          ],
        ),
        // Branch 2: Trophées
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trophies',
              builder: (context, state) => const TrophiesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isCampaign = extra?['isCampaign'] ?? false;
        return GameScreen(isCampaign: isCampaign);
      },
    ),
  ],
);

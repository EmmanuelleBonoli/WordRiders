import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/screens/game_screen.dart';

import 'features/ui/screens/campaign_progress_screen.dart';
import 'features/ui/screens/loading_start_screen.dart';
import 'features/ui/screens/menu_game_screen.dart';
import 'features/ui/screens/settings_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoadingStartScreen()),
    GoRoute(path: '/menu', builder: (context, state) => const MenuGameScreen()),
    GoRoute(
      path: '/campaign',
      builder: (context, state) => const CampaignProgressScreen(),
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

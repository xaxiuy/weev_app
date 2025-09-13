import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:weev_app/features/auth/login_screen.dart';
import 'package:weev_app/features/discover/discover_screen.dart';
import 'package:weev_app/features/activate/activate_screen.dart';
import 'package:weev_app/features/wallet/wallet_screen.dart';
import 'package:weev_app/features/profile/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/discover',
  routes: <RouteBase>[
    GoRoute(
      path: '/auth/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/discover',
      name: 'discover',
      builder: (BuildContext context, GoRouterState state) => const DiscoverScreen(),
    ),
    GoRoute(
      path: '/activate',
      name: 'activate',
      builder: (BuildContext context, GoRouterState state) => const ActivateScreen(),
    ),
    GoRoute(
      path: '/wallet',
      name: 'wallet',
      builder: (BuildContext context, GoRouterState state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
    ),
  ],
);

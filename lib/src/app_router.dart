import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/agenda/agenda_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/finance/finance_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/clients/client_detail_screen.dart';
import 'screens/clients/package_create_screen.dart';
import 'screens/sessions/session_edit_screen.dart';
import 'screens/sessions/session_start_screen.dart';
import 'screens/billing/paywall_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';

/// Listenable adapter para o `FirebaseAuth.authStateChanges()` reagir no router.
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    _sub = AuthService.instance.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _AuthStateNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authNotifier,
  redirect: (context, state) async {
    final loc = state.matchedLocation;
    final isAuthFlow = loc == '/login' || loc == '/splash';
    final user = AuthService.instance.currentUser;

    // Ainda carregando: deixa na splash.
    if (loc == '/splash') {
      if (user == null) return '/login';
      final data = await AuthService.instance.getCurrentUserData();
      if (data == null || !data.onboardingCompleted) return '/onboarding';
      return '/home';
    }

    // Sem usuário → força login.
    if (user == null && !isAuthFlow) return '/login';

    // Usuário logado tentando entrar em /login → vai pra home.
    if (user != null && loc == '/login') return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (_, _, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/agenda', builder: (_, _) => const AgendaScreen()),
        GoRoute(path: '/clients', builder: (_, _) => const ClientsScreen()),
        GoRoute(path: '/finance', builder: (_, _) => const FinanceScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/clients/:id',
      builder: (_, state) => ClientDetailScreen(clientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/clients/:id/package/new',
      builder: (_, state) => PackageCreateScreen(clientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/session/new',
      builder: (_, state) => const SessionEditScreen(),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (_, state) => SessionEditScreen(sessionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/session/:id/start',
      builder: (_, state) => SessionStartScreen(sessionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paywall',
      builder: (_, _) => const PaywallScreen(),
    ),
  ],
);

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
import 'screens/sessions/session_edit_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/agenda', builder: (_, __) => const AgendaScreen()),
        GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
        GoRoute(path: '/finance', builder: (_, __) => const FinanceScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/clients/:id',
      builder: (_, state) => ClientDetailScreen(clientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/session/new',
      builder: (_, state) => const SessionEditScreen(),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (_, state) => SessionEditScreen(sessionId: state.pathParameters['id']!),
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/agenda')) return 1;
    if (location.startsWith('/clients')) return 2;
    if (location.startsWith('/finance')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // home
  }

  void _onTap(int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/agenda'); break;
      case 2: context.go('/clients'); break;
      case 3: context.go('/finance'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.payments), label: 'Financeiro'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

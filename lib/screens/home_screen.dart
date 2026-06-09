import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    CustomersScreen(),
    ReportsScreen(),
  ];

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  void _toggleTheme() {
    final current = ref.read(themeModeProvider);
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(themeModeProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reporter',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: _toggleTheme,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _screens[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

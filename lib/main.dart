import 'package:flutter/material.dart';

void main() {
  runApp(const MoneyAtlasApp());
}

class MoneyAtlasApp extends StatelessWidget {
  const MoneyAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyAtlas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      routes: {
        '/converter': (context) => const ConverterScreen(),
        '/exchange': (context) => const ExchangeScreen(),
        '/encyclopedia': (context) => const EncyclopediaScreen(),
        '/atlas': (context) => const AtlasScreen(),
        '/vault': (context) => const VaultScreen(),
        '/gallery': (context) => const GalleryScreen(),
      },
    );
  }
}

/// Home screen with navigation to all feature modules.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      label: 'Converter',
      icon: Icons.currency_exchange,
      route: '/converter',
    ),
    _NavItem(label: 'Exchange', icon: Icons.trending_up, route: '/exchange'),
    _NavItem(
      label: 'Encyclopedia',
      icon: Icons.library_books,
      route: '/encyclopedia',
    ),
    _NavItem(label: 'Atlas', icon: Icons.public, route: '/atlas'),
    _NavItem(label: 'Vault', icon: Icons.star, route: '/vault'),
    _NavItem(label: 'Symbols', icon: Icons.image, route: '/gallery'),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushNamed(context, _navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyAtlas'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to MoneyAtlas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text('Your guide to world currencies'),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  _navItems.length,
                  (index) => _NavButton(
                    item: _navItems[index],
                    onTap: () => _onNavItemTapped(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  _NavItem({required this.label, required this.icon, required this.route});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(item.icon),
      label: Text(item.label),
    );
  }
}

// Placeholder screens for each feature module.
// These will be replaced with actual implementations from lib/converter/, lib/exchange/, etc.

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: const Center(child: Text('Converter Module')),
    );
  }
}

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exchange Rates')),
      body: const Center(child: Text('Exchange Module')),
    );
  }
}

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encyclopedia')),
      body: const Center(child: Text('Encyclopedia Module')),
    );
  }
}

class AtlasScreen extends StatelessWidget {
  const AtlasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atlas')),
      body: const Center(child: Text('Atlas Module')),
    );
  }
}

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: const Center(child: Text('Vault Module')),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symbols')),
      body: const Center(
        child: Text('Symbols Module — currency symbols only (no flags)'),
      ),
    );
  }
}

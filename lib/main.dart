import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exchange/providers.dart';
import 'core/services/currency_data_loader.dart';
import 'core/models/currency_info.dart';
import 'core/theme_provider.dart';
import 'core/theme_toggle_button.dart';
import 'core/utils/timestamp_formatter.dart';

void main() async {
  // Initialize SharedPreferences before running the app
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MoneyAtlasApp(),
    ),
  );
}

class MoneyAtlasApp extends ConsumerWidget {
  const MoneyAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
      themeMode: themeMode,
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
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
        actions: const [ThemeToggleButton()],
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
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(child: Text('Converter Module')),
    );
  }
}

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  String? _baseCurrency;
  bool _isLoading = false;
  Map<String, double>? _rates;
  String? _error;
  DateTime? _lastUpdate;
  List<CurrencyInfo> _allCurrencies = [];
  Map<String, CurrencyInfo> _currencyMap = {};

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final currencies = await CurrencyDataLoader.getAllCurrencies();
      final currencyMap = await CurrencyDataLoader.loadCurrencies();
      if (!mounted) return;
      setState(() {
        _allCurrencies = currencies;
        _currencyMap = currencyMap;
      });
      // Don't fetch rates automatically - wait for user to select currency
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load currencies: $e';
      });
    }
  }

  Future<void> _fetchRates() async {
    if (_baseCurrency == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(exchangeRateRepositoryProvider);
      final result = await repository.getAllRates(baseCurrency: _baseCurrency!);

      if (!mounted) return;
      setState(() {
        _rates = result.allRates;
        _lastUpdate = result.timestamp;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (_isLoading || _baseCurrency == null)
                ? null
                : _fetchRates,
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_allCurrencies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show currency selector and prompt when no currency selected
    if (_baseCurrency == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.currency_exchange, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Select a base currency to view exchange rates',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildCurrencySelector(),
            ],
          ),
        ),
      );
    }

    if (_isLoading && _rates == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _rates == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchRates, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_rates == null) {
      return const Center(child: Text('No data available'));
    }

    final baseCurrencyInfo = _currencyMap[_baseCurrency];

    return Column(
      children: [
        // Last updated info
        if (_lastUpdate != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              TimestampFormatter.formatLocal(_lastUpdate!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        // Currency selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCurrencySelector(),
        ),
        // Header showing exchange rates for selected currency
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Exchange Rates for $_baseCurrency${baseCurrencyInfo != null ? ' (${baseCurrencyInfo.name})' : ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // List of rates
        Expanded(
          child: ListView.builder(
            itemCount: _rates!.length,
            itemBuilder: (context, index) {
              final entry = _rates!.entries.elementAt(index);
              final targetCurrency = _currencyMap[entry.key];

              return ListTile(
                leading: CircleAvatar(child: Text(entry.key.substring(0, 2))),
                title: targetCurrency != null
                    ? Text(targetCurrency.displayName)
                    : Text(entry.key),
                trailing: Text(
                  targetCurrency != null
                      ? '${targetCurrency.symbol}${entry.value.toStringAsFixed(4)}'
                      : entry.value.toStringAsFixed(4),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '1 $_baseCurrency = ${entry.value.toStringAsFixed(4)} ${entry.key}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select base currency',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _baseCurrency,
          hint: const Text('Choose a currency'),
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _baseCurrency = newValue;
              });
              _fetchRates();
            }
          },
          items: _allCurrencies.map((CurrencyInfo currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Text(currency.displayName),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encyclopedia'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(child: Text('Encyclopedia Module')),
    );
  }
}

class AtlasScreen extends StatelessWidget {
  const AtlasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(child: Text('Atlas Module')),
    );
  }
}

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(child: Text('Vault Module')),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symbols'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(
        child: Text('Symbols Module — currency symbols only (no flags)'),
      ),
    );
  }
}

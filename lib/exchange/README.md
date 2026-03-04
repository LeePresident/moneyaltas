# Exchange Module

This module handles currency exchange rate fetching and caching.

## Features

- ✅ Real-time exchange rate fetching via [Frankfurter API](https://www.frankfurter.app/)
- ✅ Automatic caching with 12-hour TTL (Time To Live)
- ✅ Offline support with cached rates
- ✅ Support for 30+ currencies based on European Central Bank data
- ✅ No API key required
- ✅ Comprehensive error handling

## API Terms & Conditions

**Frankfurter API** (https://www.frankfurter.app/)
- **License**: MIT (open source)
- **Data Source**: European Central Bank (ECB)
- **Commercial Use**: ✅ Allowed
- **Rate Limits**: No explicit limits (reasonable use expected)
- **API Key**: Not required
- **Attribution**: Data provided by European Central Bank via Frankfurter API

## Usage

### Basic Example

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyatlas/exchange/providers.dart';

// In your widget
class MyCurrencyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(exchangeRateRepositoryProvider);
    
    // Fetch a rate
    return FutureBuilder(
      future: repository.getExchangeRate(from: 'USD', to: 'EUR'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rate = snapshot.data!;
          return Text('1 USD = ${rate.rate} EUR');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Get All Rates

```dart
final rates = await repository.getAllRates(baseCurrency: 'USD');
print('USD to EUR: ${rates.getRateFor('EUR')}');
print('USD to GBP: ${rates.getRateFor('GBP')}');
```

### Supported Currencies

```dart
final currencies = await repository.getSupportedCurrencies();
// Returns: ['AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', ...]
```

### Manual Refresh

```dart
// Force fetch from API (bypass cache)
final freshRate = await repository.refreshRate(from: 'USD', to: 'EUR');
```

### Cache Management

```dart
// Check if cached data exists
final hasCached = await repository.hasCachedRate(from: 'USD', to: 'EUR');

// Clear all cached rates
await repository.clearCache();
```

## Error Handling

The module provides specific exception types:

- `NetworkException` - Network connectivity issues
- `InvalidCurrencyException` - Invalid currency code
- `RateLimitException` - API rate limit exceeded
- `ParseException` - Response parsing error
- `CacheException` - Cache operation failure

Example:
```dart
try {
  final rate = await repository.getExchangeRate(from: 'USD', to: 'EUR');
} on InvalidCurrencyException catch (e) {
  print('Invalid currency: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ExchangeException catch (e) {
  print('General error: ${e.message}');
}
```

## Architecture

- **Models**: Data structures for rates, providers, exceptions
- **Repository**: Abstract interface for exchange operations
- **Cache**: SharedPreferences-based caching with TTL
- **Frankfurter Repository**: Concrete implementation using Frankfurter API
- **Providers**: Riverpod dependency injection setup

## Files

- `models/exchange_rate.dart` - Exchange rate data model
- `models/rate_provider.dart` - Provider configuration
- `models/exchange_exception.dart` - Exception types
- `exchange_rate_repository.dart` - Repository interface
- `exchange_rate_cache.dart` - Caching implementation
- `frankfurter_repository.dart` - Frankfurter API client
- `providers.dart` - Riverpod providers

## Configuration

Public provider configuration keys (example):

- `provider` — provider id (e.g., `frankfurter`)
- `ttl_hours` — cache TTL in hours (default: 12)
- `base_currency` — app default base currency (e.g., `USD`)

Example usage (Riverpod):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyatlas/exchange/providers.dart';

final repository = ref.watch(exchangeRateRepositoryProvider);
final rate = await repository.getExchangeRate(from: 'USD', to: 'EUR');
```

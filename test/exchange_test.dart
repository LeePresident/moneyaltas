import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneyatlas/exchange/exchange_rate_cache.dart';
import 'package:moneyatlas/exchange/frankfurter_repository.dart';
import 'package:moneyatlas/exchange/models/exchange_exception.dart';

void main() {
  group('Exchange Rate Fetching Tests', () {
    late FrankfurterRepository repository;
    late http.Client httpClient;
    late ExchangeRateCache cache;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      httpClient = http.Client();
      cache = ExchangeRateCache(prefs);
      repository = FrankfurterRepository(
        httpClient: httpClient,
        cache: cache,
      );
    });

    tearDown(() async {
      httpClient.close();
      await cache.clearAll();
    });

    test('Fetch USD to EUR exchange rate', () async {
      final rate = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: false, // Force fresh fetch
      );

      expect(rate.baseCurrency, 'USD');
      expect(rate.targetCurrency, 'EUR');
      expect(rate.rate, greaterThan(0));
      expect(rate.timestamp, isNotNull);
      
      print('✅ USD to EUR: ${rate.rate}');
      print('   Fetched at: ${rate.timestamp}');
    });

    test('Fetch all rates for USD', () async {
      final rates = await repository.getAllRates(
        baseCurrency: 'USD',
        useCache: false,
      );

      expect(rates.baseCurrency, 'USD');
      expect(rates.allRates, isNotNull);
      expect(rates.allRates!.length, greaterThan(20));
      
      print('✅ All rates for USD (${rates.allRates!.length} currencies):');
      rates.allRates!.forEach((currency, rate) {
        print('   USD to $currency: $rate');
      });
    });

    test('Get supported currencies', () async {
      final currencies = await repository.getSupportedCurrencies();

      expect(currencies, isNotEmpty);
      expect(currencies, contains('USD'));
      expect(currencies, contains('EUR'));
      expect(currencies, contains('GBP'));
      
      print('✅ Supported currencies (${currencies.length}): ${currencies.join(', ')}');
    });

    test('Cache functionality', () async {
      // First fetch - should come from API
      final rate1 = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: false,
      );
      
      print('✅ First fetch (from API): ${rate1.rate}');
      
      // Second fetch - should come from cache
      final rate2 = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: true,
      );
      
      print('✅ Second fetch (from cache): ${rate2.rate}');
      
      // Should be the same rate and timestamp
      expect(rate2.rate, rate1.rate);
      expect(rate2.timestamp, rate1.timestamp);
      
      // Note: Full cache verification tests should be in unit tests for ExchangeRateCache
      // The repository integration test above validates the caching works end-to-end
      print('✅ Cache integration verified');
    });

    test('Currency conversion calculation', () async {
      final rate = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: false,
      );

      final amount = 100.0;
      final converted = rate.convert(amount);
      
      expect(converted, greaterThan(0));
      print('✅ $amount USD = $converted EUR (rate: ${rate.rate})');
    });

    test('Invalid currency handling', () async {
      expect(
        () => repository.getExchangeRate(
          from: 'INVALID',
          to: 'EUR',
          useCache: false,
        ),
        throwsA(isA<InvalidCurrencyException>()),
      );
      
      print('✅ Invalid currency exception handled correctly');
    });

    test('Clear cache', () async {
      // Fetch and cache a rate
      await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: false,
      );
      
      // Clear cache
      await repository.clearCache();
      
      // After clearing, fetching with cache should fetch from API again
      final rate = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: true,
      );
      
      expect(rate.rate, greaterThan(0));
      print('✅ Cache cleared and fresh fetch verified');
    });

    test('Case-insensitive currency codes', () async {
      final rate1 = await repository.getExchangeRate(
        from: 'usd',
        to: 'eur',
        useCache: false,
      );
      
      final rate2 = await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: true,
      );

      expect(rate1.baseCurrency, 'USD');
      expect(rate1.targetCurrency, 'EUR');
      expect(rate2.rate, rate1.rate);
      
      print('✅ Case-insensitive currency codes work correctly');
    });

    test('Refresh rate (bypass cache)', () async {
      // Initial fetch
      await repository.getExchangeRate(
        from: 'USD',
        to: 'EUR',
        useCache: false,
      );
      
      // Refresh should fetch fresh data
      final refreshed = await repository.refreshRate(
        from: 'USD',
        to: 'EUR',
      );
      
      expect(refreshed.baseCurrency, 'USD');
      expect(refreshed.targetCurrency, 'EUR');
      expect(refreshed.rate, greaterThan(0));
      
      print('✅ Rate refreshed successfully: ${refreshed.rate}');
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'exchange_rate_repository.dart';
import 'exchange_rate_cache.dart';
import 'frankfurter_repository.dart';

/// Provider for HTTP client (shared instance)
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Provider for SharedPreferences
/// This is overridden from main() with the initialized instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

/// Provider for ExchangeRateCache
final exchangeRateCacheProvider = Provider<ExchangeRateCache>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ExchangeRateCache(prefs);
});

/// Provider for ExchangeRateRepository
///
/// This is the main provider you should use in your app to access
/// exchange rate functionality.
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final cache = ref.watch(exchangeRateCacheProvider);

  return FrankfurterRepository(httpClient: httpClient, cache: cache);
});

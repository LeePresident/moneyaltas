import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exchange_rate_repository.dart';
import 'exchange_rate_cache.dart';
import 'models/exchange_rate.dart';
import 'models/rate_provider.dart';
import 'models/exchange_exception.dart';

/// Implementation of ExchangeRateRepository using Frankfurter API
class FrankfurterRepository implements ExchangeRateRepository {
  final http.Client _httpClient;
  final ExchangeRateCache _cache;
  final RateProvider _provider = RateProvider.frankfurter;

  FrankfurterRepository({
    required http.Client httpClient,
    required ExchangeRateCache cache,
  })  : _httpClient = httpClient,
        _cache = cache;

  @override
  Future<ExchangeRate> getExchangeRate({
    required String from,
    required String to,
    bool useCache = true,
  }) async {
    // Normalize currency codes to uppercase
    final fromCurrency = from.toUpperCase();
    final toCurrency = to.toUpperCase();

    // Try cache first if enabled
    if (useCache) {
      final cachedRate = await _cache.getRate(
        from: fromCurrency,
        to: toCurrency,
      );
      if (cachedRate != null) {
        return cachedRate;
      }
    }

    // Fetch from API
    return await _fetchRate(from: fromCurrency, to: toCurrency);
  }

  @override
  Future<ExchangeRate> getAllRates({
    required String baseCurrency,
    bool useCache = true,
  }) async {
    final base = baseCurrency.toUpperCase();

    // Try cache first
    if (useCache) {
      final cachedRates = await _cache.getAllRates(baseCurrency: base);
      if (cachedRates != null) {
        return cachedRates;
      }
    }

    // Fetch all rates from API
    return await _fetchAllRates(baseCurrency: base);
  }

  @override
  Future<List<String>> getSupportedCurrencies() async {
    // Try cache first
    final cached = await _cache.getSupportedCurrencies();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Fetch from API
    try {
      final url = Uri.parse('${_provider.baseUrl}/currencies');
      final response = await _httpClient.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final currencies = json.keys.toList()..sort();
        
        // Cache the result
        await _cache.saveSupportedCurrencies(currencies);
        
        return currencies;
      } else {
        throw NetworkException(
          'Failed to fetch currencies: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ExchangeException) rethrow;
      throw NetworkException('Failed to fetch supported currencies', e);
    }
  }

  @override
  Future<ExchangeRate> refreshRate({
    required String from,
    required String to,
  }) async {
    return await getExchangeRate(
      from: from,
      to: to,
      useCache: false,
    );
  }

  @override
  Future<void> clearCache() async {
    await _cache.clearAll();
  }

  @override
  Future<bool> hasCachedRate({
    required String from,
    required String to,
  }) async {
    return await _cache.hasRate(
      from: from.toUpperCase(),
      to: to.toUpperCase(),
    );
  }

  /// Internal method to fetch a specific rate from the API
  Future<ExchangeRate> _fetchRate({
    required String from,
    required String to,
  }) async {
    try {
      // Frankfurter API endpoint: /latest?from=USD&to=EUR
      final url = Uri.parse(
        '${_provider.baseUrl}/latest?from=$from&to=$to',
      );

      final response = await _httpClient.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rate = ExchangeRate.fromJson(json, targetCurrency: to);
        
        // Cache the result
        await _cache.saveRate(rate);
        
        return rate;
      } else if (response.statusCode == 404) {
        throw InvalidCurrencyException(
          'Invalid currency code: $from or $to',
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Rate limit exceeded');
      } else {
        throw NetworkException(
          'Failed to fetch exchange rate: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ExchangeException) rethrow;
      throw NetworkException('Network error while fetching rate', e);
    }
  }

  /// Internal method to fetch all rates for a base currency
  Future<ExchangeRate> _fetchAllRates({
    required String baseCurrency,
  }) async {
    try {
      // Frankfurter API endpoint: /latest?from=USD
      final url = Uri.parse('${_provider.baseUrl}/latest?from=$baseCurrency');

      final response = await _httpClient.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rate = ExchangeRate.fromJson(json);
        
        // Cache the result
        await _cache.saveRate(rate);
        
        return rate;
      } else if (response.statusCode == 404) {
        throw InvalidCurrencyException(
          'Invalid currency code: $baseCurrency',
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Rate limit exceeded');
      } else {
        throw NetworkException(
          'Failed to fetch exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ExchangeException) rethrow;
      throw NetworkException('Network error while fetching rates', e);
    }
  }
}

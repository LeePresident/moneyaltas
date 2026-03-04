import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/exchange_rate.dart';
import 'models/exchange_exception.dart';

/// Cache manager for exchange rates using SharedPreferences
class ExchangeRateCache {
  static const String _cachePrefix = 'exchange_rate_';
  static const String _allRatesPrefix = 'all_rates_';
  static const String _supportedCurrenciesKey = 'supported_currencies';
  
  final SharedPreferences _prefs;

  ExchangeRateCache(this._prefs);

  /// Get cached exchange rate for a currency pair
  Future<ExchangeRate?> getRate({
    required String from,
    required String to,
  }) async {
    try {
      final key = _getCacheKey(from, to);
      final cached = _prefs.getString(key);
      
      if (cached == null) return null;
      
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final rate = ExchangeRate.fromCache(json);
      
      // Return null if expired (12 hour TTL)
      if (rate.isExpired()) {
        await _prefs.remove(key);
        return null;
      }
      
      return rate;
    } catch (e) {
      throw CacheException('Failed to retrieve cached rate', e);
    }
  }

  /// Get all rates for a base currency
  Future<ExchangeRate?> getAllRates({required String baseCurrency}) async {
    try {
      final key = '$_allRatesPrefix$baseCurrency';
      final cached = _prefs.getString(key);
      
      if (cached == null) return null;
      
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final rate = ExchangeRate.fromCache(json);
      
      // Return null if expired
      if (rate.isExpired()) {
        await _prefs.remove(key);
        return null;
      }
      
      return rate;
    } catch (e) {
      throw CacheException('Failed to retrieve all cached rates', e);
    }
  }

  /// Save an exchange rate to cache
  Future<void> saveRate(ExchangeRate rate) async {
    try {
      final key = _getCacheKey(rate.baseCurrency, rate.targetCurrency);
      final json = jsonEncode(rate.toJson());
      await _prefs.setString(key, json);
      
      // Also save to all rates cache if available
      if (rate.allRates != null) {
        final allRatesKey = '$_allRatesPrefix${rate.baseCurrency}';
        await _prefs.setString(allRatesKey, json);
        
        // Cache individual pairs from allRates for faster lookup
        for (final entry in rate.allRates!.entries) {
          final pairKey = _getCacheKey(rate.baseCurrency, entry.key);
          final pairRate = ExchangeRate(
            baseCurrency: rate.baseCurrency,
            targetCurrency: entry.key,
            rate: entry.value,
            timestamp: rate.timestamp,
            allRates: rate.allRates,
          );
          final pairJson = jsonEncode(pairRate.toJson());
          await _prefs.setString(pairKey, pairJson);
        }
      }
    } catch (e) {
      throw CacheException('Failed to save rate to cache', e);
    }
  }

  /// Get supported currencies from cache
  Future<List<String>?> getSupportedCurrencies() async {
    try {
      final cached = _prefs.getString(_supportedCurrenciesKey);
      if (cached == null) return null;
      
      final list = jsonDecode(cached) as List;
      return list.cast<String>();
    } catch (e) {
      throw CacheException('Failed to retrieve supported currencies', e);
    }
  }

  /// Save supported currencies to cache
  Future<void> saveSupportedCurrencies(List<String> currencies) async {
    try {
      final json = jsonEncode(currencies);
      await _prefs.setString(_supportedCurrenciesKey, json);
    } catch (e) {
      throw CacheException('Failed to save supported currencies', e);
    }
  }

  /// Clear all cached rates
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys().where(
        (key) => key.startsWith(_cachePrefix) || 
                 key.startsWith(_allRatesPrefix) ||
                 key == _supportedCurrenciesKey,
      );
      
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear cache', e);
    }
  }

  /// Check if a rate exists in cache (and is not expired)
  Future<bool> hasRate({required String from, required String to}) async {
    final rate = await getRate(from: from, to: to);
    return rate != null;
  }

  /// Generate cache key for a currency pair
  String _getCacheKey(String from, String to) {
    return '$_cachePrefix${from}_$to';
  }
}

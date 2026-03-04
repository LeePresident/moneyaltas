import 'models/exchange_rate.dart';

/// Abstract repository interface for fetching exchange rates
abstract class ExchangeRateRepository {
  /// Fetch the latest exchange rate between two currencies
  /// 
  /// [from] - Base currency code (e.g., 'USD')
  /// [to] - Target currency code (e.g., 'EUR')
  /// [useCache] - Whether to use cached data if available and not expired
  /// 
  /// Throws [ExchangeException] if the operation fails
  Future<ExchangeRate> getExchangeRate({
    required String from,
    required String to,
    bool useCache = true,
  });

  /// Fetch all exchange rates for a base currency
  /// 
  /// [baseCurrency] - Base currency code (e.g., 'USD')
  /// [useCache] - Whether to use cached data if available and not expired
  /// 
  /// Returns an ExchangeRate object with allRates populated
  Future<ExchangeRate> getAllRates({
    required String baseCurrency,
    bool useCache = true,
  });

  /// Get list of supported currencies
  /// 
  /// Returns a list of currency codes that can be used for conversion
  Future<List<String>> getSupportedCurrencies();

  /// Force refresh the exchange rates (bypass cache)
  Future<ExchangeRate> refreshRate({
    required String from,
    required String to,
  });

  /// Clear all cached exchange rates
  Future<void> clearCache();

  /// Check if cached data is available for a currency pair
  Future<bool> hasCachedRate({
    required String from,
    required String to,
  });
}

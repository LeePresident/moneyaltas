/// Supported exchange rate providers
enum RateProvider {
  /// Frankfurter API - Free, open source, ECB data
  /// https://www.frankfurter.app/
  /// No API key required, no rate limits
  frankfurter,

  // Future providers can be added here:
  // exchangeRateApi,
  // openExchangeRates,
  // etc.
}

extension RateProviderExtension on RateProvider {
  /// Get the base URL for the provider
  String get baseUrl {
    switch (this) {
      case RateProvider.frankfurter:
        return 'https://api.frankfurter.app';
    }
  }

  /// Get the display name for the provider
  String get displayName {
    switch (this) {
      case RateProvider.frankfurter:
        return 'Frankfurter (ECB)';
    }
  }

  /// Whether this provider requires an API key
  bool get requiresApiKey {
    switch (this) {
      case RateProvider.frankfurter:
        return false;
    }
  }

  /// Get attribution/credit text for the provider
  String get attribution {
    switch (this) {
      case RateProvider.frankfurter:
        return 'Data provided by Frankfurter API (European Central Bank)';
    }
  }
}

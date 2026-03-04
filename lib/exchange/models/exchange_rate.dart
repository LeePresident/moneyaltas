/// Represents a set of exchange rates at a specific point in time.
class ExchangeRate {
  /// Base currency code (e.g., 'EUR', 'USD')
  final String baseCurrency;

  /// Target currency code
  final String targetCurrency;

  /// Exchange rate from base to target
  final double rate;

  /// Timestamp when the rate was fetched/updated
  final DateTime timestamp;

  /// Map of all available rates from base currency
  /// Key: currency code, Value: exchange rate
  final Map<String, double>? allRates;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.timestamp,
    this.allRates,
  });

  /// Creates an ExchangeRate from JSON response
  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    String? targetCurrency,
  }) {
    final base = json['base'] as String;
    final ratesMap = (json['rates'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    // Parse date from the API response
    // The API returns dates like "2026-03-03" which represent midnight UTC
    final dateStr = json['date'] as String;
    // Parse as UTC by appending 'T00:00:00Z' to create a full ISO8601 UTC datetime
    final timestamp = DateTime.parse(dateStr + 'T00:00:00Z');

    // If target currency specified, use that rate; otherwise use first available
    final target = targetCurrency ?? ratesMap.keys.first;
    final rate = ratesMap[target] ?? 1.0;

    return ExchangeRate(
      baseCurrency: base,
      targetCurrency: target,
      rate: rate,
      timestamp: timestamp,
      allRates: ratesMap,
    );
  }

  /// Converts this to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'base': baseCurrency,
      'target': targetCurrency,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
      'allRates': allRates,
    };
  }

  /// Creates an ExchangeRate from cached JSON
  factory ExchangeRate.fromCache(Map<String, dynamic> json) {
    return ExchangeRate(
      baseCurrency: json['base'] as String,
      targetCurrency: json['target'] as String,
      rate: (json['rate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      allRates: (json['allRates'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  /// Check if this rate is expired based on TTL (Time To Live)
  bool isExpired({Duration ttl = const Duration(hours: 12)}) {
    return DateTime.now().difference(timestamp) > ttl;
  }

  /// Convert an amount using this exchange rate
  double convert(double amount) {
    return amount * rate;
  }

  /// Get rate for a specific currency from allRates
  double? getRateFor(String currencyCode) {
    return allRates?[currencyCode];
  }

  @override
  String toString() {
    return 'ExchangeRate(${baseCurrency}->${targetCurrency}: $rate at $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExchangeRate &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.rate == rate &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return baseCurrency.hashCode ^
        targetCurrency.hashCode ^
        rate.hashCode ^
        timestamp.hashCode;
  }
}

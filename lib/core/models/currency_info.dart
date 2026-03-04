/// Represents complete information about a currency
class CurrencyInfo {
  /// ISO 4217 currency code (e.g., 'USD', 'EUR')
  final String code;

  /// Full currency name (e.g., 'US Dollar', 'Euro')
  final String name;

  /// Currency symbol (e.g., '$', '€')
  final String symbol;

  /// Region where the currency is used
  final String region;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.region,
  });

  /// Creates CurrencyInfo from JSON
  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    return CurrencyInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      region: json['region'] as String,
    );
  }

  /// Display name like "USD (US Dollar)"
  String get displayName => '$code ($name)';

  /// Display name with symbol like "USD - US Dollar - $"
  String get fullDisplayName => '$code - $name - $symbol';

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrencyInfo && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/currency_info.dart';

/// Service for loading and managing currency information
class CurrencyDataLoader {
  static const String _assetPath = 'assets/currencies.json';
  static Map<String, CurrencyInfo>? _cachedData;

  /// Load all currencies from the asset file
  static Future<Map<String, CurrencyInfo>> loadCurrencies() async {
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      // Load the JSON asset
      final jsonString = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Parse into CurrencyInfo objects
      _cachedData = json.map(
        (key, value) => MapEntry(
          key,
          CurrencyInfo.fromJson(value as Map<String, dynamic>),
        ),
      );

      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load currencies: $e');
    }
  }

  /// Get info for a specific currency code
  static Future<CurrencyInfo?> getCurrencyInfo(String code) async {
    final currencies = await loadCurrencies();
    return currencies[code.toUpperCase()];
  }

  /// Get list of all currency codes sorted alphabetically
  static Future<List<String>> getCurrencyCodes() async {
    final currencies = await loadCurrencies();
    return currencies.keys.toList()..sort();
  }

  /// Get list of all CurrencyInfo objects
  static Future<List<CurrencyInfo>> getAllCurrencies() async {
    final currencies = await loadCurrencies();
    return currencies.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }

  /// Clear cached data (useful for testing)
  static void clearCache() {
    _cachedData = null;
  }
}

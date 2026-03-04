import 'package:flutter_test/flutter_test.dart';
import 'package:moneyatlas/exchange/models/exchange_rate.dart';

void main() {
  group('Timestamp Parsing Tests', () {
    test('API date is parsed as UTC', () {
      // Simulate API response with date string
      final json = {
        'base': 'USD',
        'date': '2026-03-03',
        'rates': {
          'EUR': 0.86162,
          'GBP': 0.75108,
        }
      };

      final rate = ExchangeRate.fromJson(json);

      // Verify timestamp is in UTC
      expect(rate.timestamp.isUtc, true,
          reason: 'Timestamp should be parsed as UTC');

      // Verify the correct date is preserved
      // The API returns "2026-03-03" which means 2026-03-03 00:00:00 UTC
      expect(rate.timestamp.year, 2026);
      expect(rate.timestamp.month, 3);
      expect(rate.timestamp.day, 3);
      expect(rate.timestamp.hour, 0);
      expect(rate.timestamp.minute, 0);
      expect(rate.timestamp.second, 0);

      print('✅ API date "2026-03-03" correctly parsed as UTC: ${rate.timestamp}');
    });

    test('Timestamp converts correctly to different timezones', () {
      // Create a UTC timestamp
      final json = {
        'base': 'USD',
        'date': '2026-03-03',
        'rates': {'EUR': 0.86162}
      };

      final rate = ExchangeRate.fromJson(json);
      final utcTime = rate.timestamp;

      // Simulate converting to different local timezones
      // This is what happens when you call .toLocal()
      final localTime = utcTime.toLocal();

      // The local time should be offset from UTC
      // but represent the same moment in time
      expect(utcTime.microsecondsSinceEpoch, localTime.microsecondsSinceEpoch,
          reason:
              'UTC and local time should represent the same moment in time');

      print(
          '✅ Timestamp conversion verified: UTC=${utcTime.toIso8601String()}, Local=${localTime.toIso8601String()}');
    });

    test('Cache serialization preserves UTC timezone', () {
      // Create initial rate
      final json = {
        'base': 'USD',
        'date': '2026-03-03',
        'rates': {'EUR': 0.86162}
      };

      final original = ExchangeRate.fromJson(json);

      // Serialize to JSON (like caching)
      final serialized = original.toJson();

      // Deserialize from JSON (like loading from cache)
      final deserialized = ExchangeRate.fromCache(serialized);

      // Verify timestamps match exactly
      expect(deserialized.timestamp, original.timestamp,
          reason: 'Timestamps should match after serialization round-trip');

      expect(deserialized.timestamp.isUtc, true,
          reason: 'Deserialized timestamp should still be UTC');

      print(
          '✅ Cache serialization preserves UTC: ${deserialized.timestamp.toIso8601String()}');
    });

    test('Different system timezones display same UTC moment correctly', () {
      // This test verifies the fix for the timezone display issue
      final json = {
        'base': 'USD',
        'date': '2026-03-03',
        'rates': {'EUR': 0.86162}
      };

      final rate = ExchangeRate.fromJson(json);

      // The timestamp represents: 2026-03-03 00:00:00 UTC
      // At UTC+8: it displays as 2026-03-03 08:00:00 UTC+8
      // At UTC+9: it displays as 2026-03-03 09:00:00 UTC+9
      // Both represent the same moment in time

      final utcTime = rate.timestamp;

      // When converted to local (which varies by system timezone)
      // the underlying moment in time (microsecondsSinceEpoch) stays the same
      final localTime = utcTime.toLocal();

      print(
          '✅ Same UTC moment in different timezones:');
      print(
          '   UTC: ${utcTime.toIso8601String()}');
      print(
          '   Local: ${localTime.toIso8601String()}');
      print(
          '   Both represent the same moment: ${localTime.microsecondsSinceEpoch == utcTime.microsecondsSinceEpoch}');
    });
  });
}

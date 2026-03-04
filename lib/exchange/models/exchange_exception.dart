/// Base exception for exchange rate operations
class ExchangeException implements Exception {
  final String message;
  final dynamic originalError;

  const ExchangeException(this.message, [this.originalError]);

  @override
  String toString() => 'ExchangeException: $message';
}

/// Exception for network-related errors
class NetworkException extends ExchangeException {
  const NetworkException(super.message, [super.originalError]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for API response parsing errors
class ParseException extends ExchangeException {
  const ParseException(super.message, [super.originalError]);

  @override
  String toString() => 'ParseException: $message';
}

/// Exception for rate limit errors
class RateLimitException extends ExchangeException {
  const RateLimitException(super.message, [super.originalError]);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Exception for invalid currency codes
class InvalidCurrencyException extends ExchangeException {
  const InvalidCurrencyException(super.message, [super.originalError]);

  @override
  String toString() => 'InvalidCurrencyException: $message';
}

/// Exception for cache-related errors
class CacheException extends ExchangeException {
  const CacheException(super.message, [super.originalError]);

  @override
  String toString() => 'CacheException: $message';
}

import 'package:intl/intl.dart';

/// Utility class for formatting timestamps
class TimestampFormatter {
  /// Format timestamp as local time with timezone offset
  /// Example: "2026-03-03 08:00:00 UTC+8" (for UTC+8 system)
  static String formatLocal(DateTime dateTime) {
    // Convert UTC time to local time
    final localTime = dateTime.toLocal();
    
    // Format the date and time
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedTime = formatter.format(localTime);
    
    // Get timezone offset
    final offset = localTime.timeZoneOffset;
    final offsetHours = offset.inHours;
    final offsetMinutes = offset.inMinutes.remainder(60).abs();
    
    // Format timezone offset (e.g., "UTC+8", "UTC-5", "UTC+0")
    final sign = offsetHours >= 0 ? '+' : '';
    final tzOffset = offsetMinutes > 0 
        ? 'UTC$sign$offsetHours:${offsetMinutes.toString().padLeft(2, '0')}'
        : 'UTC$sign$offsetHours';
    
    return '$formattedTime $tzOffset';
  }

  /// Format timestamp as UTC (for reference)
  /// Example: "2026-03-03 00:00:00 UTC"
  static String formatUtc(DateTime dateTime) {
    // Format in UTC
    final utcTime = dateTime.toUtc();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return '${formatter.format(utcTime)} UTC';
  }

  /// Format timestamp as relative time
  /// Example: "2 hours ago", "just now", "in 3 days"
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatLocal(dateTime);
    }
  }

  /// Format timestamp as "Last updated: [time] ([relative time ago])"
  static String formatLastUpdated(DateTime dateTime) {
    return 'Last updated: ${formatLocal(dateTime)} (${formatRelative(dateTime)})';
  }
}

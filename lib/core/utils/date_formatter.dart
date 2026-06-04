import 'package:intl/intl.dart';

class DateFormatter {
  static String formatLastSeen(String isoString) {
    if (isoString.isEmpty) return 'Unknown';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      
      // Calculate true calendar difference instead of strict 24-hour hour differences
      final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final todayOnly = DateTime(now.year, now.month, now.day);
      final dayDiff = todayOnly.difference(dateOnly).inDays;

      // Keep the actual absolute difference for minute-level accuracy today
      final actualDiff = now.difference(dateTime);

      // Nicely format the time: e.g. "14:30"
      final timeString = DateFormat.Hm().format(dateTime);

      if (dayDiff == 0) {
        if (actualDiff.inHours == 0) {
          if (actualDiff.inMinutes <= 1) return 'Just now';
          return '${actualDiff.inMinutes} mins ago';
        }
        return 'Today at $timeString';
      } else if (dayDiff == 1) {
        return 'Yesterday at $timeString';
      } else {
        return '$dayDiff days ago at $timeString';
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }
}

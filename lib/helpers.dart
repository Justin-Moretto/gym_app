import 'package:intl/intl.dart';

class Helpers {
  /// Converts ISO 8601 timestamp string to a readable format
  /// Example: "2025-03-02T19:15:30.123Z" -> "Mar 2, 2025 – 7:15 PM"
  static String formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'Unknown date';
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final formatter = DateFormat('MMM d, yyyy – h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Converts ISO 8601 timestamp string to a shorter format
  /// Example: "2025-03-02T19:15:30.123Z" -> "Mar 2, 7:15 PM"
  static String formatTimestampShort(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'Unknown date';
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final formatter = DateFormat('MMM d, h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Converts ISO 8601 timestamp string to date only
  /// Example: "2025-03-02T19:15:30.123Z" -> "Mar 2, 2025"
  static String formatDateOnly(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'Unknown date';
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Converts ISO 8601 timestamp string to time only
  /// Example: "2025-03-02T19:15:30.123Z" -> "7:15 PM"
  static String formatTimeOnly(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'Unknown time';
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final formatter = DateFormat('h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid time';
    }
  }

  /// Formats weight with proper units
  /// Example: 150 -> "150 lbs"
  static String formatWeight(dynamic weight) {
    final w = weight;// int.tryParse(weight.toString());
    return w != null ? "$w lbs" : "- lbs";
  }

  /// Formats sets and reps in a readable format
  /// Example: (3, 10) -> "3 sets × 10 reps"
  static String formatSetsAndReps(int? sets, int? reps) {
    final setsValue = sets ?? 0;
    final repsValue = reps ?? 0;
    return '$setsValue sets × $repsValue reps';
  }

  /// Formats reps in a readable format
  /// Example: 10 -> "10 reps"
  static String formatReps(dynamic reps) {
    if (reps == null) return '-';
    final r = reps; //int.tryParse(reps.toString());
    if (r == null) return '-';
    return r == 1 ? '1 rep' : '$r reps';
  }

  /// Validates if a string is a valid email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Capitalizes the first letter of each word
  /// Example: "bench press" -> "Bench Press"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats a DateTime object to date only
  /// Example: DateTime(2025, 3, 2) -> "Mar 2, 2025"
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }
} 
import 'package:flutter/material.dart';

class AppTextStyles {
  // App Title Styles
  static const TextStyle appTitle = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle appSubtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  // Button Styles
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle mainPageButton = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
  );

  // Card and List Styles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle listItem = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle listItemSelected = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Input Field Styles
  static const TextStyle inputField = TextStyle(
    fontSize: 18,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 18,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 18,
  );

  // Date and Time Styles
  static const TextStyle dateHeader = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dateSelector = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  // Helper method to apply theme colors
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle style, Color color, double opacity) {
    return style.copyWith(color: color.withOpacity(opacity));
  }
} 
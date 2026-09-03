import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

class TierUiUtils {
  TierUiUtils._();

  static Color tierForeground(String? name) {
    final slug = (name ?? '').toLowerCase();
    if (slug.contains('bronze')) return const Color(0xFFB87333);
    if (slug.contains('silver') || slug.contains('argent')) {
      return const Color(0xFF8796AB);
    }
    if (slug.contains('gold') || slug.contains('or')) {
      return const Color(0xFFC99006);
    }
    if (slug.contains('platinum') || slug.contains('platine')) {
      return AppColors.primary;
    }
    return AppColors.primary;
  }

  static Color tierBackground(String? name) {
    return tierForeground(name).withValues(alpha: 0.16);
  }

  static String formatEuro(double amount) {
    return '€${amount.toStringAsFixed(2)}';
  }

  static double _logScale(double value) => math.log(value + 1) / math.ln10;

  static double barHeightPercent(double value, double peak) {
    if (value <= 0 || peak <= 0) return 0;
    return math.max(10, (_logScale(value) / _logScale(peak)) * 100);
  }

  static String? nextTierBenefitsText(String? benefits) {
    if (benefits == null || benefits.trim().isEmpty) return null;
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*%').firstMatch(benefits);
    if (match != null) {
      return '${match.group(1)}% cashback';
    }
    return benefits;
  }
}

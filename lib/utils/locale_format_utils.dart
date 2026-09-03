import '../res/app_localization.dart';

class LocaleFormatUtils {
  static const _abbrevKeys = [
    'monthJan',
    'monthFeb',
    'monthMar',
    'monthApr',
    'monthMay',
    'monthJun',
    'monthJul',
    'monthAug',
    'monthSep',
    'monthOct',
    'monthNov',
    'monthDec',
  ];

  static const _fullKeys = [
    'monthJanuary',
    'monthFebruary',
    'monthMarch',
    'monthApril',
    'monthMayFull',
    'monthJune',
    'monthJuly',
    'monthAugust',
    'monthSeptember',
    'monthOctober',
    'monthNovember',
    'monthDecember',
  ];

  static const _abbrevFallbacks = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _fullFallbacks = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static List<String> monthAbbreviations(AppLocalizations l10n) {
    return List.generate(
      12,
      (index) => l10n.translate(_abbrevKeys[index]) ?? _abbrevFallbacks[index],
    );
  }

  static String monthFullName(AppLocalizations l10n, int month) {
    if (month < 1 || month > 12) return '';
    return l10n.translate(_fullKeys[month - 1]) ?? _fullFallbacks[month - 1];
  }

  static String allMonthsLabel(AppLocalizations l10n) {
    return l10n.translate('allMonths') ?? 'All months';
  }
}

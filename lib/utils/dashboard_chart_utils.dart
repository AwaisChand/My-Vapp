import '../models/dashboard_model/dashboard_model.dart';

class DashboardChartUtils {
  static const monthLabelsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static List<String> monthLabelsFor(String languageCode) {
    if (languageCode == 'fr') {
      return const [
        'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
      ];
    }
    return monthLabelsEn;
  }

  static const monthLabels = monthLabelsEn;

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static FilteredChartData buildOrdersChart({
    required List<OrderRawRow> rows,
    required int year,
    required int month,
    List<String>? monthLabels,
  }) {
    final labels = monthLabels ?? monthLabelsEn;
    if (month == 0) {
      final sales = List<double>.filled(12, 0);
      for (final row in rows) {
        final date = _parseDate(row.date);
        if (date == null || date.year != year) continue;
        sales[date.month - 1] += row.totalAmount;
      }
      return FilteredChartData(
        categories: List<String>.from(labels),
        values: sales.map((v) => double.parse(v.toStringAsFixed(2))).toList(),
      );
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final sales = List<double>.filled(daysInMonth, 0);
    final dayLabels = List.generate(daysInMonth, (i) => '${i + 1}');

    for (final row in rows) {
      final date = _parseDate(row.date);
      if (date == null || date.year != year || date.month != month) continue;
      sales[date.day - 1] += row.totalAmount;
    }

    return FilteredChartData(
      categories: dayLabels,
      values: sales.map((v) => double.parse(v.toStringAsFixed(2))).toList(),
    );
  }

  static FilteredChartData buildPassportChart({
    required List<PassportEntryRow> entries,
    required List<PassportRawRow> raw,
    required int year,
    required int month,
    List<String>? monthLabels,
  }) {
    final labels = monthLabels ?? monthLabelsEn;
    if (month == 0) {
      final sums = List<double>.filled(12, 0);
      final counts = List<int>.filled(12, 0);

      for (final row in entries) {
        final date = _parseDate(row.date);
        if (date == null || date.year != year) continue;
        final idx = date.month - 1;
        sums[idx] += row.mg;
        counts[idx] += 1;
      }

      final values = List<double>.generate(12, (idx) {
        if (counts[idx] == 0) return 0;
        return double.parse((sums[idx] / counts[idx]).toStringAsFixed(2));
      });

      return FilteredChartData(
        categories: List<String>.from(labels),
        values: values,
      );
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final mg = List<double>.filled(daysInMonth, 0);
    final dayLabels = List.generate(daysInMonth, (i) => '${i + 1}');

    for (final row in raw) {
      final date = _parseDate(row.date);
      if (date == null || date.year != year || date.month != month) continue;
      mg[date.day - 1] += row.mg;
    }

    return FilteredChartData(
      categories: dayLabels,
      values: mg.map((v) => double.parse(v.toStringAsFixed(2))).toList(),
    );
  }

  static List<int> yearsWithFallback(List<int> years) {
    if (years.isNotEmpty) return years;
    return [DateTime.now().year];
  }
}

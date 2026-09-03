import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../portal_ui.dart';

class DashboardLineChart extends StatelessWidget {
  final List<String> categories;
  final List<double> values;
  final String emptyMessage;
  final String? emptyExtra;
  final Color lineColor;
  final String valueSuffix;
  final String? tooltipValueLabel;
  final String? tooltipDateLabel;
  final String? tooltipTimeLabel;
  final String? tooltipAverageLabel;
  final bool showMonthlyAverage;
  final bool asLineChart;
  final String? yAxisTitle;

  const DashboardLineChart({
    super.key,
    required this.categories,
    required this.values,
    required this.emptyMessage,
    this.emptyExtra,
    this.lineColor = AppColors.primary,
    this.valueSuffix = '',
    this.tooltipValueLabel,
    this.tooltipDateLabel,
    this.tooltipTimeLabel,
    this.tooltipAverageLabel,
    this.showMonthlyAverage = false,
    this.asLineChart = false,
    this.yAxisTitle,
  });

  bool get _hasData => values.any((v) => v > 0);

  String _tooltip(int index, double value, String label) {
    final lines = <String>[];
    if (showMonthlyAverage && (tooltipAverageLabel ?? '').isNotEmpty) {
      lines.add('$tooltipAverageLabel: ${value.toStringAsFixed(2)}$valueSuffix');
    }
    if ((tooltipDateLabel ?? '').isNotEmpty) {
      lines.add('$tooltipDateLabel: $label');
    }
    if ((tooltipTimeLabel ?? '').isNotEmpty) {
      lines.add('$tooltipTimeLabel: —');
    }
    if ((tooltipValueLabel ?? '').isNotEmpty) {
      lines.add('$tooltipValueLabel: ${value.toStringAsFixed(2)}$valueSuffix');
    }
    return lines.isEmpty ? '${value.toStringAsFixed(2)}$valueSuffix' : lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) {
      return _emptyState();
    }

    if (asLineChart) {
      return _LineChartView(
        categories: categories,
        values: values,
        lineColor: lineColor,
        valueSuffix: valueSuffix,
        yAxisTitle: yAxisTitle ?? tooltipValueLabel ?? 'Sales',
        tooltipBuilder: _tooltip,
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final chartMax = maxValue <= 0 ? 1.0 : maxValue * 1.15;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final heightFactor = (value / chartMax).clamp(0.0, 1.0);
          final label = index < categories.length ? categories[index] : '';

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Tooltip(
                message: _tooltip(index, value, label),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (value > 0)
                      Text(
                        '${value.toStringAsFixed(value >= 100 ? 0 : 1)}$valueSuffix',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: heightFactor < 0.04 && value > 0 ? 0.04 : heightFactor,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  lineColor,
                                  lineColor.withValues(alpha: 0.55),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((emptyExtra ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              emptyExtra!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineChartView extends StatelessWidget {
  final List<String> categories;
  final List<double> values;
  final Color lineColor;
  final String valueSuffix;
  final String yAxisTitle;
  final String Function(int index, double value, String label) tooltipBuilder;

  const _LineChartView({
    required this.categories,
    required this.values,
    required this.lineColor,
    required this.valueSuffix,
    required this.yAxisTitle,
    required this.tooltipBuilder,
  });

  List<double> _ticks(double maxValue) {
    final niceMax = maxValue <= 50
        ? (maxValue <= 10 ? 10.0 : 50.0)
        : (maxValue / 50).ceil() * 50.0;
    const steps = 10;
    final step = niceMax / steps;
    return List.generate(steps + 1, (i) => (step * (steps - i)));
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final ticks = _ticks(maxValue);
    final chartMax = ticks.first <= 0 ? 1.0 : ticks.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: lineColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              yAxisTitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 16,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      yAxisTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 58,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ticks
                        .map(
                          (tick) => Text(
                            '${tick.toStringAsFixed(2)} $valueSuffix'.trim(),
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: _PurchasesLinePainter(
                                  values: values,
                                  maxValue: chartMax,
                                  lineColor: lineColor,
                                ),
                              ),
                              Row(
                                children: List.generate(values.length, (index) {
                                  final label = index < categories.length ? categories[index] : '';
                                  return Expanded(
                                    child: Tooltip(
                                      message: tooltipBuilder(index, values[index], label),
                                      child: const SizedBox.expand(),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(categories.length, (index) {
                        return Expanded(
                          child: Text(
                            categories[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchasesLinePainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color lineColor;

  _PurchasesLinePainter({
    required this.values,
    required this.maxValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x24782074)
      ..strokeWidth = 1;

    const rows = 10;
    for (var i = 0; i <= rows; i++) {
      final y = size.height * i / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / maxValue).clamp(0.0, 1.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PurchasesLinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.lineColor != lineColor;
  }
}

class DashboardPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const DashboardPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: PortalUi.cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

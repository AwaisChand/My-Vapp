import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../app_localization.dart';

class SavingsAnimation extends StatefulWidget {
  final double dayValue;
  final double monthValue;
  final double yearValue;

  const SavingsAnimation({
    super.key,
    this.dayValue = 0,
    this.monthValue = 0,
    this.yearValue = 0,
  });

  @override
  State<SavingsAnimation> createState() => _SavingsAnimationState();
}

enum _SavingsPeriod { day, month, year }

class _SavingsAnimationState extends State<SavingsAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _tickerController;
  _SavingsPeriod _activePeriod = _SavingsPeriod.day;
  double _displayValue = 0;
  bool _boosting = false;
  bool _vaultPressed = false;
  int _burstSeed = 0;
  Timer? _periodTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _displayValue = widget.dayValue;
    _periodTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_activePeriod.index + 1) % _SavingsPeriod.values.length;
      _setPeriod(_SavingsPeriod.values[next]);
    });
    _setPeriod(_SavingsPeriod.day);
  }

  @override
  void didUpdateWidget(covariant SavingsAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animateTo(_valueForPeriod(_activePeriod));
  }

  @override
  void dispose() {
    _periodTimer?.cancel();
    _controller.dispose();
    _tickerController.dispose();
    super.dispose();
  }

  double _valueForPeriod(_SavingsPeriod period) {
    switch (period) {
      case _SavingsPeriod.day:
        return widget.dayValue;
      case _SavingsPeriod.month:
        return widget.monthValue;
      case _SavingsPeriod.year:
        return widget.yearValue;
    }
  }

  String _labelForPeriod(_SavingsPeriod period, AppLocalizations l10n) {
    switch (period) {
      case _SavingsPeriod.day:
        return l10n.translate('perDay') ?? 'Per day';
      case _SavingsPeriod.month:
        return l10n.translate('perMonth') ?? 'Per month';
      case _SavingsPeriod.year:
        return l10n.translate('perYear') ?? 'Per year';
    }
  }

  void _setPeriod(_SavingsPeriod period) {
    setState(() => _activePeriod = period);
    _animateTo(_valueForPeriod(period));
  }

  void _animateTo(double target) {
    final start = _displayValue;
    _tickerController
      ..stop()
      ..reset();
    void tick() {
      final t = Curves.easeOutCubic.transform(_tickerController.value);
      setState(() => _displayValue = start + (target - start) * t);
    }

    _tickerController
      ..removeListener(tick)
      ..addListener(tick)
      ..forward(from: 0);
  }

  void _onVaultTap() {
    setState(() {
      _boosting = true;
      _vaultPressed = true;
      _burstSeed++;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _vaultPressed = false);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _boosting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            l10n.translate('savingsOverview') ?? 'Savings overview',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 188,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final coinDuration = _boosting ? 0.45 : 1.0;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _SceneBackdrop(),
                      _GrowthBars(progress: t),
                      _TrendLine(progress: t),
                      for (var i = 0; i < 7; i++)
                        _FallingCoin(
                          progress: ((t * coinDuration) + (i * 0.14)) % 1.0,
                          leftFactor: 0.08 + (i * 0.125),
                          size: i == 0 || i == 4
                              ? _CoinSize.small
                              : i == 2 || i == 6
                                  ? _CoinSize.large
                                  : _CoinSize.medium,
                        ),
                      ..._floatingBadges(t),
                      _BurstCoins(seed: _burstSeed),
                      GestureDetector(
                        onTap: _onVaultTap,
                        child: _PiggyVault(
                          progress: t,
                          pressed: _vaultPressed,
                        ),
                      ),
                      ..._sparkles(t),
                      _TickerPill(
                        label: _labelForPeriod(_activePeriod, l10n),
                        value: _displayValue,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 2000),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -2 * math.sin(value * math.pi)),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 12,
                  color: AppColors.success,
                ),
              ),
              Text(
                l10n.translate('savingsKeepGrowing') ??
                    'Your savings keep growing',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '• ${l10n.translate('tapPiggyBank') ?? 'Tap the piggy bank'}',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _floatingBadges(double t) {
    const delays = [0.22, 0.5, 0.78];
    const lefts = [0.28, 0.48, 0.68];

    return List.generate(3, (index) {
      final phase = (t + delays[index]) % 1.0;
      final visible = phase > 0.58 && phase < 0.88;
      final lift = phase > 0.58 ? (phase - 0.58) / 0.3 : 0.0;

      return Positioned(
        left: MediaQuery.sizeOf(context).width * lefts[index] * 0.35,
        bottom: 72 + lift * 18,
        child: Opacity(
          opacity: visible ? (1 - (lift * 0.8).clamp(0.0, 1.0)) : 0,
          child: Transform.scale(
            scale: visible ? 0.85 + (lift * 0.15) : 0.8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '+€',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF047857),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _sparkles(double t) {
    const colors = [
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      AppColors.primaryMid,
      AppColors.warning,
      Color(0xFF22C55E),
    ];
    const offsets = [
      Offset(0, 0),
      Offset(18, 14),
      Offset(8, 28),
      Offset(32, 8),
      Offset(38, 22),
    ];

    return List.generate(5, (index) {
      final phase = (t + index * 0.2) % 1.0;
      final visible = phase > 0.58 && phase < 0.78;
      final scale = visible ? 0.3 + ((phase - 0.58) / 0.2) * 1.0 : 0.3;

      return Positioned(
        top: 20 + offsets[index].dy,
        right: 24 + (4 - index) * 6.0,
        child: Opacity(
          opacity: visible ? 1 : 0,
          child: Transform.rotate(
            angle: phase * math.pi,
            child: Container(
              width: index.isEven ? 7 : 5,
              height: index.isEven ? 7 : 5,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
              transform: Matrix4.diagonal3Values(scale, scale, 1),
            ),
          ),
        ),
      );
    });
  }
}

enum _CoinSize { small, medium, large }

class _SceneBackdrop extends StatelessWidget {
  const _SceneBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySoft,
            Colors.white,
            AppColors.scaffoldBg,
          ],
          stops: const [0, 0.42, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            left: 24,
            child: _BlurOrb(
              size: 72,
              color: AppColors.primaryMid.withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            top: 24,
            right: 16,
            child: _BlurOrb(
              size: 56,
              color: AppColors.success.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: 18,
            left: MediaQuery.sizeOf(context).width * 0.55,
            child: _BlurOrb(
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.55),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 28,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _GrowthBars extends StatelessWidget {
  final double progress;

  const _GrowthBars({required this.progress});

  static const _heights = <double>[18, 28, 38, 30, 44];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 14,
      child: Opacity(
        opacity: 0.45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(5, (index) {
            final phase = (progress + index * 0.125) % 1.0;
            final scale = 0.82 + 0.3 * math.sin(phase * math.pi * 2);

            return Padding(
              padding: EdgeInsets.only(right: index == 4 ? 0 : 5),
              child: Transform.scale(
                scaleY: scale,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 10,
                  height: _heights[index],
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                      bottom: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TrendLine extends StatelessWidget {
  final double progress;

  const _TrendLine({required this.progress});

  @override
  Widget build(BuildContext context) {
    final draw = Curves.easeInOut.transform(
      ((progress * 1.25) % 1.0).clamp(0.0, 1.0),
    );

    return Positioned(
      top: 16,
      right: 12,
      child: Opacity(
        opacity: 0.35,
        child: CustomPaint(
          size: const Size(100, 36),
          painter: _TrendPainter(drawProgress: draw),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final double drawProgress;

  _TrendPainter({required this.drawProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * 0.04, size.height * 0.82),
      Offset(size.width * 0.24, size.height * 0.66),
      Offset(size.width * 0.44, size.height * 0.52),
      Offset(size.width * 0.64, size.height * 0.32),
      Offset(size.width * 0.84, size.height * 0.16),
      Offset(size.width * 0.96, size.height * 0.06),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final metrics = path.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * drawProgress);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extract, linePaint);

    if (drawProgress > 0.3) {
      final area = Path.from(extract)
        ..lineTo(extract.getBounds().right, size.height)
        ..lineTo(extract.getBounds().left, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryMid.withValues(alpha: 0.25),
            AppColors.primaryMid.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(area, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.drawProgress != drawProgress;
}

class _FallingCoin extends StatelessWidget {
  final double progress;
  final double leftFactor;
  final _CoinSize size;

  const _FallingCoin({
    required this.progress,
    required this.leftFactor,
    required this.size,
  });

  double get _diameter {
    switch (size) {
      case _CoinSize.small:
        return 18;
      case _CoinSize.medium:
        return 24;
      case _CoinSize.large:
        return 28;
    }
  }

  double get _fontSize {
    switch (size) {
      case _CoinSize.small:
        return 9;
      case _CoinSize.medium:
        return 12;
      case _CoinSize.large:
        return 13;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final fall = t < 0.55
        ? Curves.easeIn.transform(t / 0.55)
        : 1.0 + 0.04 * math.sin((t - 0.55) / 0.15 * math.pi);
    final yBase = 8 + fall * 72;
    final bounce = t > 0.55 && t < 0.7
        ? -4 * math.sin((t - 0.55) / 0.15 * math.pi)
        : 0.0;

    final opacity = t < 0.08
        ? t / 0.08
        : t > 0.7
            ? (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0)
            : 1.0;

    final scale = t > 0.7
        ? lerpDouble(1, 0.5, (t - 0.7) / 0.3) ?? 1
        : t < 0.08
            ? lerpDouble(0.55, 1, t / 0.08) ?? 1
            : 1.0;

    return Positioned(
      left: MediaQuery.sizeOf(context).width * leftFactor * 0.38,
      top: yBase + bounce,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: (-0.35 + fall * 0.55) * math.pi,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: _diameter,
              height: _diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFEF3C7),
                    Color(0xFFFDE68A),
                    Color(0xFFF59E0B),
                    Color(0xFFD97706),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '€',
                style: GoogleFonts.poppins(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF854D0E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PiggyVault extends StatelessWidget {
  final double progress;
  final bool pressed;

  const _PiggyVault({required this.progress, this.pressed = false});

  @override
  Widget build(BuildContext context) {
    final pulsePhase = progress % 1.0;
    final pulse = pulsePhase > 0.55 && pulsePhase < 0.78
        ? 1 + 0.05 * math.sin((pulsePhase - 0.55) / 0.23 * math.pi)
        : 1.0;
    final ringVisible = pulsePhase > 0.58 && pulsePhase < 0.78;
    final ringScale = ringVisible ? 0.6 + (pulsePhase - 0.58) / 0.2 * 0.85 : 0.6;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Transform.scale(
          scale: pressed ? pulse * 0.94 : pulse,
          child: SizedBox(
            width: 108,
            height: 86,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -4,
                  child: Container(
                    width: 120,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                if (ringVisible)
                  Positioned(
                    top: 10,
                    child: Opacity(
                      opacity: (1 - (pulsePhase - 0.58) / 0.2).clamp(0.0, 0.7),
                      child: Transform.scale(
                        scale: ringScale,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryMid.withValues(alpha: 0.55),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.18),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 108,
                  height: 78,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryMid,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGlow,
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(4, (index) {
                            final show = (progress + index * 0.14) % 1.0 > 0.52;
                            return Padding(
                              padding: EdgeInsets.only(left: index == 0 ? 0 : 3),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: show ? 1 : 0,
                                child: Container(
                                  width: index.isOdd ? 16 : 14,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFDE68A),
                                        Color(0xFFF59E0B),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TickerPill extends StatelessWidget {
  final String label;
  final double value;

  const _TickerPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(label),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.06,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '€${value.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstCoins extends StatefulWidget {
  final int seed;

  const _BurstCoins({required this.seed});

  @override
  State<_BurstCoins> createState() => _BurstCoinsState();
}

class _BurstCoinsState extends State<_BurstCoins>
    with SingleTickerProviderStateMixin {
  late AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didUpdateWidget(covariant _BurstCoins oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed) {
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_burstController.value == 0 && widget.seed == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _burstController,
      builder: (context, _) {
        return Stack(
          children: List.generate(8, (index) {
            final t = Curves.easeOutCubic.transform(_burstController.value);
            final angle = (index / 8) * math.pi * 2;
            final dx = math.cos(angle) * 42 * t;
            final dy = -28 * t - math.sin(angle).abs() * 18 * t;

            return Positioned(
              left: MediaQuery.sizeOf(context).width * 0.5 + dx - 10,
              bottom: 72 - dy,
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: t * math.pi,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFEF3C7), Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '€',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../app_assets.dart';

/// Full-screen loader background matching `#global-loader.my-vapp-loader` on web.
class LoaderBackground extends StatelessWidget {
  final Widget child;

  const LoaderBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF9FD), Color(0xFFF8F0F8), Color(0xFFF0E4F0)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _radialGlow(
            alignment: const Alignment(0, -0.15),
            color: AppColors.primaryMid,
            alpha: 0.18,
            radius: 0.52,
          ),
          _radialGlow(
            alignment: const Alignment(-0.6, 0.85),
            color: AppColors.primary,
            alpha: 0.10,
            radius: 0.40,
          ),
          _radialGlow(
            alignment: const Alignment(0.6, -0.75),
            color: AppColors.accent,
            alpha: 0.14,
            radius: 0.38,
          ),
          child,
        ],
      ),
    );
  }

  Widget _radialGlow({
    required Alignment alignment,
    required Color color,
    required double alpha,
    required double radius,
  }) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: radius * 2,
        heightFactor: radius * 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: alpha),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Web global-loader stage: aura + orbit ring + breathing round logo.
class WebLoaderStage extends StatefulWidget {
  final double stageSize;
  final bool showOrbit;
  final bool animate;

  const WebLoaderStage({
    super.key,
    this.stageSize = 160,
    this.showOrbit = true,
    this.animate = true,
  });

  @override
  State<WebLoaderStage> createState() => _WebLoaderStageState();
}

class _WebLoaderStageState extends State<WebLoaderStage> with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _breathController;
  late final AnimationController _auraController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    if (widget.animate) {
      _orbitController.repeat();
      _breathController.repeat(reverse: true);
      _auraController.repeat(reverse: true);
    } else {
      _orbitController.value = 0;
      _breathController.value = 0;
      _auraController.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant WebLoaderStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _orbitController.repeat();
        _breathController.repeat(reverse: true);
        _auraController.repeat(reverse: true);
      } else {
        _orbitController.stop();
        _breathController.stop();
        _auraController.stop();
      }
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _breathController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stageSize;
    final logoSize = stage * 0.75;
    final auraInset = stage * 0.05;

    return SizedBox(
      width: stage,
      height: stage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _auraController,
            builder: (context, child) {
              final t = widget.animate ? _auraController.value : 0.5;
              final scale = 0.92 + (0.16 * t);
              final opacity = 0.65 + (0.35 * t);
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: stage - (auraInset * 2),
                    height: stage - (auraInset * 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryMid.withValues(alpha: 0.55),
                          AppColors.primary.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 0.72],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.showOrbit)
            AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _orbitController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: SizedBox(
                width: stage,
                height: stage,
                child: CustomPaint(
                  painter: _OrbitRingPainter(strokeWidth: stage * 0.0125),
                ),
              ),
            ),
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final t = widget.animate ? _breathController.value : 0.0;
              final scale = 1.0 + (0.06 * t);
              final dy = -4.0 * t;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: _LoaderLogo(size: logoSize),
          ),
        ],
      ),
    );
  }
}

class _LoaderLogo extends StatelessWidget {
  final double size;

  const _LoaderLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: size * 0.27,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.appLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double strokeWidth;

  _OrbitRingPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    final topPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.primaryMid.withValues(alpha: 0.75)
      ..strokeCap = StrokeCap.round;

    final sidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.1,
      false,
      topPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 5,
      math.pi / 3,
      false,
      sidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => false;
}

/// Static round logo for login and headers (no orbit animation).
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showAura;

  const BrandLogo({
    super.key,
    this.size = 96,
    this.showAura = true,
  });

  @override
  Widget build(BuildContext context) {
    return WebLoaderStage(
      stageSize: size,
      showOrbit: false,
      animate: showAura,
    );
  }
}

/// Auth screens background (same palette as web loader).
class AuthScreenBackground extends StatelessWidget {
  final Widget child;

  const AuthScreenBackground({super.key, required this.child});

  static const bottomColor = Color(0xFFF0E4F0);

  @override
  Widget build(BuildContext context) {
    return LoaderBackground(child: child);
  }
}

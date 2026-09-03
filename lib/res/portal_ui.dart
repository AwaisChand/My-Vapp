import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';
import 'components/customer_shell.dart';

/// Typography + reusable portal widgets matching the web customer dashboard.
class PortalUi {
  PortalUi._();

  static TextStyle poppins({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle pageTitle(BuildContext context) => poppins(
        size: 24,
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle pageSubtitle(BuildContext context) => poppins(
        size: 14,
        weight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.55,
      );

  static TextStyle sectionTitle(BuildContext context) => poppins(
        size: 18,
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle heroBalance(BuildContext context) => poppins(
        size: 36,
        weight: FontWeight.w800,
        color: Colors.white,
      );

  static BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      );

  static BoxDecoration heroDecoration({double radius = 16}) => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.brandShadow,
      );

  static Widget pageHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    bool showBack = false,
    VoidCallback? onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: AppColors.textPrimary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else if (CustomerShell.maybeOf(context) != null) ...[
                CustomerShell.menuButton(context)!,
                const SizedBox(width: 4),
              ],
              if (showBack) const SizedBox(width: 12),
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(title, style: pageTitle(context)),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: pageSubtitle(context)),
          ],
        ],
      ),
    );
  }

  static Widget gradientButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    double height = 52,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : AppColors.primaryGradient,
          color: onPressed == null ? AppColors.textSubtle : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null ? null : AppColors.brandShadow,
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  label,
                  style: poppins(size: 16, weight: FontWeight.w600, color: Colors.white),
                ),
        ),
      ),
    );
  }

  static Widget pillTabs({
    required TabController controller,
    required List<String> labels,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppColors.brandShadow,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: poppins(size: 12, weight: FontWeight.w600),
        unselectedLabelStyle: poppins(size: 12, weight: FontWeight.w500),
        tabs: labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }

  static Widget promoCard({
    required String title,
    String? code,
    String? expiry,
    String? discount,
    VoidCallback? onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: poppins(size: 16, weight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      discount,
                      style: poppins(size: 12, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (code != null && code.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE9D4EB)),
                        ),
                        child: Text(
                          code,
                          style: poppins(
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      if (onCopy != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onCopy,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: AppColors.primary,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primarySoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                if (expiry != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    expiry,
                    style: poppins(size: 12, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

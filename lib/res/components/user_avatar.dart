import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/login_model/login_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/avatar_utils.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final String? imageUrl;
  final String? name;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? caption;

  const UserAvatar({
    super.key,
    required this.user,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.borderWidth = 2,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ??
        AvatarUtils.resolve(
          avatarUrl: user?.avatarUrl,
          avatar: user?.avatar,
        );
    final displayName = name ?? user?.name ?? '';
    final initial = displayName.isNotEmpty ? displayName.trim()[0].toUpperCase() : 'M';
    final useInitial = !AvatarUtils.hasCustomAvatar(
      avatarUrl: imageUrl ?? user?.avatarUrl,
      avatar: user?.avatar,
    );

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.85),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: useInitial
          ? _fallback(initial)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => _fallback(initial),
              errorWidget: (_, __, ___) => _fallback(initial),
            ),
    );

    Widget content = avatar;
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      );
    }

    if (caption == null || caption!.isEmpty) {
      return content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        const SizedBox(height: 4),
        Text(
          caption!,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _fallback(String initial) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

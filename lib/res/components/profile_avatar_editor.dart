import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/login_model/login_model.dart';
import 'package:lim_crm/res/components/user_avatar.dart';
import 'package:lim_crm/utils/app_colors.dart';

class ProfileAvatarEditor extends StatelessWidget {
  final User? user;
  final File? localImage;
  final VoidCallback onTap;
  final double size;

  const ProfileAvatarEditor({
    super.key,
    required this.user,
    this.localImage,
    required this.onTap,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (localImage != null)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(localImage!, fit: BoxFit.cover),
                )
              else
                UserAvatar(user: user, size: size, borderWidth: 3),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget profileAvatarHint(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
    ),
  );
}

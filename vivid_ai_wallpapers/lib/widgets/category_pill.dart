import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

class CategoryPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const CategoryPill({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BouncingWrapper(
        lowerBound: 0.94,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple
                : (isDark ? AppColors.darkSurface : AppColors.pillBackground),
            borderRadius: BorderRadius.circular(24),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

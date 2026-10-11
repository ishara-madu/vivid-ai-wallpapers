import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool isDark;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.borderLight.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : AppColors.primaryPurple.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem(
              index: 0,
              icon: AmazingIconFilled.discover,
              outlineIcon: AmazingIconOutlined.discover,
            ),
            const SizedBox(width: 20),
            _buildNavItem(
              index: 1,
              icon: AmazingIconFilled.gallery,
              outlineIcon: AmazingIconOutlined.gallery,
            ),
            const SizedBox(width: 20),
            _buildNavItem(
              index: 2,
              icon: AmazingIconFilled.heart,
              outlineIcon: AmazingIconOutlined.heart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlineIcon,
  }) {
    final isSelected = currentIndex == index;
    return BouncingWrapper(
      lowerBound: 0.88,
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryPurple.withOpacity(0.2)
                  : AppColors.pillBackground)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: child,
            ),
            child: Icon(
              isSelected ? icon : outlineIcon,
              key: ValueKey<bool>(isSelected),
              size: 24,
              color: isSelected
                  ? AppColors.primaryPurple
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

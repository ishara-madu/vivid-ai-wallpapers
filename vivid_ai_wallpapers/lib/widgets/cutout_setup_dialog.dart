import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amazing_icons/amazing_icons.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

/// Premium Gazeo-style Visual Camera Cutout Selection Modal.
/// Features a tactile 2x2 grid of modern phone silhouettes with precise camera notch alignment.
class CutoutSetupDialog extends StatefulWidget {
  final CutoutType currentCutout;
  final ValueChanged<CutoutType> onSelect;
  final bool isDark;

  const CutoutSetupDialog({
    super.key,
    required this.currentCutout,
    required this.onSelect,
    this.isDark = false,
  });

  static Future<void> show({
    required BuildContext context,
    required CutoutType currentCutout,
    required ValueChanged<CutoutType> onSelect,
    bool isDark = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CutoutSetupDialog(
        currentCutout: currentCutout,
        onSelect: onSelect,
        isDark: isDark,
      ),
    );
  }

  @override
  State<CutoutSetupDialog> createState() => _CutoutSetupDialogState();
}

class _CutoutSetupDialogState extends State<CutoutSetupDialog> {
  late CutoutType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCutout;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Row with Glowing Icon
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple.withValues(alpha: 0.16),
                        AppColors.accentCoral.withValues(alpha: 0.16),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      AmazingIconOutlined.mobile,
                      color: AppColors.primaryPurple,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Camera Cutout',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select your phone\'s camera notch to tailor wallpapers',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2x2 Tactile Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    type: CutoutType.centerHole,
                    title: 'Center Hole',
                    subtitle: 'Galaxy, Pixel, Xiaomi',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridCard(
                    type: CutoutType.dynamicIsland,
                    title: 'Dynamic Island',
                    subtitle: 'iPhone 14-16 Pro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    type: CutoutType.leftHole,
                    title: 'Left Corner',
                    subtitle: 'OnePlus, Realme',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridCard(
                    type: CutoutType.universal,
                    title: 'Universal',
                    subtitle: 'Notchless & all phones',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Confirm Button
            BouncingWrapper(
              lowerBound: 0.95,
              onTap: () {
                widget.onSelect(_selected);
                Navigator.pop(context);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      AmazingIconFilled.tickCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Apply Cutout Style',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required CutoutType type,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selected == type;
    final isDark = widget.isDark;

    final cardBg = isSelected
        ? (isDark
            ? AppColors.darkCard
            : Colors.white)
        : (isDark
            ? AppColors.darkCard.withValues(alpha: 0.6)
            : AppColors.pillBackground.withValues(alpha: 0.8));

    final borderColor = isSelected
        ? AppColors.primaryPurple
        : (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.borderLight.withValues(alpha: 0.6));

    return BouncingWrapper(
      lowerBound: 0.96,
      onTap: () {
        setState(() {
          _selected = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: isDark ? 0.3 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            // Top Indicator (Checked or Placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 18),
                _buildPhoneMockup(type, isSelected),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryPurple : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : (isDark ? Colors.white30 : AppColors.textMuted.withValues(alpha: 0.3)),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.check, size: 12, color: Colors.white),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primaryPurple
                    : (isDark ? Colors.white : AppColors.textDark),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Stylized Mini Phone Mockup with precision physical cutout rendering
  Widget _buildPhoneMockup(CutoutType type, bool isSelected) {
    return Container(
      width: 44,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF13101C),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryPurple.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Screen Interior with Vibrant Flows gradient
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [Color(0xFF3B1E78), Color(0xFF18122B)]
                      : const [Color(0xFF241A38), Color(0xFF110D1D)],
                ),
              ),
            ),
          ),

          // Physical Camera Cutouts
          if (type == CutoutType.centerHole)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPurple : Colors.white54,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                  ],
                ),
              ),
            )
          else if (type == CutoutType.dynamicIsland)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                width: 16,
                height: 5.5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSelected ? AppColors.accentCoral : Colors.white54,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.accentCoral.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                  ],
                ),
              ),
            )
          else if (type == CutoutType.leftHole)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 5, left: 5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPurple : Colors.white54,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                  ],
                ),
              ),
            )
          else if (type == CutoutType.universal)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

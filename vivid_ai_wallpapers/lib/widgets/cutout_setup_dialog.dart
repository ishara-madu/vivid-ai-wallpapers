import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amazing_icons/amazing_icons.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

/// Interactive Visual Camera Cutout Selection Modal.
/// Displays tactile phone mockups helping users instantly choose their device's camera style.
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AmazingIconOutlined.mobile,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Camera Cutout',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Wallpapers will be custom-fitted to your screen',
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

          // Cutout Options Grid
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildCutoutCard(
                    type: CutoutType.centerHole,
                    title: 'Center Hole-Punch',
                    subtitle: 'Samsung S21-S25, Xiaomi, Pixel, Nothing',
                    badge: 'Most Popular',
                  ),
                  const SizedBox(height: 12),
                  _buildCutoutCard(
                    type: CutoutType.dynamicIsland,
                    title: 'Dynamic Island / Pill',
                    subtitle: 'iPhone 14-16 Pro, Honor Magic Pill',
                    badge: 'Capsule Flow',
                  ),
                  const SizedBox(height: 12),
                  _buildCutoutCard(
                    type: CutoutType.leftHole,
                    title: 'Left Corner Hole',
                    subtitle: 'OnePlus, Realme, older Galaxy S10',
                    badge: 'Corner Arc',
                  ),
                  const SizedBox(height: 12),
                  _buildCutoutCard(
                    type: CutoutType.universal,
                    title: 'Universal Stealth Fade',
                    subtitle: 'Pure OLED black fade for all notches & waterdrops',
                    badge: '100% Fit',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Confirm Button
          BouncingWrapper(
            lowerBound: 0.95,
            onTap: () {
              widget.onSelect(_selected);
              Navigator.pop(context);
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AmazingIconFilled.tickCircle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Apply & Personalize Feed',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCutoutCard({
    required CutoutType type,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    final isSelected = _selected == type;
    final isDark = widget.isDark;

    return BouncingWrapper(
      lowerBound: 0.96,
      onTap: () {
        setState(() {
          _selected = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryPurple.withOpacity(0.18)
                  : AppColors.primaryPurple.withOpacity(0.08))
              : (isDark ? AppColors.darkCard : AppColors.pillBackground.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Visual Phone Mockup Thumbnail with camera indicator
            _buildPhoneMockup(type, isSelected),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : (isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : AppColors.primaryPurple.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.primaryPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryPurple : AppColors.textMuted.withOpacity(0.4),
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryPurple : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Stylized Mini Phone Mockup showing the physical cutout position
  Widget _buildPhoneMockup(CutoutType type, bool isSelected) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1016),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryPurple : Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.3),
              blurRadius: 10,
            ),
        ],
      ),
      child: Stack(
        children: [
          // Screen interior glow
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    type == CutoutType.universal
                        ? Colors.black
                        : const Color(0xFF1E1035),
                    const Color(0xFF0A0714),
                  ],
                ),
              ),
            ),
          ),

          // Camera Cutout Representation
          if (type == CutoutType.centerHole)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFB703) : Colors.white60,
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0xFFFFB703),
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
                margin: const EdgeInsets.only(top: 6),
                width: 18,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF523B) : Colors.white60,
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0xFFFF523B),
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
                margin: const EdgeInsets.only(top: 6, left: 6),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00E599) : Colors.white60,
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0xFF00E599),
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
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.0),
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

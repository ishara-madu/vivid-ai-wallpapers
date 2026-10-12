import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_wrapper.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;
  final Function(String wallpaperId) onToggleLike;
  final bool isDark;

  const WallpaperDetailScreen({
    super.key,
    required this.wallpaper,
    required this.onToggleLike,
    this.isDark = false,
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  late Wallpaper _currentWallpaper;
  int _selectedVariantIndex = 0;
  String? _selectedCutoutVariantKey;

  // Interactive Cutout Alignment state
  bool _isTunerMode = false;
  double _verticalOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _currentWallpaper = widget.wallpaper;
    if (_currentWallpaper.cutoutVariants.isNotEmpty) {
      _selectedCutoutVariantKey = _currentWallpaper.cutoutVariants.keys.first;
    }
  }

  void _showSetWallpaperSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              Text(
                'Apply Wallpaper',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose where you would like to apply this wallpaper',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              _buildApplyOption(
                icon: AmazingIconOutlined.mobile,
                title: 'Set as Home Screen',
                onTap: () => _applyWallpaper('Home Screen'),
              ),
              const SizedBox(height: 10),
              _buildApplyOption(
                icon: AmazingIconOutlined.lock,
                title: 'Set as Lock Screen',
                onTap: () => _applyWallpaper('Lock Screen'),
              ),
              const SizedBox(height: 10),
              _buildApplyOption(
                icon: AmazingIconOutlined.devices1,
                title: 'Set on Both Screens',
                onTap: () => _applyWallpaper('Both Screens'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplyOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      lowerBound: 0.95,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.darkCard
              : AppColors.pillBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            Icon(
              AmazingIconOutlined.arrowRight2,
              color: AppColors.textMuted.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _applyWallpaper(String target) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(AmazingIconFilled.tickCircle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Applied successfully to $target!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showVariantSelector() {
    final hasCutoutVariants = _currentWallpaper.cutoutVariants.isNotEmpty;
    final hasStandardVariants = _currentWallpaper.variants.isNotEmpty;

    if (!hasCutoutVariants && !hasStandardVariants) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This wallpaper does not have additional cutout variants.',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final cutoutEntries = _currentWallpaper.cutoutVariants.entries.toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cutout Variants',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Choose for your camera',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal list of variants with cutout labels
              SizedBox(
                height: 150,
                child: hasCutoutVariants
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cutoutEntries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final entry = cutoutEntries[index];
                          final isSelected = _selectedCutoutVariantKey == entry.key;

                          return BouncingWrapper(
                            lowerBound: 0.92,
                            onTap: () {
                              setState(() {
                                _selectedCutoutVariantKey = entry.key;
                              });
                              Navigator.pop(context);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 90,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    entry.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: AppColors.primaryPurple.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : (widget.isDark
                                            ? Colors.white10
                                            : AppColors.pillBackground),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (widget.isDark
                                              ? Colors.white70
                                              : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentWallpaper.variants.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final variantUrl = _currentWallpaper.variants[index];
                          final isSelected = _selectedVariantIndex == index;
                          return BouncingWrapper(
                            lowerBound: 0.92,
                            onTap: () {
                              setState(() {
                                _selectedVariantIndex = index;
                              });
                              Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 90,
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                variantUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _downloadWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accentCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(AmazingIconFilled.tickCircle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Wallpaper saved in Ultra HD!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Title and Engine Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentWallpaper.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: widget.isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentWallpaper.category}  •  Target: ${_currentWallpaper.cutoutType.displayName}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Upload Date Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkCard
                          : AppColors.pillBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AmazingIconOutlined.calendar,
                          size: 13,
                          color: widget.isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentWallpaper.uploadDate,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wallpaper Note / Description
              Text(
                _currentWallpaper.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.textDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 22),

              // Minimal Specs Line
              Row(
                children: [
                  const Icon(
                    AmazingIconOutlined.image,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentWallpaper.resolution}  •  ${_currentWallpaper.dimensions}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getActiveImageUrl() {
    if (_selectedCutoutVariantKey != null &&
        _currentWallpaper.cutoutVariants.containsKey(_selectedCutoutVariantKey)) {
      return _currentWallpaper.cutoutVariants[_selectedCutoutVariantKey]!;
    }
    if (_currentWallpaper.variants.isNotEmpty &&
        _selectedVariantIndex < _currentWallpaper.variants.length) {
      return _currentWallpaper.variants[_selectedVariantIndex];
    }
    return _currentWallpaper.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = _getActiveImageUrl();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wallpaper Full View with Interactive Pan / Alignment
          GestureDetector(
            onVerticalDragUpdate: _isTunerMode
                ? (details) {
                    setState(() {
                      _verticalOffset = (_verticalOffset + details.delta.dy)
                          .clamp(-120.0, 120.0);
                    });
                  }
                : null,
            child: Transform.translate(
              offset: Offset(0, _verticalOffset),
              child: Image.network(
                currentImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _currentWallpaper.gradientFallback,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        AmazingIconOutlined.image,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Top Subtle Gradient Scrim
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Camera Cutout Reticle & Alignment Guide (Visible in Tuner Mode)
          if (_isTunerMode) _buildCutoutGuideOverlay(),

          // Top Navigation Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                BouncingWrapper(
                  lowerBound: 0.88,
                  onTap: () {
                    if (_isTunerMode) {
                      setState(() {
                        _isTunerMode = false;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AmazingIconOutlined.arrowLeft2,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Title Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isTunerMode ? 'Cutout Alignment Tool' : _currentWallpaper.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Info Button
                BouncingWrapper(
                  lowerBound: 0.88,
                  onTap: _showInfoSheet,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AmazingIconOutlined.infoCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Controls: Standard Actions or Tuner Control Panel
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 20,
            right: 20,
            child: _isTunerMode
                ? _buildTunerControlPanel()
                : _buildStandardActionToolbar(),
          ),
        ],
      ),
    );
  }

  /// Top Cutout Alignment Guide showing optical camera position
  Widget _buildCutoutGuideOverlay() {
    final cutout = _currentWallpaper.cutoutType;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Optical Reticle
          if (cutout == CutoutType.centerHole)
            Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB703), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFFB703), blurRadius: 8),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 14, color: Color(0xFFFFB703)),
                ),
              ),
            )
          else if (cutout == CutoutType.dynamicIsland)
            Center(
              child: Container(
                width: 90,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF523B), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFF523B), blurRadius: 8),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'ISLAND',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF523B),
                    ),
                  ),
                ),
              ),
            )
          else if (cutout == CutoutType.leftHole)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 24),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E599), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF00E599), blurRadius: 8),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 14, color: Color(0xFF00E599)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Drag image up/down to align with your camera lens',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Specialized Tuner Control Bar
  Widget _buildTunerControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14121F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nudge Down Button
          BouncingWrapper(
            onTap: () {
              setState(() {
                _verticalOffset = (_verticalOffset - 4).clamp(-120.0, 120.0);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_upward, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Up', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),

          // Offset readout & Reset
          GestureDetector(
            onTap: () {
              setState(() {
                _verticalOffset = 0.0;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_verticalOffset >= 0 ? "+" : ""}${_verticalOffset.toInt()} px',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPurple,
                  ),
                ),
                Text(
                  'Tap to Reset',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Nudge Up Button
          BouncingWrapper(
            onTap: () {
              setState(() {
                _verticalOffset = (_verticalOffset + 4).clamp(-120.0, 120.0);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_downward, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Down', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),

          // Done Button
          BouncingWrapper(
            onTap: () {
              setState(() {
                _isTunerMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryPurple,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: const Text('Camera alignment locked & saved!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Lock',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Standard Floating Action Toolbar
  Widget _buildStandardActionToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left 4 Action Buttons (Download, Tuner Tool, Variants, Apply)
        Row(
          children: [
            _buildCircularAction(
              icon: AmazingIconFilled.arrowDown,
              onTap: _downloadWallpaper,
            ),
            const SizedBox(width: 10),
            // Tuner Button
            _buildCircularAction(
              icon: AmazingIconOutlined.sliderVertical,
              badgeActive: _verticalOffset != 0.0,
              onTap: () {
                setState(() {
                  _isTunerMode = true;
                });
              },
            ),
            const SizedBox(width: 10),
            // Variants Button
            _buildCircularAction(
              icon: AmazingIconFilled.layer,
              badgeActive: _currentWallpaper.isMultivariant,
              onTap: _showVariantSelector,
            ),
            const SizedBox(width: 10),
            // Apply Wallpaper Button
            _buildCircularAction(
              icon: AmazingIconFilled.paintbucket,
              onTap: _showSetWallpaperSheet,
            ),
          ],
        ),

        // Right Favorite Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: LikeHeartButton(
              isLiked: _currentWallpaper.isLiked,
              onTap: () {
                setState(() {
                  _currentWallpaper.isLiked = !_currentWallpaper.isLiked;
                });
                widget.onToggleLike(_currentWallpaper.id);
              },
              size: 24,
              likedColor: AppColors.primaryPurple,
              unlikedColor: AppColors.textDark,
              likedIcon: AmazingIconFilled.heart,
              unlikedIcon: AmazingIconOutlined.heart,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required VoidCallback onTap,
    bool badgeActive = false,
  }) {
    return BouncingWrapper(
      lowerBound: 0.88,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textDark, size: 20),
            if (badgeActive)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

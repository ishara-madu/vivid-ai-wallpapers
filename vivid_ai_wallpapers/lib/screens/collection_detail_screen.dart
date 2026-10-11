import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/wallpaper_card.dart';
import 'wallpaper_detail_screen.dart';

class CollectionDetailScreen extends StatelessWidget {
  final WallpaperCollection collection;
  final Function(String wallpaperId) onToggleLike;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = collection.isDarkTheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BouncingWrapper(
                      lowerBound: 0.88,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.pillBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AmazingIconOutlined.arrowLeft2,
                          color: isDark ? Colors.white : AppColors.textDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collection Header Details (Title, Subtitle, Count Badge)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collection.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Badge with count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.pillBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AmazingIconOutlined.gallery,
                            size: 16,
                            color: isDark ? Colors.white70 : AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${collection.wallpaperCount} wallpapers',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Wallpapers Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final wp = collection.wallpapers[index];
                    return WallpaperCard(
                      wallpaper: wp,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WallpaperDetailScreen(
                              wallpaper: wp,
                              onToggleLike: onToggleLike,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                      onLikeToggle: () => onToggleLike(wp.id),
                    );
                  },
                  childCount: collection.wallpapers.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

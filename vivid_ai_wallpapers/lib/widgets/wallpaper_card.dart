import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;
  final bool isDark;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.onTap,
    required this.onLikeToggle,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      lowerBound: 0.96,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? AppColors.darkCard : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image / Gradient Fallback
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: wallpaper.gradientFallback,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Image.network(
                wallpaper.thumbnailUrl.isNotEmpty
                    ? wallpaper.thumbnailUrl
                    : wallpaper.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: wallpaper.gradientFallback,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        AmazingIconOutlined.image,
                        color: Colors.white.withOpacity(0.6),
                        size: 32,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: wallpaper.gradientFallback,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top-left Multivariant Badge (if applicable)
            if (wallpaper.isMultivariant)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      AmazingIconFilled.layer,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),

            // Bottom-right Floating Favorite Heart Button
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: LikeHeartButton(
                    isLiked: wallpaper.isLiked,
                    onTap: onLikeToggle,
                    size: 20,
                    likedColor: AppColors.primaryPurple,
                    unlikedColor: AppColors.textDark.withOpacity(0.7),
                    likedIcon: AmazingIconFilled.heart,
                    unlikedIcon: AmazingIconOutlined.heart,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

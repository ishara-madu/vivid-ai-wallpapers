import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'bouncing_wrapper.dart';

/// Unified Gazeo top bar header used consistently across Explore, Collections, and Favorites.
/// Guarantees exact matching height, vertical alignment, and spacing.
class AppTopBar extends StatelessWidget {
  final String title;
  final bool isDark;
  final bool showSearch;
  final bool showSettings;
  final bool isSearching;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onToggleSearch;
  final VoidCallback? onOpenSettings;
  final Widget? trailing;
  final String searchHint;

  const AppTopBar({
    super.key,
    required this.title,
    this.isDark = false,
    this.showSearch = true,
    this.showSettings = true,
    this.isSearching = false,
    this.searchController,
    this.onSearchSubmitted,
    this.onToggleSearch,
    this.onOpenSettings,
    this.trailing,
    this.searchHint = 'Search...',
  });

  /// Convenient helper to embed directly into a CustomScrollView's slivers list
  Widget toSliver() => SliverToBoxAdapter(child: this);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: SizedBox(
        height: 44, // Strict uniform height across all screens
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Title or Search Field
            Expanded(
              child: isSearching
                  ? TextField(
                      controller: searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: onSearchSubmitted,
                    )
                  : Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            // Right: Actions (Trailing badge, Search, Settings)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],

                // Search Icon Button
                if (showSearch) ...[
                  BouncingWrapper(
                    lowerBound: 0.88,
                    onTap: onToggleSearch,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSearching
                              ? AmazingIconOutlined.closeCircle
                              : AmazingIconOutlined.searchNormal,
                          key: ValueKey<bool>(isSearching),
                          size: 22,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Settings Icon Button
                if (showSettings) ...[
                  BouncingWrapper(
                    lowerBound: 0.88,
                    onTap: onOpenSettings,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: Icon(
                        AmazingIconOutlined.setting2,
                        size: 22,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

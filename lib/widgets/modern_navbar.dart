import 'package:flutter/material.dart';
import 'dart:ui';

class ModernNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Widget? leading;
  final double height;
  final bool isTransparent;
  final Widget? flexibleSpace;
  final Widget? bottom;
  final double bottomHeight;

  const ModernNavbar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.leading,
    this.height = kToolbarHeight + 16,
    this.isTransparent = false,
    this.flexibleSpace,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    return Container(
      width: double.infinity,
      height: height, // Explicitly set height to avoid infinite height constraint
      decoration: BoxDecoration(
        color: isTransparent
            ? Colors.transparent
            : backgroundColor ?? theme.colorScheme.primary,
        gradient: isTransparent
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a56db), // Rich blue
                  const Color(0xFF3b82f6), // Lighter blue
                ],
                stops: const [0.0, 1.0],
              ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 3,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
        borderRadius: isTransparent
            ? null
            : BorderRadius.circular(24), // More rounded edges for a modern look
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: height - bottomHeight,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : (isTabletOrDesktop ? 24 : 12),
                vertical: 4,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Leading widget (usually back button)
                      if (leading != null)
                        _buildGlassEffect(
                          child: leading!,
                          context: context,
                          isTransparent: isTransparent,
                        )
                      else
                        SizedBox(width: isTabletOrDesktop ? 16 : 8),

                      // Title - centered on mobile, left-aligned on desktop
                      if (isDesktop)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildGlassEffect(
                            child: _buildTitle(context),
                            context: context,
                            isTransparent: isTransparent,
                          ),
                        )
                      else
                        Expanded(
                          child: Center(
                            child: _buildGlassEffect(
                              child: _buildTitle(context, compact: true),
                              context: context,
                              isTransparent: isTransparent,
                            ),
                          ),
                        ),

                      // Action buttons
                      if (actions != null && actions!.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // If space is very limited, don't use glass effect container
                            if (constraints.maxWidth < 150) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: actions!,
                              );
                            }

                            return _buildGlassEffect(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: actions!,
                                  ),
                                ),
                              ),
                              context: context,
                              isTransparent: isTransparent,
                            );
                          },
                        )
                      else
                        SizedBox(width: isTabletOrDesktop ? 16 : 8),
                    ],
                  );
                },
              ),
            ),

            // Bottom widget (usually tabs)
            if (bottom != null)
              SizedBox(
                width: double.infinity,
                height: bottomHeight,
                child: bottom!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    final textColor = isTransparent || backgroundColor == null
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTabletOrDesktop = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    // Use even more compact layout if specified
    final useCompactLayout = compact || isSmallScreen;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Calendar icon with elegant container
        Container(
          padding: EdgeInsets.all(useCompactLayout ? 3 : (isTabletOrDesktop ? 6 : 4)),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: textColor.withOpacity(0.2),
              width: useCompactLayout ? 0.5 : 1,
            ),
            boxShadow: useCompactLayout ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.calendar_today,
            color: textColor,
            size: useCompactLayout ? 12 : (isTabletOrDesktop ? 16 : 14),
          ),
        ),
        SizedBox(width: useCompactLayout ? 4 : (isTabletOrDesktop ? 10 : 6)),

        // Title text with elegant styling
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title - simplified for compact mode
            Text(
              useCompactLayout ? 'Calendar' : title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: useCompactLayout ? 12 : (isDesktop ? 18 : (isTabletOrDesktop ? 16 : 14)),
                letterSpacing: useCompactLayout ? 0 : 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),

            // Optional subtitle for desktop (not shown in compact mode)
            if (isDesktop && !useCompactLayout)
              Text(
                'Booking System',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassEffect({
    required Widget child,
    required BuildContext context,
    required bool isTransparent,
  }) {
    if (!isTransparent) return child;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTabletOrDesktop = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    // Simplified glass effect for small screens to save space
    if (isSmallScreen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(isTabletOrDesktop ? 16 : 12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : (isTabletOrDesktop ? 12 : 8),
            vertical: isTabletOrDesktop ? 8 : 6
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isTabletOrDesktop ? 16 : 12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class ModernNavbarTheme extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isTransparent;

  const ModernNavbarTheme({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        iconTheme: IconThemeData(
          color: foregroundColor,
        ),
      ),
      child: child,
    );
  }
}

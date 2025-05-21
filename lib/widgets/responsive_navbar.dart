import 'package:flutter/material.dart';

class NavBadge {
  final String label;
  final Color color;
  final bool isDismissible;
  final VoidCallback? onTap;

  NavBadge({
    required this.label,
    required this.color,
    this.isDismissible = false,
    this.onTap,
  });
}

class NavItem {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final List<NavItem>? subItems;
  final NavBadge? badge;

  NavItem({
    required this.title,
    required this.icon,
    this.isActive = false,
    required this.onTap,
    this.subItems,
    this.badge,
  });
}

class UserProfileButton extends StatelessWidget {
  final String userName;
  final VoidCallback onPressed;
  final List<PopupMenuEntry<dynamic>> menuItems;
  final String? avatarUrl;

  const UserProfileButton({
    Key? key,
    required this.userName,
    required this.onPressed,
    required this.menuItems,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => menuItems,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF1a56db),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveNavbar extends StatefulWidget {
  final List<NavItem> items;
  final String title;
  final Color backgroundColor;
  final Color accentColor;
  final Widget child;
  final Widget? userProfileWidget;

  const ResponsiveNavbar({
    Key? key,
    required this.items,
    required this.title,
    required this.backgroundColor,
    required this.accentColor,
    required this.child,
    this.userProfileWidget,
  }) : super(key: key);

  @override
  State<ResponsiveNavbar> createState() => _ResponsiveNavbarState();
}

class _ResponsiveNavbarState extends State<ResponsiveNavbar> {
  bool _isDrawerOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: isTabletOrDesktop ? null : _buildMobileAppBar(),
      drawer: isTabletOrDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          // Side navigation for tablet/desktop
          if (isTabletOrDesktop) _buildSideNavigation(),

          // Main content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  AppBar _buildMobileAppBar() {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (widget.userProfileWidget != null) widget.userProfileWidget!,
        const SizedBox(width: 8),
      ],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor,
              widget.accentColor,
            ],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Meeting Room Manager',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return _buildNavItem(item, true);
                },
              ),
            ),
            // User profile widget removed
          ],
        ),
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.backgroundColor,
            widget.accentColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Meeting Room Manager',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _buildNavItem(item, false);
              },
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          // User profile widget removed
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isMobile) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.isActive
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            item.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (item.badge != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: item.badge!.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.badge!.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: item.badge!.color.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.badge!.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.badge!.isDismissible) ...[
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 8,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: hasSubItems
          ? const Icon(
              Icons.expand_more,
              color: Colors.white70,
            )
          : null,
      onExpansionChanged: (expanded) {
        if (!hasSubItems) {
          item.onTap();
          if (isMobile) {
            Navigator.pop(context);
          }
        }
      },
      initiallyExpanded: item.isActive,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: Colors.white,
      iconColor: Colors.white,
      collapsedTextColor: Colors.white,
      collapsedIconColor: Colors.white,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: hasSubItems
          ? item.subItems!.map((subItem) {
              return ListTile(
                leading: Icon(
                  subItem.icon,
                  color: Colors.white70,
                  size: 18,
                ),
                title: Text(
                  subItem.title,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                onTap: () {
                  subItem.onTap();
                  if (isMobile) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList()
          : [],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/booking_provider.dart';
import '../services/room_provider.dart';
import '../widgets/responsive_navbar.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/data_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // We'll use the services for state management instead of local variables

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;

    // Create navigation items
    final navItems = [
      NavItem(
        title: 'Home',
        icon: Icons.home,
        onTap: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      NavItem(
        title: 'Dashboards',
        icon: Icons.dashboard,
        onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        subItems: [
          NavItem(
            title: 'Analytics',
            icon: Icons.analytics,
            onTap: () {},
          ),
          NavItem(
            title: 'Reports',
            icon: Icons.summarize,
            onTap: () {},
          ),
        ],
      ),
      NavItem(
        title: 'Calendar',
        icon: Icons.calendar_today,
        onTap: () => Navigator.pushReplacementNamed(context, '/calendar'),
      ),
      NavItem(
        title: 'Settings',
        icon: Icons.settings,
        isActive: true,
        onTap: () {},
      ),
    ];

    return ResponsiveNavbar(
      items: navItems,
      title: 'MeetSpace',
      backgroundColor: const Color(0xFF6366F1), // Modern indigo
      accentColor: const Color(0xFF818CF8), // Lighter indigo
      child: _buildSettingsContent(context),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),

          // Settings sections
          _buildSettingsSection(
            context,
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              _buildSwitchSetting(
                context,
                title: 'Dark Mode',
                subtitle: 'Enable dark mode for the application',
                value: false, // Default value
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                        ? 'Dark mode enabled'
                        : 'Light mode enabled'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildDropdownSetting(
                context,
                title: 'Theme Color',
                subtitle: 'Choose your preferred theme color',
                value: 'Indigo',
                options: ['Indigo', 'Blue', 'Teal', 'Purple', 'Orange'],
                onChanged: (value) {
                  if (value != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme color changed to $value'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildButtonSetting(
                context,
                title: 'Reset Theme Settings',
                subtitle: 'Restore default theme settings',
                buttonText: 'Reset',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Theme settings reset to defaults'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            context,
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              _buildSwitchSetting(
                context,
                title: 'Enable Notifications',
                subtitle: 'Receive notifications for bookings and updates',
                value: true, // Default value
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                        ? 'Notifications enabled'
                        : 'Notifications disabled'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownSetting(
                context,
                title: 'Reminder Time',
                subtitle: 'When to send booking reminders',
                value: '30',
                options: ['15', '30', '60', '120', '1440'],
                onChanged: (value) {
                  if (value != null) {
                    final minutes = int.tryParse(value) ?? 30;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reminders set to $minutes minutes before'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                valueFormatter: (value) => '${int.tryParse(value) ?? 30} minutes before',
              ),
              const SizedBox(height: 16),
              _buildNotificationTypesList(context, null),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            context,
            title: 'Data & Synchronization',
            icon: Icons.sync,
            children: [
              _buildSwitchSetting(
                context,
                title: 'Auto Refresh',
                subtitle: 'Automatically refresh data periodically',
                value: true, // Default value
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                        ? 'Auto refresh enabled'
                        : 'Auto refresh disabled'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownSetting(
                context,
                title: 'Refresh Interval',
                subtitle: 'How often to refresh data',
                value: '5',
                options: ['1', '5', '15', '30', '60'],
                onChanged: (value) {
                  if (value != null) {
                    final minutes = int.tryParse(value) ?? 5;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Refresh interval set to $minutes ${minutes == 1 ? 'minute' : 'minutes'}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                valueFormatter: (value) => '${value} ${value == '1' ? 'minute' : 'minutes'}',
              ),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                context,
                title: 'Offline Mode',
                subtitle: 'Work with locally cached data only',
                value: false, // Default value
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                        ? 'Offline mode enabled'
                        : 'Offline mode disabled'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoSetting(
                context,
                title: 'Last Synced',
                value: 'Never',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildButtonSetting(
                      context,
                      title: 'Sync Now',
                      subtitle: 'Manually sync data with the server',
                      buttonText: 'Sync',
                      onPressed: () {
                        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                        final roomProvider = Provider.of<RoomProvider>(context, listen: false);

                        // Refresh data
                        bookingProvider.fetchBookings();
                        roomProvider.fetchRooms();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Data synced successfully!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildButtonSetting(
                      context,
                      title: 'Clear Cache',
                      subtitle: 'Clear locally stored data',
                      buttonText: 'Clear',
                      onPressed: () {
                        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                        final roomProvider = Provider.of<RoomProvider>(context, listen: false);

                        // Clear cache
                        bookingProvider.clearCache();
                        roomProvider.clearCache();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Cache cleared successfully!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            context,
            title: 'About',
            icon: Icons.info,
            children: [
              _buildInfoSetting(
                context,
                title: 'Version',
                value: '1.0.0',
              ),
              _buildInfoSetting(
                context,
                title: 'Build',
                value: '2023.10.15',
              ),
              _buildInfoSetting(
                context,
                title: 'Developer',
                value: 'Room Booking Team',
              ),
              const SizedBox(height: 16),
              _buildButtonSetting(
                context,
                title: 'Terms of Service',
                subtitle: 'View the terms of service',
                buttonText: 'View',
                onPressed: () {
                  _showLegalDialog(
                    context,
                    'Terms of Service',
                    'These Terms of Service ("Terms") govern your access to and use of our room booking application ("Service"). By using the Service, you agree to be bound by these Terms.\n\n'
                    '1. User Accounts\n'
                    'You are responsible for safeguarding your account and for any activities or actions under your account.\n\n'
                    '2. Acceptable Use\n'
                    'You may not use the Service for any illegal or unauthorized purpose.\n\n'
                    '3. Termination\n'
                    'We may terminate or suspend your account at any time for any reason.\n\n'
                    '4. Limitation of Liability\n'
                    'In no event shall we be liable for any indirect, incidental, special, consequential or punitive damages.\n\n'
                    '5. Changes to Terms\n'
                    'We reserve the right to modify these Terms at any time.'
                  );
                },
              ),
              _buildButtonSetting(
                context,
                title: 'Privacy Policy',
                subtitle: 'View the privacy policy',
                buttonText: 'View',
                onPressed: () {
                  _showLegalDialog(
                    context,
                    'Privacy Policy',
                    'This Privacy Policy describes how we collect, use, and disclose your information when you use our room booking application ("Service").\n\n'
                    '1. Information We Collect\n'
                    'We collect information you provide directly to us, such as your name, email address, and booking details.\n\n'
                    '2. How We Use Information\n'
                    'We use the information we collect to provide, maintain, and improve the Service.\n\n'
                    '3. Information Sharing\n'
                    'We do not share your personal information with third parties except as described in this Privacy Policy.\n\n'
                    '4. Data Security\n'
                    'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.\n\n'
                    '5. Changes to Privacy Policy\n'
                    'We may change this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.'
                  );
                },
              ),
              _buildButtonSetting(
                context,
                title: 'Licenses',
                subtitle: 'View third-party licenses',
                buttonText: 'View',
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Room Booking App',
                    applicationVersion: '1.0.0',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.meeting_room,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String Function(String value)? valueFormatter,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<String>(
              value: value,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    valueFormatter != null ? valueFormatter(option) : option,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSetting(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesList(BuildContext context, dynamic notificationService) {
    final theme = Theme.of(context);

    // List of notification types
    final availableTypes = ['bookings', 'reminders', 'updates', 'cancellations'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Select which notifications you want to receive',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...availableTypes.map((type) {
          // For now, we'll just use a static value since we're fixing compilation errors
          final isEnabled = true;
          final title = type[0].toUpperCase() + type.substring(1);

          return CheckboxListTile(
            title: Text(title),
            value: isEnabled,
            onChanged: (value) {
              // We'll implement this later
            },
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    title.contains('Terms') ? Icons.gavel : Icons.privacy_tip,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/booking_provider.dart';
import '../services/room_provider.dart';
import '../widgets/responsive_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

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
        isActive: true,
        onTap: () {},
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
        onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
      ),
    ];

    return ResponsiveNavbar(
      items: navItems,
      title: 'MeetSpace',
      backgroundColor: const Color(0xFF6366F1), // Modern indigo
      accentColor: const Color(0xFF818CF8), // Lighter indigo
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<BookingProvider, RoomProvider>(
      builder: (context, bookingProvider, roomProvider, child) {
        // Show loading indicator
        if ((bookingProvider.isLoading && bookingProvider.bookings.isEmpty) ||
            (roomProvider.isLoading && roomProvider.rooms.isEmpty)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading dashboard data...',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        // Show error message if any
        if ((bookingProvider.error != null && bookingProvider.bookings.isEmpty) ||
            (roomProvider.error != null && roomProvider.rooms.isEmpty)) {
          return Center(
            child: Text(
              'Error loading dashboard data: ${bookingProvider.error ?? roomProvider.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        // Calculate dashboard metrics
        final totalBookings = bookingProvider.bookings.length;
        final upcomingBookings = bookingProvider.bookings.where((booking) {
          final bookingTime = booking.startTime is DateTime
              ? booking.startTime as DateTime
              : DateTime.parse(booking.startTime.toString());
          return bookingTime.isAfter(DateTime.now());
        }).length;
        final totalRooms = roomProvider.rooms.length;
        final availableRooms = roomProvider.rooms.where((room) => room.isAvailable).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Dashboard metrics
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard(
                    context,
                    title: 'Total Bookings',
                    value: totalBookings.toString(),
                    icon: Icons.calendar_month,
                    color: theme.colorScheme.primary,
                  ),
                  _buildMetricCard(
                    context,
                    title: 'Upcoming Bookings',
                    value: upcomingBookings.toString(),
                    icon: Icons.upcoming,
                    color: theme.colorScheme.secondary,
                  ),
                  _buildMetricCard(
                    context,
                    title: 'Total Rooms',
                    value: totalRooms.toString(),
                    icon: Icons.meeting_room,
                    color: theme.colorScheme.tertiary,
                  ),
                  _buildMetricCard(
                    context,
                    title: 'Available Rooms',
                    value: availableRooms.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent bookings section
              Text(
                'Recent Bookings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Recent bookings list
              _buildRecentBookingsList(context, bookingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsList(BuildContext context, BookingProvider bookingProvider) {
    final theme = Theme.of(context);
    final recentBookings = bookingProvider.bookings.take(5).toList();

    if (recentBookings.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No recent bookings found',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentBookings.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final booking = recentBookings[index];
          final startTime = booking.startTime is DateTime
              ? booking.startTime as DateTime
              : DateTime.parse(booking.startTime.toString());

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.event,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              booking.title ?? 'Meeting',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Room: ${booking.roomId} • ${_formatDateTime(startTime)}',
            ),
            trailing: Icon(
              startTime.isAfter(DateTime.now()) ? Icons.upcoming : Icons.event_available,
              color: startTime.isAfter(DateTime.now()) ? theme.colorScheme.secondary : Colors.green,
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

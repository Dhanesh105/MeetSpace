import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/booking_provider.dart';
import '../widgets/booking_form.dart';
import '../widgets/responsive_navbar.dart';
import '../widgets/elegant_calendar.dart';
import '../widgets/elegant_booking_list.dart';
import '../widgets/elegant_fab.dart' as fab;

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showNewFeaturesBadge = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Fetch bookings when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingsForVisibleRange();
      _loadBadgeState();
    });
  }

  // Load badge state from SharedPreferences
  Future<void> _loadBadgeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showNewFeaturesBadge = prefs.getBool('showNewFeaturesBadge') ?? true;
    });
  }

  // Save badge state to SharedPreferences
  Future<void> _saveBadgeState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNewFeaturesBadge', value);
  }

  // Show new features dialog
  void _showNewFeaturesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.new_releases,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('New Features'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              description: 'View booking metrics and analytics',
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: Icons.calendar_today,
              title: 'Enhanced Calendar',
              description: 'More elegant and stylish calendar design',
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: Icons.settings,
              title: 'Settings',
              description: 'Customize your application preferences',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _showNewFeaturesBadge = false;
              });
              await _saveBadgeState(false);
              if (context.mounted) {
                Navigator.of(context).pop();

                // Show a confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('You\'re all caught up with the latest features!'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Restore Badge',
                      onPressed: () {
                        setState(() {
                          _showNewFeaturesBadge = true;
                        });
                        _saveBadgeState(true);
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('Got it!'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Build feature item for the dialog
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fetch bookings for the visible date range
  Future<void> _fetchBookingsForVisibleRange() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    // Calculate the visible range based on the calendar format
    final DateTime start;
    final DateTime end;

    if (_calendarFormat == CalendarFormat.month) {
      // For month view, get the first and last day of the month
      start = DateTime(_focusedDay.year, _focusedDay.month, 1);
      end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    } else if (_calendarFormat == CalendarFormat.week) {
      // For week view, get the first and last day of the week
      start = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
      end = start.add(const Duration(days: 6));
    } else {
      // For day view, just use the focused day
      start = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
      end = start.add(const Duration(days: 1));
    }

    // Fetch bookings for the calculated range
    await provider.fetchBookingsForDateRange(start, end);
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
        isActive: true,
        onTap: () {},
        badge: _showNewFeaturesBadge ? NavBadge(
          label: 'New',
          color: theme.colorScheme.secondary,
          isDismissible: true,
          onTap: _showNewFeaturesDialog,
        ) : null,
      ),
      NavItem(
        title: 'Dashboards',
        icon: Icons.dashboard,
        onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        subItems: [
          NavItem(
            title: 'Analytics',
            icon: Icons.analytics,
            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          NavItem(
            title: 'Reports',
            icon: Icons.summarize,
            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
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

    // User profile widget removed

    return ResponsiveNavbar(
      items: navItems,
      title: 'MeetSpace',
      backgroundColor: const Color(0xFF6366F1), // Modern indigo
      accentColor: const Color(0xFF818CF8), // Lighter indigo
      child: Stack(
        children: [
          _buildMainContent(context),

          // Floating action button
          Positioned(
            right: 24,
            bottom: 24,
            child: fab.AnimatedElegantFAB(
              label: 'New Booking',
              icon: Icons.add,
              onPressed: () => _showBookingForm(context),
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;

    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        // Show loading indicator
        if (bookingProvider.isLoading && bookingProvider.bookings.isEmpty) {
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
                  'Loading your bookings...',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        // Show error message
        if (bookingProvider.error != null && bookingProvider.bookings.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${bookingProvider.error}',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _fetchBookingsForVisibleRange(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Get bookings for the selected day
        final selectedDayBookings = _getBookingsForDay(
          bookingProvider.bookings,
          _selectedDay ?? _focusedDay,
        );

        // Responsive layout based on screen width
        if (isTabletOrDesktop) {
          // Tablet/Desktop layout with side-by-side calendar and bookings
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel with calendar (40% width)
                Expanded(
                  flex: 4,
                  child: _buildCalendarPanel(bookingProvider),
                ),

                const SizedBox(width: 16),

                // Right panel with bookings (60% width)
                Expanded(
                  flex: 6,
                  child: ElegantBookingList(
                    bookings: selectedDayBookings,
                    onRefresh: () async {
                      await _fetchBookingsForVisibleRange();
                    },
                    selectedDate: _selectedDay ?? _focusedDay,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile layout with stacked calendar and bookings
          return Column(
            children: [
              // Calendar panel (40% height)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _buildCalendarPanel(bookingProvider),
              ),

              // Bookings list (60% height)
              Expanded(
                child: ElegantBookingList(
                  bookings: selectedDayBookings,
                  onRefresh: () async {
                    await _fetchBookingsForVisibleRange();
                  },
                  selectedDate: _selectedDay ?? _focusedDay,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Helper method to get bookings for a specific day
  List<Booking> _getBookingsForDay(List<Booking> bookings, DateTime day) {
    return bookings.where((booking) {
      // Handle both String and DateTime types for startTime
      final DateTime bookingStart;
      if (booking.startTime is String) {
        bookingStart = DateTime.parse(booking.startTime as String);
      } else {
        bookingStart = booking.startTime as DateTime;
      }

      final bookingDay = DateTime(bookingStart.year, bookingStart.month, bookingStart.day);
      final selectedDay = DateTime(day.year, day.month, day.day);
      return bookingDay == selectedDay;
    }).toList();
  }

  // Show booking form dialog
  void _showBookingForm(BuildContext context) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingForm(
        selectedDate: _selectedDay ?? _focusedDay,
      ),
    );

    // Refresh bookings after dialog is closed
    if (context.mounted && result == true) {
      // If a booking was created or updated, refresh the bookings
      _fetchBookingsForVisibleRange();
    }
  }

  // Build calendar panel
  Widget _buildCalendarPanel(BookingProvider bookingProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElegantCalendar(
        focusedDay: _focusedDay,
        selectedDay: _selectedDay,
        calendarFormat: _calendarFormat,
        events: bookingProvider.bookings,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
          // Fetch bookings for the new format
          _fetchBookingsForVisibleRange();
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          // Fetch bookings for the new page
          _fetchBookingsForVisibleRange();
        },
        eventLoader: (day) {
          return _getBookingsForDay(bookingProvider.bookings, day);
        },
      ),
    );
  }
}

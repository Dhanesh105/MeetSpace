import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_provider.dart';
import '../widgets/booking_form.dart';
import '../widgets/responsive_navbar.dart';
import '../widgets/elegant_calendar.dart';
import '../widgets/elegant_booking_list.dart';
import '../widgets/elegant_fab.dart' as fab;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Fetch bookings when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingsForVisibleRange();
    });
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
        isActive: true,
        onTap: () {},
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

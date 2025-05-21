import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ElegantCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final CalendarFormat calendarFormat;
  final List<dynamic> events;
  final List<dynamic> Function(DateTime) eventLoader;

  const ElegantCalendar({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.calendarFormat,
    required this.events,
    required this.eventLoader,
  }) : super(key: key);

  @override
  State<ElegantCalendar> createState() => _ElegantCalendarState();
}

class _ElegantCalendarState extends State<ElegantCalendar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isTabletOrDesktop ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                theme.colorScheme.primaryContainer.withOpacity(0.15),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
          child: Column(
            children: [
              _buildCalendarHeader(theme, isTabletOrDesktop),
              _buildCalendar(theme),
            ],
          ),
        ) : BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  theme.colorScheme.primaryContainer.withOpacity(0.15),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
            child: Column(
              children: [
                _buildCalendarHeader(theme, isTabletOrDesktop),
                _buildCalendar(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(ThemeData theme, bool isTabletOrDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTabletOrDesktop ? 24 : 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, theme.colorScheme.secondary, 0.7) ?? theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Month and year display with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Calendar title with icon
              Row(
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
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMMM yyyy').format(widget.focusedDay),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Navigation buttons
              Row(
                children: [
                  _buildNavButton(
                    icon: Icons.chevron_left,
                    onPressed: () => widget.onPageChanged(
                      DateTime(
                        widget.focusedDay.year,
                        widget.focusedDay.month - 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildNavButton(
                    icon: Icons.chevron_right,
                    onPressed: () => widget.onPageChanged(
                      DateTime(
                        widget.focusedDay.year,
                        widget.focusedDay.month + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Format toggle buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormatToggleButton(
                  label: 'Month',
                  isSelected: widget.calendarFormat == CalendarFormat.month,
                  onTap: () => widget.onFormatChanged(CalendarFormat.month),
                ),
                _buildFormatToggleButton(
                  label: 'Week',
                  isSelected: widget.calendarFormat == CalendarFormat.week,
                  onTap: () => widget.onFormatChanged(CalendarFormat.week),
                ),
                _buildFormatToggleButton(
                  label: '2 Weeks',
                  isSelected: widget.calendarFormat == CalendarFormat.twoWeeks,
                  onTap: () => widget.onFormatChanged(CalendarFormat.twoWeeks),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildFormatToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: widget.focusedDay,
      calendarFormat: widget.calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(widget.selectedDay, day);
      },
      onDaySelected: widget.onDaySelected,
      onFormatChanged: widget.onFormatChanged,
      onPageChanged: widget.onPageChanged,
      eventLoader: widget.eventLoader,
      calendarStyle: CalendarStyle(
        // Today decoration
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),

        // Selected day decoration
        selectedDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              Color.lerp(theme.colorScheme.primary, theme.colorScheme.secondary, 0.7) ?? theme.colorScheme.secondary,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        // Default day decoration
        defaultDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),

        // Weekend style
        weekendTextStyle: TextStyle(
          color: theme.colorScheme.tertiary,
        ),

        // Markers style
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markerSize: 5,
        markersAnchor: 0.7,
        markersAlignment: Alignment.bottomCenter,

        // Cell margin for better spacing
        cellMargin: const EdgeInsets.all(6),

        // Rounded cells
        rangeHighlightColor: theme.colorScheme.primaryContainer.withOpacity(0.2),

        // Outside days
        outsideTextStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),

        // Hover color
        holidayTextStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
      ),
      headerVisible: false, // We're using our custom header
      daysOfWeekStyle: DaysOfWeekStyle(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        weekdayStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        weekendStyle: TextStyle(
          color: theme.colorScheme.tertiary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        dowTextFormatter: (date, locale) {
          return DateFormat.E(locale).format(date).toUpperCase().substring(0, 1);
        },
      ),
      daysOfWeekHeight: 36,
    );
  }
}

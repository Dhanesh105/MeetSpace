import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class ElegantBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ElegantBookingCard({
    Key? key,
    required this.booking,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 768;
    
    // Format times
    final startTime = _formatTime(booking.startTime);
    final endTime = _formatTime(booking.endTime);
    final duration = _calculateDuration(booking.startTime, booking.endTime);
    
    // Get initials for avatar
    final initials = _getInitials(booking.userId);
    
    // Determine if booking is today
    final isToday = _isToday(booking.startTime);
    
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                isToday 
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.white,
              ],
              stops: const [0.85, 1.0],
            ),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: InkWell(
            onTap: onEdit,
            splashColor: theme.colorScheme.primary.withOpacity(0.1),
            highlightColor: theme.colorScheme.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User avatar
                      _buildAvatar(initials, theme),
                      
                      const SizedBox(width: 16),
                      
                      // Booking details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User ID as title
                            Text(
                              'Booking by ${booking.userId}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Creation date
                            Text(
                              'Created on ${_formatDate(booking.startTime)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Duration badge
                      _buildDurationBadge(duration, theme),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time information
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInfo(
                          icon: Icons.access_time,
                          label: 'Start Time',
                          time: startTime,
                          theme: theme,
                        ),
                      ),
                      
                      Container(
                        height: 40,
                        width: 1,
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                      
                      Expanded(
                        child: _buildTimeInfo(
                          icon: Icons.access_time_filled,
                          label: 'End Time',
                          time: endTime,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        onPressed: onEdit,
                        isPrimary: true,
                        theme: theme,
                      ),
                      
                      const SizedBox(width: 8),
                      
                      _buildActionButton(
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        onPressed: onDelete,
                        isPrimary: false,
                        theme: theme,
                        isDanger: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatar(String initials, ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDurationBadge(String duration, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            duration,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
    required ThemeData theme,
    bool isDanger = false,
  }) {
    final Color textColor;
    final Color backgroundColor;
    
    if (isDanger) {
      textColor = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.error.withOpacity(0.1);
    } else if (isPrimary) {
      textColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primaryContainer;
    } else {
      textColor = theme.colorScheme.onSurface.withOpacity(0.7);
      backgroundColor = theme.colorScheme.onSurface.withOpacity(0.05);
    }
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatTime(dynamic time) {
    if (time is DateTime) {
      return DateFormat('h:mm a').format(time);
    } else if (time is String) {
      try {
        final dateTime = DateTime.parse(time);
        return DateFormat('h:mm a').format(dateTime);
      } catch (e) {
        return time;
      }
    }
    return 'Unknown';
  }
  
  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return DateFormat('MMM d, yyyy').format(dateTime);
      } catch (e) {
        return date;
      }
    }
    return 'Unknown';
  }
  
  String _calculateDuration(dynamic start, dynamic end) {
    try {
      final DateTime startTime;
      final DateTime endTime;
      
      if (start is DateTime) {
        startTime = start;
      } else {
        startTime = DateTime.parse(start.toString());
      }
      
      if (end is DateTime) {
        endTime = end;
      } else {
        endTime = DateTime.parse(end.toString());
      }
      
      final difference = endTime.difference(startTime);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
      } else {
        return '$minutes min';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  String _getInitials(String userId) {
    if (userId.isEmpty) return '?';
    
    final parts = userId.split('.');
    if (parts.length > 1) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    } else if (userId.length > 1) {
      return userId.substring(0, 2).toUpperCase();
    } else {
      return userId[0].toUpperCase();
    }
  }
  
  bool _isToday(dynamic date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      final DateTime bookingDate;
      if (date is DateTime) {
        bookingDate = date;
      } else {
        bookingDate = DateTime.parse(date.toString());
      }
      
      final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
      return bookingDay == today;
    } catch (e) {
      return false;
    }
  }
}

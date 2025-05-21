import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _reminderTimeKey = 'reminderTime';
  static const String _notificationTypesKey = 'notificationTypes';
  
  bool _notificationsEnabled = true;
  int _reminderTime = 30; // Default: 30 minutes before
  List<String> _notificationTypes = ['bookings', 'reminders', 'updates'];
  
  // Available notification types
  static const List<String> availableNotificationTypes = [
    'bookings',    // New bookings
    'reminders',   // Booking reminders
    'updates',     // App updates
    'cancellations', // Booking cancellations
  ];
  
  // Available reminder times (in minutes)
  static const List<int> availableReminderTimes = [15, 30, 60, 120, 1440]; // 15, 30, 60, 120 mins, 24 hours
  
  NotificationService() {
    _loadPreferences();
  }
  
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderTime => _reminderTime;
  List<String> get notificationTypes => _notificationTypes;
  
  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _reminderTime = prefs.getInt(_reminderTimeKey) ?? 30;
    
    final typesJson = prefs.getString(_notificationTypesKey);
    if (typesJson != null) {
      _notificationTypes = List<String>.from(
        (typesJson.split(','))
      );
    }
    
    notifyListeners();
  }
  
  // Enable or disable notifications
  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
    notifyListeners();
  }
  
  // Set reminder time
  Future<void> setReminderTime(int minutes) async {
    if (_reminderTime == minutes) return;
    
    _reminderTime = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderTimeKey, minutes);
    notifyListeners();
  }
  
  // Toggle a notification type
  Future<void> toggleNotificationType(String type, bool enabled) async {
    if (enabled && !_notificationTypes.contains(type)) {
      _notificationTypes.add(type);
    } else if (!enabled && _notificationTypes.contains(type)) {
      _notificationTypes.remove(type);
    } else {
      return; // No change
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTypesKey, _notificationTypes.join(','));
    notifyListeners();
  }
  
  // Check if a notification type is enabled
  bool isNotificationTypeEnabled(String type) {
    return _notificationTypes.contains(type);
  }
  
  // Reset all notification settings to defaults
  Future<void> resetNotificationSettings() async {
    _notificationsEnabled = true;
    _reminderTime = 30;
    _notificationTypes = ['bookings', 'reminders', 'updates'];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, true);
    await prefs.setInt(_reminderTimeKey, 30);
    await prefs.setString(_notificationTypesKey, _notificationTypes.join(','));
    
    notifyListeners();
  }
  
  // Format reminder time for display
  String formatReminderTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes before';
    } else if (minutes == 60) {
      return '1 hour before';
    } else if (minutes < 1440) {
      return '${minutes ~/ 60} hours before';
    } else {
      return '1 day before';
    }
  }
}

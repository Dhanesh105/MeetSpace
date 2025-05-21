import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_provider.dart';
import 'room_provider.dart';

class DataSyncService extends ChangeNotifier {
  static const String _autoRefreshKey = 'autoRefresh';
  static const String _refreshIntervalKey = 'refreshInterval';
  static const String _lastSyncTimeKey = 'lastSyncTime';
  static const String _offlineModeKey = 'offlineMode';
  
  bool _autoRefresh = true;
  int _refreshInterval = 5; // Default: 5 minutes
  DateTime? _lastSyncTime;
  bool _offlineMode = false;
  bool _isSyncing = false;
  String? _syncError;
  
  // Available refresh intervals (in minutes)
  static const List<int> availableRefreshIntervals = [1, 5, 15, 30, 60];
  
  // Dependencies
  final BookingProvider? bookingProvider;
  final RoomProvider? roomProvider;
  
  DataSyncService({this.bookingProvider, this.roomProvider}) {
    _loadPreferences();
  }
  
  bool get autoRefresh => _autoRefresh;
  int get refreshInterval => _refreshInterval;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get offlineMode => _offlineMode;
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;
  
  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _autoRefresh = prefs.getBool(_autoRefreshKey) ?? true;
    _refreshInterval = prefs.getInt(_refreshIntervalKey) ?? 5;
    _offlineMode = prefs.getBool(_offlineModeKey) ?? false;
    
    final lastSyncTimeStr = prefs.getString(_lastSyncTimeKey);
    if (lastSyncTimeStr != null) {
      _lastSyncTime = DateTime.parse(lastSyncTimeStr);
    }
    
    notifyListeners();
  }
  
  // Enable or disable auto refresh
  Future<void> setAutoRefresh(bool value) async {
    if (_autoRefresh == value) return;
    
    _autoRefresh = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoRefreshKey, value);
    notifyListeners();
  }
  
  // Set refresh interval
  Future<void> setRefreshInterval(int minutes) async {
    if (_refreshInterval == minutes) return;
    
    _refreshInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_refreshIntervalKey, minutes);
    notifyListeners();
  }
  
  // Enable or disable offline mode
  Future<void> setOfflineMode(bool value) async {
    if (_offlineMode == value) return;
    
    _offlineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, value);
    notifyListeners();
  }
  
  // Sync data with the server
  Future<bool> syncData() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _syncError = null;
    notifyListeners();
    
    try {
      // Sync bookings
      if (bookingProvider != null) {
        await bookingProvider!.fetchBookings();
      }
      
      // Sync rooms
      if (roomProvider != null) {
        await roomProvider!.fetchRooms();
      }
      
      // Update last sync time
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncTimeKey, _lastSyncTime!.toIso8601String());
      
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _syncError = e.toString();
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear local cache
  Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear booking cache
      if (bookingProvider != null) {
        bookingProvider!.clearCache();
      }
      
      // Clear room cache
      if (roomProvider != null) {
        roomProvider!.clearCache();
      }
      
      // Clear last sync time
      await prefs.remove(_lastSyncTimeKey);
      _lastSyncTime = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      _syncError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Format last sync time for display
  String getFormattedLastSyncTime() {
    if (_lastSyncTime == null) {
      return 'Never';
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../utils/api_exception.dart';
import 'mongodb_service.dart';

class MongoDBProvider with ChangeNotifier {
  final MongoDBService _mongoDBService = MongoDBService();
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  // Constructor
  MongoDBProvider() {
    // Check if we're running on web
    if (_isWebPlatform()) {
      print('Running in web environment, MongoDB connection is not supported');
      _isConnected = false;
      _setError('MongoDB connection is not supported in web environment');
    } else {
      try {
        _initializeConnection();
      } catch (e) {
        print('MongoDB initialization failed: $e');
        _isConnected = false;
        _setError('MongoDB connection failed: $e');
      }
    }
  }

  // Helper method to detect web platform
  bool _isWebPlatform() {
    try {
      // This will throw an error on web platforms
      return identical(0, 0.0);
    } catch (_) {
      return false;
    }
  }

  // Initialize MongoDB connection
  Future<void> _initializeConnection() async {
    _setLoading(true);
    _clearError();

    try {
      await _mongoDBService.connect();
      _isConnected = await _mongoDBService.checkConnection();
      notifyListeners();
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      _isConnected = false;
    } finally {
      _setLoading(false);
    }
  }

  // Reconnect to MongoDB
  Future<void> reconnect() async {
    _setLoading(true);
    _clearError();

    try {
      await _mongoDBService.close();
      await _mongoDBService.connect();
      _isConnected = await _mongoDBService.checkConnection();
      notifyListeners();
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      _isConnected = false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking
  Future<Booking> createBooking(Booking booking) async {
    _setLoading(true);
    _clearError();

    try {
      final newBooking = await _mongoDBService.createBooking(booking);
      notifyListeners();
      return newBooking;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get all bookings
  Future<List<Booking>> getAllBookings() async {
    _setLoading(true);
    _clearError();

    try {
      final bookings = await _mongoDBService.getAllBookings();
      notifyListeners();
      return bookings;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get bookings for a specific date range
  Future<List<Booking>> getBookingsForDateRange(DateTime start, DateTime end) async {
    _setLoading(true);
    _clearError();

    try {
      final bookings = await _mongoDBService.getBookingsForDateRange(start, end);
      notifyListeners();
      return bookings;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Update a booking
  Future<Booking> updateBooking(String id, Booking booking) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedBooking = await _mongoDBService.updateBooking(id, booking);
      notifyListeners();
      return updatedBooking;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _mongoDBService.deleteBooking(id);
      notifyListeners();
      return success;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new room
  Future<Room> createRoom(Room room) async {
    _setLoading(true);
    _clearError();

    try {
      final newRoom = await _mongoDBService.createRoom(room);
      notifyListeners();
      return newRoom;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get all rooms
  Future<List<Room>> getAllRooms() async {
    _setLoading(true);
    _clearError();

    try {
      final rooms = await _mongoDBService.getAllRooms();
      notifyListeners();
      return rooms;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../services/service_provider.dart';
import '../services/room_provider.dart';
import '../utils/api_exception.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all bookings
  Future<List<Booking>> fetchBookings() async {
    _setLoading(true);
    _clearError();

    try {
      _bookings = await ServiceProvider.getBookings();
      notifyListeners();
      return _bookings;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Fetch bookings for a specific date range
  Future<List<Booking>> fetchBookingsForDateRange(DateTime start, DateTime end) async {
    _setLoading(true);
    _clearError();

    try {
      final bookings = await ServiceProvider.getBookingsForDateRange(start, end);
      _bookings = bookings;
      notifyListeners();
      return bookings;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking
  Future<bool> createBooking(Booking booking, RoomProvider roomProvider) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate booking data
      if (booking.userId.isEmpty) {
        throw ApiException('User ID cannot be empty');
      }

      if (booking.roomId.isEmpty) {
        throw ApiException('Room must be selected');
      }

      if (booking.startTime == null) {
        throw ApiException('Start time must be specified');
      }

      if (booking.endTime == null) {
        throw ApiException('End time must be specified');
      }

      // Check if end time is after start time
      if (booking.startTime is DateTime && booking.endTime is DateTime) {
        final DateTime startTime = booking.startTime as DateTime;
        final DateTime endTime = booking.endTime as DateTime;

        if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
          throw ApiException('End time must be after start time');
        }

        // Check if booking is in the past
        final now = DateTime.now();
        if (startTime.isBefore(now)) {
          throw ApiException('Cannot book a room in the past');
        }

        // Check if booking duration is reasonable (e.g., not more than 8 hours)
        final duration = endTime.difference(startTime).inHours;
        if (duration > 8) {
          throw ApiException('Booking duration cannot exceed 8 hours');
        }
      }

      // Validate room capacity if attendees are specified
      if (booking.attendees != null && booking.attendees! > 0) {
        final room = roomProvider.getRoomById(booking.roomId);
        if (room != null && booking.attendees! > room.capacity) {
          throw ApiException('The selected room cannot accommodate ${booking.attendees} people (capacity: ${room.capacity})');
        }
      }

      // Check room availability
      if (booking.startTime is DateTime && booking.endTime is DateTime) {
        final isAvailable = await roomProvider.isRoomAvailable(
          booking.roomId,
          booking.startTime as DateTime,
          booking.endTime as DateTime,
        );

        if (!isAvailable) {
          throw ApiException('The selected room is not available for the specified time');
        }
      }

      // Create booking in the backend
      final newBooking = await ServiceProvider.createBooking(booking);

      // Add to local state and notify listeners
      _bookings.add(newBooking);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing booking
  Future<bool> updateBooking(String id, Booking booking, RoomProvider roomProvider) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate booking data
      if (booking.userId.isEmpty) {
        throw ApiException('User ID cannot be empty');
      }

      if (booking.roomId.isEmpty) {
        throw ApiException('Room must be selected');
      }

      if (booking.startTime == null) {
        throw ApiException('Start time must be specified');
      }

      if (booking.endTime == null) {
        throw ApiException('End time must be specified');
      }

      // Check if end time is after start time
      if (booking.startTime is DateTime && booking.endTime is DateTime) {
        final DateTime startTime = booking.startTime as DateTime;
        final DateTime endTime = booking.endTime as DateTime;

        if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
          throw ApiException('End time must be after start time');
        }

        // Check if booking is in the past
        final now = DateTime.now();
        if (startTime.isBefore(now)) {
          // Allow editing past bookings only if the start time hasn't changed
          final existingBooking = _bookings.firstWhere((b) => b.id == id);
          final existingStartTime = existingBooking.startTime is DateTime
              ? existingBooking.startTime as DateTime
              : DateTime.parse(existingBooking.startTime.toString());

          if (startTime != existingStartTime) {
            throw ApiException('Cannot change the start time of a past booking');
          }
        }

        // Check if booking duration is reasonable (e.g., not more than 8 hours)
        final duration = endTime.difference(startTime).inHours;
        if (duration > 8) {
          throw ApiException('Booking duration cannot exceed 8 hours');
        }
      }

      // Validate room capacity if attendees are specified
      if (booking.attendees != null && booking.attendees! > 0) {
        final room = roomProvider.getRoomById(booking.roomId);
        if (room != null && booking.attendees! > room.capacity) {
          throw ApiException('The selected room cannot accommodate ${booking.attendees} people (capacity: ${room.capacity})');
        }
      }

      // Check room availability (excluding this booking)
      if (booking.startTime is DateTime && booking.endTime is DateTime) {
        final isAvailable = await roomProvider.isRoomAvailable(
          booking.roomId,
          booking.startTime as DateTime,
          booking.endTime as DateTime,
          excludeBookingId: id,
        );

        if (!isAvailable) {
          throw ApiException('The selected room is not available for the specified time');
        }
      }

      // Update booking in the backend
      final updatedBooking = await ServiceProvider.updateBooking(id, booking);

      // Update local state and notify listeners
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = updatedBooking;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await ServiceProvider.deleteBooking(id);
      if (success) {
        _bookings.removeWhere((booking) => booking.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return false;
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

  // Clear local booking cache
  void clearCache() {
    _bookings = [];
    _error = null;
    notifyListeners();
  }
}

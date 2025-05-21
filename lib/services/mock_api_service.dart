import 'dart:math';
import '../models/booking.dart';
import '../utils/api_exception.dart';

/// A mock implementation of the API service for testing and development
class MockApiService {
  // In-memory storage for bookings
  final List<Booking> _bookings = [];

  // Flag to simulate loading state
  bool _isLoading = false;

  // Flag to simulate error state
  bool _shouldThrowError = false;

  // Constructor with optional sample data
  MockApiService({bool generateSampleData = true}) {
    if (generateSampleData) {
      _generateSampleBookings();
    }
  }

  // Set loading state for testing
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
  }

  // Set error state for testing
  void setShouldThrowError(bool shouldThrowError) {
    _shouldThrowError = shouldThrowError;
  }

  // GET all bookings
  Future<List<Booking>> getBookings() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate loading state
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 3));
    }

    // Simulate error
    if (_shouldThrowError) {
      throw ApiException('Failed to fetch bookings: Network error');
    }

    return _bookings;
  }

  // GET booking by ID
  Future<Booking> getBookingById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate loading state
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Simulate error
    if (_shouldThrowError) {
      throw ApiException('Failed to fetch booking: Booking not found');
    }

    final booking = _bookings.firstWhere(
      (booking) => booking.id == id,
      orElse: () => throw ApiException('Booking not found', statusCode: 404),
    );

    return booking;
  }

  // POST create new booking
  Future<Booking> createBooking(Booking booking) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulate loading state
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Simulate error
    if (_shouldThrowError) {
      throw ApiException('Failed to create booking: Invalid data');
    }

    // Validate room ID
    if (booking.roomId.isEmpty) {
      throw ApiException('Room ID is required', statusCode: 400);
    }

    // Check for overlapping bookings for the same room
    final hasOverlap = _checkOverlap(booking.roomId, booking.startTime, booking.endTime);
    if (hasOverlap) {
      throw ApiException('Room is already booked for this time period', statusCode: 409);
    }

    // Check if booking is in the past
    if (booking.startTime is DateTime) {
      final now = DateTime.now();
      if ((booking.startTime as DateTime).isBefore(now)) {
        throw ApiException('Cannot book a room in the past', statusCode: 400);
      }
    }

    // Create a new booking with ID and timestamp
    final newBooking = Booking(
      id: _generateId(),
      userId: booking.userId,
      roomId: booking.roomId,
      startTime: booking.startTime,
      endTime: booking.endTime,
      createdAt: DateTime.now().toIso8601String(),
      notes: booking.notes,
      attendees: booking.attendees,
      status: 'confirmed',
    );

    _bookings.add(newBooking);
    return newBooking;
  }

  // PUT update booking
  Future<Booking> updateBooking(String id, Booking booking) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate loading state
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Simulate error
    if (_shouldThrowError) {
      throw ApiException('Failed to update booking: Server error');
    }

    // Find the booking
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) {
      throw ApiException('Booking not found', statusCode: 404);
    }

    // Check for overlapping bookings (excluding this booking)
    final hasOverlap = _checkOverlap(
      booking.roomId,
      booking.startTime,
      booking.endTime,
      excludeId: id,
    );
    if (hasOverlap) {
      throw ApiException('Room is already booked for this time period', statusCode: 409);
    }

    // Update the booking
    final updatedBooking = Booking(
      id: id,
      userId: booking.userId,
      roomId: booking.roomId,
      startTime: booking.startTime,
      endTime: booking.endTime,
      createdAt: _bookings[index].createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      notes: booking.notes,
      attendees: booking.attendees,
      status: booking.status ?? _bookings[index].status,
    );

    _bookings[index] = updatedBooking;
    return updatedBooking;
  }

  // DELETE booking
  Future<bool> deleteBooking(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate loading state
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // Simulate error
    if (_shouldThrowError) {
      throw ApiException('Failed to delete booking: Server error');
    }

    // Find and remove the booking
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) {
      throw ApiException('Booking not found', statusCode: 404);
    }

    _bookings.removeAt(index);
    return true;
  }

  // Generate a random ID
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result = StringBuffer();

    for (var i = 0; i < 8; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }

  // Check for overlapping bookings for the same room
  bool _checkOverlap(String roomId, dynamic startTime, dynamic endTime, {String? excludeId}) {
    // Convert to DateTime if needed
    final DateTime start;
    final DateTime end;

    if (startTime is DateTime) {
      start = startTime;
    } else {
      try {
        start = DateTime.parse(startTime.toString());
      } catch (e) {
        throw ApiException('Invalid start time format', statusCode: 400);
      }
    }

    if (endTime is DateTime) {
      end = endTime;
    } else {
      try {
        end = DateTime.parse(endTime.toString());
      } catch (e) {
        throw ApiException('Invalid end time format', statusCode: 400);
      }
    }

    return _bookings.any((booking) {
      // Skip the booking being updated
      if (excludeId != null && booking.id == excludeId) {
        return false;
      }

      // Only check bookings for the same room
      if (booking.roomId != roomId) {
        return false;
      }

      // Get booking times as DateTime
      final DateTime bookingStart;
      final DateTime bookingEnd;

      if (booking.startTime is DateTime) {
        bookingStart = booking.startTime as DateTime;
      } else {
        bookingStart = DateTime.parse(booking.startTime.toString());
      }

      if (booking.endTime is DateTime) {
        bookingEnd = booking.endTime as DateTime;
      } else {
        bookingEnd = DateTime.parse(booking.endTime.toString());
      }

      // Check for overlap
      return (start.isBefore(bookingEnd) && end.isAfter(bookingStart));
    });
  }

  // Generate sample bookings for testing
  void _generateSampleBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Sample users
    final users = ['user123', 'john.doe', 'alice.smith', 'bob.jones'];

    // Create bookings for today
    _bookings.add(Booking(
      id: 'sample1',
      userId: users[0],
      roomId: 'room1',
      startTime: DateTime(today.year, today.month, today.day, 9, 0),
      endTime: DateTime(today.year, today.month, today.day, 10, 30),
      createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      attendees: 8,
      notes: 'Weekly team meeting',
      status: 'confirmed',
    ));

    _bookings.add(Booking(
      id: 'sample2',
      userId: users[1],
      roomId: 'room2',
      startTime: DateTime(today.year, today.month, today.day, 13, 0),
      endTime: DateTime(today.year, today.month, today.day, 14, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      attendees: 4,
      notes: 'Project planning',
      status: 'confirmed',
    ));

    // Create bookings for tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    _bookings.add(Booking(
      id: 'sample3',
      userId: users[2],
      roomId: 'room3',
      startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
      endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      attendees: 15,
      notes: 'Board meeting',
      status: 'confirmed',
    ));

    // Create bookings for yesterday
    final yesterday = today.subtract(const Duration(days: 1));
    _bookings.add(Booking(
      id: 'sample4',
      userId: users[3],
      roomId: 'room4',
      startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 15, 0),
      endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 30),
      createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      attendees: 3,
      notes: 'Client call',
      status: 'completed',
    ));
  }
}

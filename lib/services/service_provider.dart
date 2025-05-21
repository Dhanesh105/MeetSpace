import '../models/booking.dart';
import '../models/room.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'mongodb_service.dart';

/// A service provider that can switch between real and mock API services
class ServiceProvider {
  // Flags to determine which service to use
  static bool useMockApi = false; // Use real API by default
  // Disable MongoDB by default since it won't work in web mode
  static bool useMongoDb = false;

  // Singleton instances
  static final ApiService _apiService = ApiService();
  static final MockApiService _mockApiService = MockApiService();
  static final MongoDBService _mongoDBService = MongoDBService();

  // Get all bookings
  static Future<List<Booking>> getBookings() async {
    // Check if we're in a web environment - MongoDB won't work in web
    bool isWeb = _isWebPlatform();

    if (useMongoDb && !isWeb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.getAllBookings();
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to mock or API if MongoDB fails
        if (useMockApi) {
          return _mockApiService.getBookings();
        } else {
          return _apiService.getBookings();
        }
      }
    } else if (useMockApi) {
      return _mockApiService.getBookings();
    } else {
      return _apiService.getBookings();
    }
  }

  // Get booking by ID
  static Future<Booking> getBookingById(String id) async {
    if (useMongoDb) {
      try {
        await _mongoDBService.connect();
        final bookings = await _mongoDBService.getAllBookings();
        final booking = bookings.firstWhere((b) => b.id == id);
        return booking;
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to mock or API if MongoDB fails
        if (useMockApi) {
          return _mockApiService.getBookingById(id);
        } else {
          return _apiService.getBookingById(id);
        }
      }
    } else if (useMockApi) {
      return _mockApiService.getBookingById(id);
    } else {
      return _apiService.getBookingById(id);
    }
  }

  // Get bookings for date range
  static Future<List<Booking>> getBookingsForDateRange(DateTime start, DateTime end) async {
    // Check if we're in a web environment - MongoDB won't work in web
    bool isWeb = _isWebPlatform();

    if (useMongoDb && !isWeb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.getBookingsForDateRange(start, end);
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to API or mock
        if (useMockApi) {
          return _filterBookingsByDateRange(await _mockApiService.getBookings(), start, end);
        } else {
          return await _apiService.getBookingsForDateRange(start, end);
        }
      }
    } else if (useMockApi) {
      // Fall back to filtering all bookings from mock API
      return _filterBookingsByDateRange(await _mockApiService.getBookings(), start, end);
    } else {
      // Use the real API service with date range support
      return await _apiService.getBookingsForDateRange(start, end);
    }
  }

  // Helper method to filter bookings by date range
  static List<Booking> _filterBookingsByDateRange(List<Booking> bookings, DateTime start, DateTime end) {
    return bookings.where((booking) {
      final bookingStart = booking.startTime is DateTime
          ? booking.startTime as DateTime
          : DateTime.parse(booking.startTime.toString());
      final bookingEnd = booking.endTime is DateTime
          ? booking.endTime as DateTime
          : DateTime.parse(booking.endTime.toString());

      return (bookingStart.isAfter(start) && bookingStart.isBefore(end)) ||
             (bookingEnd.isAfter(start) && bookingEnd.isBefore(end)) ||
             (bookingStart.isBefore(start) && bookingEnd.isAfter(end));
    }).toList();
  }

  // Helper method to detect web platform
  static bool _isWebPlatform() {
    try {
      return identical(0, 0.0);
    } catch (_) {
      return true;
    }
  }

  // Create a new booking
  static Future<Booking> createBooking(Booking booking) async {
    // Check if we're in a web environment - MongoDB won't work in web
    bool isWeb = _isWebPlatform();

    if (useMongoDb && !isWeb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.createBooking(booking);
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to mock or API if MongoDB fails
        if (useMockApi) {
          return _mockApiService.createBooking(booking);
        } else {
          return _apiService.createBooking(booking);
        }
      }
    } else if (useMockApi) {
      return _mockApiService.createBooking(booking);
    } else {
      return _apiService.createBooking(booking);
    }
  }

  // Update a booking
  static Future<Booking> updateBooking(String id, Booking booking) async {
    if (useMongoDb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.updateBooking(id, booking);
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to mock or API if MongoDB fails
        if (useMockApi) {
          return _mockApiService.updateBooking(id, booking);
        } else {
          return _apiService.updateBooking(id, booking);
        }
      }
    } else if (useMockApi) {
      return _mockApiService.updateBooking(id, booking);
    } else {
      return _apiService.updateBooking(id, booking);
    }
  }

  // Delete a booking
  static Future<bool> deleteBooking(String id) async {
    if (useMongoDb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.deleteBooking(id);
      } catch (e) {
        print('MongoDB error: $e, falling back to mock/API');
        // Fall back to mock or API if MongoDB fails
        if (useMockApi) {
          return _mockApiService.deleteBooking(id);
        } else {
          return _apiService.deleteBooking(id);
        }
      }
    } else if (useMockApi) {
      return _mockApiService.deleteBooking(id);
    } else {
      return _apiService.deleteBooking(id);
    }
  }

  // Get all rooms
  static Future<List<Room>> getRooms() async {
    if (useMongoDb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.getAllRooms();
      } catch (e) {
        print('MongoDB error: $e, falling back to mock data');
        // Fall back to mock data
        return _generateSampleRooms();
      }
    } else {
      // Return sample rooms for now
      return _generateSampleRooms();
    }
  }

  // Create a new room
  static Future<Room> createRoom(Room room) async {
    if (useMongoDb) {
      try {
        await _mongoDBService.connect();
        return await _mongoDBService.createRoom(room);
      } catch (e) {
        print('MongoDB error: $e, falling back to mock data');
        // We don't have a mock implementation for this yet
        throw Exception('Failed to create room: $e');
      }
    } else {
      // We don't have a mock implementation for this yet
      throw Exception('Room creation not implemented in mock mode');
    }
  }

  // Toggle between real and mock API
  static void toggleMockApi(bool useMock) {
    useMockApi = useMock;
  }

  // Toggle MongoDB usage
  static void toggleMongoDb(bool useMongo) {
    useMongoDb = useMongo;
  }

  // Set loading state for mock API (for testing)
  static void setMockLoading(bool isLoading) {
    _mockApiService.setLoading(isLoading);
  }

  // Set error state for mock API (for testing)
  static void setMockShouldThrowError(bool shouldThrowError) {
    _mockApiService.setShouldThrowError(shouldThrowError);
  }

  // Generate sample rooms
  static List<Room> _generateSampleRooms() {
    return [
      Room(
        id: 'room1',
        name: 'Conference Room A',
        capacity: 12,
        features: ['Projector', 'Whiteboard', 'Video conferencing'],
        location: 'Floor 1, East Wing',
        imageUrl: 'https://example.com/room-a.jpg',
      ),
      Room(
        id: 'room2',
        name: 'Meeting Room B',
        capacity: 6,
        features: ['TV Screen', 'Whiteboard'],
        location: 'Floor 2, West Wing',
        imageUrl: 'https://example.com/room-b.jpg',
      ),
      Room(
        id: 'room3',
        name: 'Board Room',
        capacity: 20,
        features: ['Projector', 'Video conferencing', 'Catering service'],
        location: 'Floor 3, North Wing',
        imageUrl: 'https://example.com/board-room.jpg',
      ),
      Room(
        id: 'room4',
        name: 'Huddle Space',
        capacity: 4,
        features: ['Whiteboard'],
        location: 'Floor 1, South Wing',
        imageUrl: 'https://example.com/huddle.jpg',
      ),
      Room(
        id: 'room5',
        name: 'Training Room',
        capacity: 30,
        features: ['Projector', 'Whiteboard', 'Video conferencing', 'Computers'],
        location: 'Floor 2, East Wing',
        imageUrl: 'https://example.com/training.jpg',
      ),
    ];
  }
}

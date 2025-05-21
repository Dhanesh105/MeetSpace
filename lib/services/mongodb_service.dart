import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../utils/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  factory MongoDBService() => _instance;
  MongoDBService._internal();

  Db? _db;
  bool _isConnected = false;
  final String _connectionString = 'mongodb://localhost:27017/booking_app';

  // Collections
  DbCollection? _bookingsCollection;
  DbCollection? _roomsCollection;

  // Getters
  bool get isConnected => _isConnected;

  // Initialize the database connection
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Check if we're running in a web environment
      bool isWeb;
      try {
        isWeb = identical(0, 0.0);
      } catch (_) {
        isWeb = true;
      }

      if (isWeb) {
        print('Running in web environment, MongoDB connection is not supported');
        _isConnected = false;
        throw ApiException('MongoDB connection is not supported in web environment');
      }

      _db = await Db.create(_connectionString);
      await _db!.open();
      _isConnected = true;

      // Initialize collections
      _bookingsCollection = _db!.collection('bookings');
      _roomsCollection = _db!.collection('rooms');

      // Create indexes for faster queries
      await _bookingsCollection!.createIndex(keys: {
        'startTime': 1,
        'endTime': 1,
        'roomId': 1
      });

      await _roomsCollection!.createIndex(keys: {
        'id': 1
      });

      print('Connected to MongoDB successfully');

      // Save connection status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mongodb_connected', true);

    } catch (e) {
      print('Failed to connect to MongoDB: $e');
      _isConnected = false;

      // Save connection status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mongodb_connected', false);

      throw ApiException('Failed to connect to MongoDB: $e');
    }
  }

  // Close the database connection
  Future<void> close() async {
    if (_db != null && _isConnected) {
      await _db!.close();
      _isConnected = false;
      print('Disconnected from MongoDB');
    }
  }

  // Check if the connection is active
  Future<bool> checkConnection() async {
    if (_db == null) return false;

    try {
      // Ping the database to check connection
      await _db!.serverStatus();
      return true;
    } catch (e) {
      print('MongoDB connection check failed: $e');
      return false;
    }
  }

  // BOOKINGS OPERATIONS

  // Create a new booking
  Future<Booking> createBooking(Booking booking) async {
    await _ensureConnected();

    try {
      // Convert booking to a map
      final bookingMap = booking.toJson();

      // Add created timestamp if not present
      if (bookingMap['createdAt'] == null) {
        bookingMap['createdAt'] = DateTime.now().toUtc().toIso8601String();
      }

      // Generate an ID if not present
      if (bookingMap['id'] == null) {
        bookingMap['id'] = ObjectId().toHexString();
      }

      // Insert the booking
      await _bookingsCollection!.insert(bookingMap);

      // Return the created booking
      return Booking.fromJson(bookingMap);
    } catch (e) {
      print('Failed to create booking: $e');
      throw ApiException('Failed to create booking: $e');
    }
  }

  // Get all bookings
  Future<List<Booking>> getAllBookings() async {
    await _ensureConnected();

    try {
      final bookings = await _bookingsCollection!.find().toList();
      return bookings.map((doc) => Booking.fromJson(doc)).toList();
    } catch (e) {
      print('Failed to get bookings: $e');
      throw ApiException('Failed to get bookings: $e');
    }
  }

  // Get bookings for a specific date range
  Future<List<Booking>> getBookingsForDateRange(DateTime start, DateTime end) async {
    await _ensureConnected();

    try {
      final startStr = start.toUtc().toIso8601String();
      final endStr = end.toUtc().toIso8601String();

      // Create query for bookings that overlap with the date range
      final query = {
        '\$or': [
          {
            // Case 1: Booking starts within the range
            'startTime': {
              '\$gte': startStr,
              '\$lte': endStr
            }
          },
          {
            // Case 2: Booking ends within the range
            'endTime': {
              '\$gte': startStr,
              '\$lte': endStr
            }
          },
          {
            // Case 3: Booking spans the entire range
            'startTime': { '\$lte': startStr },
            'endTime': { '\$gte': endStr }
          }
        ]
      };

      final bookings = await _bookingsCollection!.find(query).toList();
      return bookings.map((doc) => Booking.fromJson(doc)).toList();
    } catch (e) {
      print('Failed to get bookings for date range: $e');
      throw ApiException('Failed to get bookings for date range: $e');
    }
  }

  // Update a booking
  Future<Booking> updateBooking(String id, Booking booking) async {
    await _ensureConnected();

    try {
      // Convert booking to a map
      final bookingMap = booking.toJson();

      // Add updated timestamp
      bookingMap['updatedAt'] = DateTime.now().toUtc().toIso8601String();

      // Update the booking
      await _bookingsCollection!.update(
        where.eq('id', id),
        {'\$set': bookingMap}
      );

      // Get the updated booking
      final updatedDoc = await _bookingsCollection!.findOne(where.eq('id', id));
      if (updatedDoc == null) {
        throw ApiException('Booking not found', statusCode: 404);
      }

      return Booking.fromJson(updatedDoc);
    } catch (e) {
      print('Failed to update booking: $e');
      throw ApiException('Failed to update booking: $e');
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(String id) async {
    await _ensureConnected();

    try {
      final result = await _bookingsCollection!.remove(where.eq('id', id));
      return result['n'] > 0;
    } catch (e) {
      print('Failed to delete booking: $e');
      throw ApiException('Failed to delete booking: $e');
    }
  }

  // ROOMS OPERATIONS

  // Create a new room
  Future<Room> createRoom(Room room) async {
    await _ensureConnected();

    try {
      // Convert room to a map
      final roomMap = room.toJson();

      // Insert the room
      await _roomsCollection!.insert(roomMap);

      // Return the created room
      return Room.fromJson(roomMap);
    } catch (e) {
      print('Failed to create room: $e');
      throw ApiException('Failed to create room: $e');
    }
  }

  // Get all rooms
  Future<List<Room>> getAllRooms() async {
    await _ensureConnected();

    try {
      final rooms = await _roomsCollection!.find().toList();
      return rooms.map((doc) => Room.fromJson(doc)).toList();
    } catch (e) {
      print('Failed to get rooms: $e');
      throw ApiException('Failed to get rooms: $e');
    }
  }

  // Helper method to ensure connection
  Future<void> _ensureConnected() async {
    if (!_isConnected) {
      await connect();
    }

    final isConnected = await checkConnection();
    if (!isConnected) {
      await connect();
    }
  }
}

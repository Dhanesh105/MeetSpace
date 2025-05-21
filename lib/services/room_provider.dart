import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../utils/api_exception.dart';
import 'dart:math';
import 'service_provider.dart';

class RoomProvider with ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor with sample data
  RoomProvider() {
    fetchRooms();
  }

  // Fetch all rooms
  Future<void> fetchRooms() async {
    _setLoading(true);
    _clearError();

    try {
      // Get rooms from the service provider
      final fetchedRooms = await ServiceProvider.getRooms();
      _rooms = fetchedRooms;
      notifyListeners();
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      // Fall back to sample data if there's an error
      _generateSampleRooms();
    } finally {
      _setLoading(false);
    }
  }

  // Check if a room is available for a specific time interval
  Future<bool> isRoomAvailable(String roomId, DateTime startTime, DateTime endTime, {String? excludeBookingId}) async {
    _setLoading(true);
    _clearError();

    try {
      // In a real app, this would be an API call
      // For now, we'll simulate a check
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the room
      final room = _rooms.firstWhere(
        (room) => room.id == roomId,
        orElse: () => throw ApiException('Room not found', statusCode: 404),
      );

      // Check if the room is generally available
      if (!room.isAvailable) {
        _setError('This room is currently unavailable for booking');
        return false;
      }

      // In a real app, we would check against existing bookings
      // For now, we'll randomly determine availability
      final random = Random();
      final isAvailable = random.nextDouble() > 0.2; // 80% chance of being available

      if (!isAvailable) {
        _setError('This room is already booked for the selected time');
      }

      return isAvailable;
    } catch (e) {
      _setError(e is ApiException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get a room by ID
  Room? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
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

  // Clear local room cache
  void clearCache() {
    _rooms = [];
    _error = null;
    notifyListeners();
  }

  // Generate sample rooms for testing
  void _generateSampleRooms() {
    _rooms = [
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

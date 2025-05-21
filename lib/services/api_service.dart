import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../utils/api_exception.dart';

class ApiService {
  // Base URL for the API - change this to match your backend URL
  static const String baseUrl = 'https://meet-space-backend-1.vercel.app';

  // Local development URL (uncomment for local testing)
  // static const String baseUrl = 'http://localhost:4322';

  // Headers for API requests
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET all bookings
  Future<List<Booking>> getBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings'),
        headers: _headers,
      );

      return _processResponse<List<Booking>>(
        response,
        (data) => (data['data'] as List)
            .map((json) => Booking.fromJson(json))
            .toList(),
      );
    } catch (e) {
      throw ApiException('Failed to fetch bookings: ${e.toString()}');
    }
  }

  // GET booking by ID
  Future<Booking> getBookingById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/$id'),
        headers: _headers,
      );

      return _processResponse<Booking>(
        response,
        (data) => Booking.fromJson(data['data']),
      );
    } catch (e) {
      throw ApiException('Failed to fetch booking: ${e.toString()}');
    }
  }

  // POST create new booking
  Future<Booking> createBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: _headers,
        body: jsonEncode(booking.toJson()),
      );

      return _processResponse<Booking>(
        response,
        (data) => Booking.fromJson(data['data']),
      );
    } catch (e) {
      throw ApiException('Failed to create booking: ${e.toString()}');
    }
  }

  // PUT update booking
  Future<Booking> updateBooking(String id, Booking booking) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/bookings/$id'),
        headers: _headers,
        body: jsonEncode(booking.toJson()),
      );

      return _processResponse<Booking>(
        response,
        (data) => Booking.fromJson(data['data']),
      );
    } catch (e) {
      throw ApiException('Failed to update booking: ${e.toString()}');
    }
  }

  // DELETE booking
  Future<bool> deleteBooking(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/bookings/$id'),
        headers: _headers,
      );

      return _processResponse<bool>(
        response,
        (data) => data['success'] == true,
      );
    } catch (e) {
      throw ApiException('Failed to delete booking: ${e.toString()}');
    }
  }

  // GET bookings for a specific date range
  Future<List<Booking>> getBookingsForDateRange(DateTime start, DateTime end) async {
    try {
      final startStr = start.toUtc().toIso8601String();
      final endStr = end.toUtc().toIso8601String();

      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings?startTime=$startStr&endTime=$endStr'),
        headers: _headers,
      );

      return _processResponse<List<Booking>>(
        response,
        (data) => (data['data'] as List)
            .map((json) => Booking.fromJson(json))
            .toList(),
      );
    } catch (e) {
      throw ApiException('Failed to fetch bookings for date range: ${e.toString()}');
    }
  }

  // Process API response
  T _processResponse<T>(
    http.Response response,
    T Function(dynamic data) processor,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return processor(data);
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Unknown error occurred';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}

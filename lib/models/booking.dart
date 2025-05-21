class Booking {
  final String? id;
  final String userId;
  final String roomId;
  final dynamic startTime; // Can be DateTime or String
  final dynamic endTime;   // Can be DateTime or String
  final String? createdAt;
  final String? updatedAt;
  final String? notes;
  final String? status;
  final int? attendees;
  final String? title;     // Add title field for backend compatibility

  Booking({
    this.id,
    required this.userId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.status,
    this.attendees,
    this.title,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle different date formats
    dynamic parseDateTime(dynamic dateTime) {
      if (dateTime == null) return null;
      if (dateTime is DateTime) return dateTime;

      try {
        return DateTime.parse(dateTime.toString());
      } catch (e) {
        return dateTime.toString();
      }
    }

    return Booking(
      id: json['id'],
      userId: json['userId'] ?? 'Unknown',
      roomId: json['roomId'] ?? '',
      startTime: parseDateTime(json['startTime']),
      endTime: parseDateTime(json['endTime']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      notes: json['notes'],
      status: json['status'],
      attendees: json['attendees'] != null ? int.tryParse(json['attendees'].toString()) : null,
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roomId': roomId,
      'startTime': startTime is DateTime
          ? (startTime as DateTime).toUtc().toIso8601String()
          : startTime,
      'endTime': endTime is DateTime
          ? (endTime as DateTime).toUtc().toIso8601String()
          : endTime,
      'notes': notes,
      'status': status,
      'attendees': attendees,
      'title': title ?? 'Meeting', // Default title for backend compatibility
      'description': notes ?? '', // Use notes as description for backend compatibility
    };
  }

  // For updating an existing booking
  Map<String, dynamic> toJsonWithId() {
    final json = toJson();
    if (id != null) {
      json['id'] = id;
    }
    return json;
  }
}

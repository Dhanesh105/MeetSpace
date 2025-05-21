class Room {
  final String id;
  final String name;
  final int capacity;
  final List<String> features;
  final String? location;
  final String? imageUrl;
  final bool isAvailable;

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.features,
    this.location,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    // Use roomId if available, otherwise fall back to id or _id
    String roomId = json['roomId'] ?? json['id'] ?? json['_id']?.toString() ?? '';

    return Room(
      id: roomId,
      name: json['name'],
      capacity: json['capacity'],
      features: List<String>.from(json['features'] ?? []),
      location: json['location'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': id, // Include roomId field for backend compatibility
      'name': name,
      'capacity': capacity,
      'features': features,
      'location': location,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  @override
  String toString() {
    return name;
  }
}

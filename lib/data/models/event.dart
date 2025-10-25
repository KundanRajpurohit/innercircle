class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dateTime;
  final double lat;
  final double lng;
  final String hostId;
  final List<String> joinedUsers;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.lat,
    required this.lng,
    required this.hostId,
    required this.joinedUsers,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    dateTime: DateTime.parse(json['dateTime']),
    lat: json['lat'],
    lng: json['lng'],
    hostId: json['hostId'],
    joinedUsers: List<String>.from(json['joinedUsers'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'dateTime': dateTime.toIso8601String(),
    'lat': lat,
    'lng': lng,
    'hostId': hostId,
    'joinedUsers': joinedUsers,
  };
}

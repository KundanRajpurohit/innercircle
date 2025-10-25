// Update models/app_user.dart
class AppUser {
  final String uid;
  final String name;
  final String? photoUrl;
  final String? bio;
  final List<String> interests;
  final double? lat;
  final double? lng;

  AppUser({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.bio,
    required this.interests,
    this.lat,
    this.lng,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    name: json['name'],
    photoUrl: json['photoUrl'],
    bio: json['bio'],
    interests: List<String>.from(json['interests'] ?? []),
    lat: json['lat'],
    lng: json['lng'],
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'photoUrl': photoUrl,
    'bio': bio,
    'interests': interests,
    'lat': lat,
    'lng': lng,
  };

  // Add copyWith method
  AppUser copyWith({
    String? uid,
    String? name,
    String? photoUrl,
    String? bio,
    List<String>? interests,
    double? lat,
    double? lng,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

class Place {
  final String? name;
  final double latitude;
  final double longitude;
  final String uid;
  final bool check;
  Place({
    this.name,
    required this.latitude,
    required this.longitude,
    required this.uid,
    this.check = false,
  });

  Place copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? uid,
    bool? check,
  }) {
    return Place(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      uid: uid ?? this.uid,
      check: check ?? this.check,
    );
  }
}

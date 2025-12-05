class MeetingPoint {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  MeetingPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory MeetingPoint.fromSupabase(Map<String, dynamic> json) {
    return MeetingPoint(
      id: json['id'],
      name: json['name'] ?? 'Unknown Point',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
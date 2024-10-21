class Playlist {
  String id;
  String name;
  List<String> videoIds;

  Playlist({required this.id, required this.name, List<String>? videoIds})
      : videoIds = videoIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videoIds': videoIds,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      videoIds: List<String>.from(json['videoIds']),
    );
  }
}
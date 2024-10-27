class Playlist {
  final String id;
  final String name;
  final List<String> videoIds;

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

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? videoIds,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      videoIds: videoIds ?? this.videoIds,
    );
  }
}

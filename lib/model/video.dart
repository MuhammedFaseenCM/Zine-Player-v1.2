import 'dart:typed_data';

class Video {
  final String id;
  final String name;
  final String uri;
  final int duration;
  final int size;
  final String mimeType;
  final Uint8List? thumbnail;
  bool isFavorite;
  DateTime? lastPlayed;
  Duration lastPosition;

  Video({
    required this.id,
    required this.name,
    required this.uri,
    required this.duration,
    required this.size,
    required this.mimeType,
    this.thumbnail,
    this.isFavorite = false,
    this.lastPlayed,
    this.lastPosition = Duration.zero,
  });

  factory Video.fromMap(Map<Object?, Object?> map) {
    return Video(
      id: map['id'] as String,
      name: map['name'] as String,
      uri: map['uri'] as String,
      duration: map['duration'] as int,
      size: map['size'] as int,
      mimeType: map['mimeType'] as String,
      thumbnail: map['thumbnail'] as Uint8List?,
      isFavorite: map['isFavorite'] as bool? ?? false,
      lastPlayed: map['lastPlayed'] != null
          ? DateTime.parse(map['lastPlayed'] as String)
          : null,
      lastPosition: Duration(milliseconds: map['lastPosition'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      'duration': duration,
      'size': size,
      'mimeType': mimeType,
      'thumbnail': thumbnail,
      'isFavorite': isFavorite,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'lastPosition': lastPosition.inMilliseconds,
    };
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
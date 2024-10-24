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
  final String folderPath;
  final String folderName;

  Video({
    required this.id,
    required this.name,
    required this.uri,
    required this.duration,
    required this.size,
    required this.mimeType,
    required this.folderPath,
    required this.folderName,
    this.thumbnail,
    this.isFavorite = false,
    this.lastPlayed,
    this.lastPosition = Duration.zero,
  });

  factory Video.fromMap(Map<Object?, Object?> map) {
    return Video(
      id: map['id'].toString(),
      name: map['name'].toString(),
      uri: map['uri'].toString(),
      duration: (map['duration'] as num).toInt(),
      size: (map['size'] as num).toInt(),
      mimeType: map['mimeType'].toString(),
      folderPath: map['folderPath']?.toString() ?? '',
      folderName: map['folderName']?.toString() ?? '',
      thumbnail: map['thumbnail'] is List ? Uint8List.fromList(List<int>.from(map['thumbnail'] as List)) : null,
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
      'folderPath': folderPath,
      'folderName': folderName,
      'thumbnail': thumbnail?.toList(),
      'isFavorite': isFavorite,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'lastPosition': lastPosition.inMilliseconds,
    };
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
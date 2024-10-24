import 'package:zine_player/model/video.dart';

class FolderModel {
  final String path;
  final String name;
  final List<Video> videos;
  final int videoCount;

  FolderModel({
    required this.path,
    required this.name,
    required this.videos,
    required this.videoCount,
  });
}
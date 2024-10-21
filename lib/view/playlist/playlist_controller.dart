import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zine_player/model/playlist.dart';
import 'package:zine_player/model/video.dart';
import 'package:uuid/uuid.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class PlaylistController extends GetxController {
  List<Playlist> playlists = [];
  final videoController = Get.find<VideoController>();

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistsJson = prefs.getStringList('playlists') ?? [];
    playlists = playlistsJson
        .map((json) => Playlist.fromJson(jsonDecode(json)))
        .toList();
    update(['playlists']);
  }

  Future<void> savePlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistsJson = playlists
        .map((playlist) => jsonEncode(playlist.toJson()))
        .toList();
    await prefs.setStringList('playlists', playlistsJson);
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(id: const Uuid().v4(), name: name);
    playlists.add(newPlaylist);
    await savePlaylists();
    update(['playlists']);
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    playlists.remove(playlist);
    await savePlaylists();
    update(['playlists']);
  }

  Future<void> addVideoToPlaylist(Playlist playlist, Video video) async {
    if (!playlist.videoIds.contains(video.id)) {
      playlist.videoIds.add(video.id);
      await savePlaylists();
      update(['playlist_${playlist.id}', 'playlists']);
    }
  }

  Future<void> removeVideoFromPlaylist(Playlist playlist, String videoId) async {
    playlist.videoIds.remove(videoId);
    await savePlaylists();
    update(['playlist_${playlist.id}', 'playlists']);
  }

  List<Video> getVideosInPlaylist(Playlist playlist) {
    return videoController.videos
        .where((video) => playlist.videoIds.contains(video.id))
        .toList();
  }

    Future<void> toggleFavorite(Video video, Playlist playlist) async {
    video.toggleFavorite();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    if (video.isFavorite) {
      favoriteIds.add(video.id);
    } else {
      favoriteIds.remove(video.id);
    }
    await prefs.setStringList('favoriteVideos', favoriteIds);

    // Update FavoriteVideoController if it's active
    if (Get.isRegistered<FavoriteVideosController>()) {
      Get.find<FavoriteVideosController>().loadFavorites();
    }
    update(['playlist_${playlist.id}', 'playlists']);
  }
}
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/controller/mixins/recently_played_mixin.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/controller/mixins/video_operations_mixin.dart';
import 'dart:convert';
import 'package:zine_player/model/playlist.dart';
import 'package:zine_player/model/video.dart';
import 'package:uuid/uuid.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class PlaylistController extends GetxController with VideoOperationsMixin, RecentlyPlayedMixin, VideoListMixin {
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
      update([VideoListMixin.playlistID, 'playlists']);
    }
  }

  Future<void> removeVideoFromPlaylist(Playlist playlist, String videoId) async {
    playlist.videoIds.remove(videoId);
    await savePlaylists();
    update([VideoListMixin.playlistID, 'playlists']);
  }

  List<Video> getVideosInPlaylist(Playlist playlist) {
    return videoController.videos
        .where((video) => playlist.videoIds.contains(video.id))
        .toList();
  }
  
  @override
  void updateControllerState() {
  }
  
  @override
  Future<void> loadVideos() async {

  }

  void updatePlaylistName(Playlist playlist, String newName) {
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist.copyWith(name: newName);
      update(['playlists']);
      savePlaylists();
    }
  }
}

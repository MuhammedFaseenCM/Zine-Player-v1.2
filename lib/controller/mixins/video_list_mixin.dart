import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

mixin VideoListMixin on GetxController {
  List<Video> videos = [];
  List<Video> get favoriteVideos => getFavoriteVideos();
  List<Video> get recentlyPlayedVideos => videos
      .where((video) => video.lastPlayed != null)
      .toList()
    ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
  
  bool isLoading = false;
  bool hasPermission = false;

  static const String videosID = 'videos';
  static const String loadingID = 'loading';
  static const String favoritesID = "favorite";
  static const String permissionID = 'permission';
  static const String playlistID = "playlist";

  Future<void> loadVideos();

  Future<void> updateFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    for (var video in videos) {
      video.isFavorite = favoriteIds.contains(video.id);
    }
    update([videosID]);
  }
  
  Future<void> toggleFavorite(Video video) async {
    video.toggleFavorite();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    
    if (video.isFavorite) {
      favoriteIds.add(video.id);
    } else {
      favoriteIds.remove(video.id);
    }
    await prefs.setStringList('favoriteVideos', favoriteIds);
    
    // Notify all registered controllers
    notifyAllControllers();
    update([loadingID,VideoController.recentlyPlayedID, favoritesID, playlistID]);
  }

  Future<void> updateVideoPosition(Video video, Duration position) async {
    video.lastPosition = position;
    video.lastPlayed = DateTime.now();
    update([videosID]);
  }

  List<Video> getVideosByFolder(String folderPath) {
    return videos.where((video) => video.folderPath == folderPath).toList();
  }

  List<Video> getFavoriteVideos() {
     return videos.where((video) => video.isFavorite).toList();
    // favoriteVideos.sort((a, b) => b.lastPlayed?.compareTo(a.lastPlayed ?? DateTime(0)) ?? 0);
    // return favoriteVideos;
  }

  void setLoading(bool value) {
    isLoading = value;
    update([loadingID]);
  }

  void setPermission(bool value) {
    hasPermission = value;
    update([permissionID]);
  }

  void notifyAllControllers() {
    update([videosID]);
    if (Get.isRegistered<FavoriteVideosController>()) {
      Get.find<FavoriteVideosController>().update([videosID]);
    }
    if (Get.isRegistered<VideoController>()) {
      Get.find<VideoController>().update([videosID]);
    }
  }
}
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class FavoriteVideosController extends GetxController {
  RxList<Video> favoriteVideos = <Video>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    
    // We need to get the videos from the main VideoController
    final videoController = Get.find<VideoController>();
    favoriteVideos.value = videoController.videos
        .where((video) => favoriteIds.contains(video.id))
        .toList();
    
    isLoading.value = false;
  }

  Future<void> toggleFavorite(Video video) async {
    video.toggleFavorite();
    if (video.isFavorite) {
      favoriteVideos.add(video);
    } else {
      favoriteVideos.remove(video);
    }
    await _saveFavorites();
    favoriteVideos.refresh();

    // We also need to update the main video list
    final videoController = Get.find<VideoController>();
    videoController.videos.refresh();
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = favoriteVideos.map((video) => video.id).toList();
    await prefs.setStringList('favoriteVideos', favoriteIds);
  }
}
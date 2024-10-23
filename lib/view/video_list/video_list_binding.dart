import 'package:get/get.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class VideoListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
    Get.lazyPut<PlaylistController>(() => PlaylistController());
    Get.lazyPut<FavoriteVideosController>(() => FavoriteVideosController());
  }
}

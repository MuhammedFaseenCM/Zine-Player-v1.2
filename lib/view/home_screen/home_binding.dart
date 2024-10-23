import 'package:get/get.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/home_screen/home_controller.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<VideoController>(() => VideoController(), fenix: true);
    Get.lazyPut<PlaylistController>(() => PlaylistController(), fenix: true);
    Get.lazyPut<FavoriteVideosController>(() => FavoriteVideosController(), fenix: true);
  }
}

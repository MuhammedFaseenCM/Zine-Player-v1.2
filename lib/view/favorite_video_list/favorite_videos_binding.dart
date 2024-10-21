import 'package:get/get.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';

class FavoriteVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteVideosController>(() => FavoriteVideosController());
  }
}
import 'package:get/get.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class VideoListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoController());
    Get.lazyPut<PlaylistController>(() => PlaylistController());
  }
}
import 'package:get/get.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';

class PlaylistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaylistController>(() => PlaylistController());
  }
}

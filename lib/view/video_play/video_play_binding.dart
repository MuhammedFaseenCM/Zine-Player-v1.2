import 'package:get/get.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';

class VideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlayScreenController(
      videoUri: Get.arguments['videoFile'],
      videoTitle: Get.arguments['videoTitle'],
      startPosition: Get.arguments['startPosition']
    ));
  }
}

import 'package:get/get.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/home_screen/home_controller.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/video_folders/video_folder_controller.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

// home_binding.dart

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<VideoController>( VideoController(), permanent: true);
    Get.put<HomeController>( HomeController(), permanent: true);
    
    Get.put<PlaylistController>( PlaylistController(), permanent: true);
    Get.lazyPut<FavoriteVideosController>(()=> FavoriteVideosController(), fenix: true);
    Get.put<FolderController>(FolderController(), permanent: true);
  }
}
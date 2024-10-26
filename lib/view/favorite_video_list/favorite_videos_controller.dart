import 'package:get/get.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/controller/mixins/video_operations_mixin.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';


class FavoriteVideosController extends GetxController 
    with VideoListMixin, VideoOperationsMixin {
  static const String favoritesID = 'favorites';
  
  final VideoController videoController = Get.find<VideoController>();

  @override
  void updateControllerState() {
    update([favoritesID]);
  }

  @override
  void onInit() {
    super.onInit();
    loadVideos();
    ever(videoController.videoListUpdated, (_) {
      loadVideos();
    });
  }

  @override
  Future<void> loadVideos() async {
    isLoading = true;
    update([VideoListMixin.loadingID]);

    print( "favorite:  ${videos}");
    
    isLoading = false;
    update([VideoListMixin.loadingID, favoritesID]);
  }
}
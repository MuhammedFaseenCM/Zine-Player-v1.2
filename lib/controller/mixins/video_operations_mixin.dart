import 'package:get/get.dart';
import 'package:zine_player/components/add_to_playlist_dialog.dart';
import 'package:zine_player/controller/mixins/recently_played_mixin.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/routes/routes_name.dart';

mixin VideoOperationsMixin on GetxController {
  void updateControllerState();
  
  void playVideo(Video video) {
    if (this is RecentlyPlayedMixin) {
      (this as RecentlyPlayedMixin).addToRecentlyPlayed(video);
    }
    
    Get.toNamed(
      ZPRouteNames.videoPlay,
      arguments: {
        'videoFile': video.uri,
        'videoTitle': video.name,
        'startPosition': video.lastPosition,
      },
    );
  }

  void showAddToPlaylistDialog(Video video) {
    Get.dialog(AddToPlaylistDialog(video: video));
  }
}
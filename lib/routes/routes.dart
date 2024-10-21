import 'package:get/get.dart';
import 'package:zine_player/routes/routes_name.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_binding.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_screen.dart';
import 'package:zine_player/view/playlist/playlist_binding.dart';
import 'package:zine_player/view/playlist/playlist_screen.dart';
import 'package:zine_player/view/video_list/video_list_screen.dart';
import 'package:zine_player/view/video_list/video_list_binding.dart';
import 'package:zine_player/view/video_play/video_play_binding.dart';
import 'package:zine_player/view/video_play/video_play_screen.dart';

class ZPRoutes {
  static final routes = [
    GetPage(
      name: ZPRouteNames.videoList,
      page: () => const VideoListScreen(),
      binding: VideoListBinding(),
    ),
    GetPage(
      name: ZPRouteNames.videoPlay,
      page: () => const PlayScreen(),
      binding: VideoPlayBinding(),
    ),
    GetPage(
      name: ZPRouteNames.favorite,
      page: () => const FavoriteVideosScreen(),
      binding: FavoriteVideosBinding(),
    ),
    GetPage(
      name: ZPRouteNames.playlist,
      page: () => const PlaylistScreen(),
      binding: PlaylistBinding(),
    ),
  ];
}

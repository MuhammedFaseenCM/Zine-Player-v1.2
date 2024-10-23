import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_screen.dart';
import 'package:zine_player/view/playlist/playlist_screen.dart';
import 'package:zine_player/view/recently_played/recently_played_screen.dart';
import 'package:zine_player/view/video_list/video_list_screen.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  List<Widget> pages = [
    const VideoListScreen(),
    const RecentlyPlayedScreen(),
    const FavoriteVideosScreen(),
    const PlaylistScreen(),
  ];
}

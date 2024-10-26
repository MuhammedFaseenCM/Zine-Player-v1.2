import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/settings/settigs_drawer.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class RecentlyPlayedScreen extends GetView<VideoController> {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.recentlyPlayed),
      ),
      body: GetBuilder<VideoController>(
        id: VideoController.recentlyPlayedID,
        builder: (controller) {
          if (controller.recentlyPlayed.isEmpty) {
            return const Center(
              child: Text(AppStrings.noRecentlyPlayedVideos),
            );
          }

          return ListView.builder(
            itemCount: controller.recentlyPlayed.length,
            itemBuilder: (context, index) {
              final video = controller.recentlyPlayed[index];
              return VideoListItem(
                video: video,
                onFavoriteToggle: controller.toggleFavorite,
                onAddToPlaylist: controller.showAddToPlaylistDialog,
                onTap: controller.playVideo,
              );
            },
          );
        },
      ),
    );
  }
}
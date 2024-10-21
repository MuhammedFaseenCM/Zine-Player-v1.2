import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/add_to_playlist_dialog.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';

class FavoriteVideosScreen extends GetView<FavoriteVideosController> {
  const FavoriteVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favoriteVideos),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favoriteVideos.isEmpty) {
          return const Center(child: Text(AppStrings.noFavoriteVideos));
        }

        return ListView.builder(
          itemCount: controller.favoriteVideos.length,
          itemBuilder: (context, index) {
            final video = controller.favoriteVideos[index];
            return VideoListItem(
              video: video,
              onFavoriteToggle: controller.toggleFavorite,
              onAddToPlaylist: (video) => Get.dialog(AddToPlaylistDialog(video: video)),
              showFavoriteButton: true,
              showAddToPlaylistButton: true, onTap: (Video ) {  },
            );
          },
        );
      }),
    );
  }
}
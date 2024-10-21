import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/add_to_playlist_dialog.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/routes/routes_name.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class VideoListScreen extends GetView<VideoController> {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.videoLibrary,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(ZPRouteNames.favorite),
            icon: const Icon(Icons.favorite),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Get.toNamed(ZPRouteNames.playlist),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.hasPermission.value) {
          return Center(
            child: ElevatedButton(
              onPressed: () => controller.checkPermissionAndLoadVideos(),
              child: Text(
                AppStrings.grantPermission,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          );
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.videos.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noVideosFound,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.videos.length,
          itemBuilder: (context, index) {
            final video = controller.videos[index];
            return VideoListItem(
              video: video,
              onFavoriteToggle: controller.toggleFavorite,
              onAddToPlaylist: (video) =>
                  Get.dialog(AddToPlaylistDialog(video: video)),
              onTap: controller.playVideo,
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.loadVideos(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

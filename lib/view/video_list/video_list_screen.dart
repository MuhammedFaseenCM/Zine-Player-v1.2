import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zine_player/components/add_to_playlist_dialog.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/settings/settigs_drawer.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class VideoListScreen extends GetView<VideoController> {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: Text(
          AppStrings.videoLibrary,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: GetBuilder<VideoController>(
        id: VideoController.permissionID,
        builder: (controller) {
          if (!controller.hasPermission) {
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

          return GetBuilder<VideoController>(
            id: VideoController.loadingID,
            builder: (controller) {
              if (controller.isLoading) {
                return Center(
                  child: Lottie.asset(
                    AppStrings.loadingLottie,
                    width: 200,
                    height: 200,
                  ),
                );
              }

              return GetBuilder<VideoController>(
                id: VideoController.videosID,
                builder: (controller) {
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
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.loadVideos(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

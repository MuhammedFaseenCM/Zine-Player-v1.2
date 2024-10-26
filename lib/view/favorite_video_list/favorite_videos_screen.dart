import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';
import 'package:zine_player/view/settings/settigs_drawer.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class FavoriteVideosScreen extends GetView<VideoController> {
  const FavoriteVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const SettingsDrawer(),
        appBar: AppBar(
          title: const Text(AppStrings.favoriteVideos),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
        body: GetBuilder<VideoController>(
          id: VideoListMixin.loadingID,
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return GetBuilder<VideoController>(
              id: FavoriteVideosController.favoritesID,
              builder: (controller) {
              var  favVideos = controller.videos.where((video)=> video.isFavorite).toList();
                if (favVideos.isEmpty) {
                  return const Center(child: Text('No favorite videos'));
                }

                return ListView.builder(
                  itemCount: favVideos.length,
                  itemBuilder: (context, index) {
                    final video = favVideos[index];
                    return VideoListItem(
                      video: video,
                      onFavoriteToggle: controller.toggleFavorite,
                      onAddToPlaylist: controller.showAddToPlaylistDialog,
                      onTap: controller.playVideo,
                    );
                  },
                );
              },
            );
          },
        ));
  }
}

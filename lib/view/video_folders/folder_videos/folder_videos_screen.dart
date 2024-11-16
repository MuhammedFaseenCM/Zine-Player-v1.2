// folder_videos_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/add_to_playlist_dialog.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/model/folder.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class FolderVideosScreen extends GetView<VideoController> {
  final FolderModel folder;

  const FolderVideosScreen({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          folder.name,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: GetBuilder<VideoController>(
        id: VideoController.videosID,
        builder: (context) {
          return ListView.builder(
            itemCount: folder.videos.length,
            itemBuilder: (context, index) {
              final video = folder.videos[index];
              return VideoListItem(
                video: video,
                onFavoriteToggle: controller.toggleFavorite,
                onAddToPlaylist: (video) =>
                    Get.dialog(AddToPlaylistDialog(video: video)),
                onTap: controller.playVideo,
              );
            },
          );
        }
      ),
    );
  }
}
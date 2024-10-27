import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/model/playlist.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';

class PlaylistDetailScreen extends GetView<PlaylistController> {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: GetBuilder<PlaylistController>(
        id: VideoListMixin.playlistID,
        builder: (_) {
          final videos = controller.getVideosInPlaylist(playlist);
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppStrings.emptyLottie,
                    width: 200,
                    height: 200
                  ),
                  const SizedBox(height: 20),
                  Text('This playlist is empty', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Dismissible(
                key: Key(video.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // confirmDismiss: (direction) => (){return true;},
                onDismissed: (direction) async {
                  await controller.removeVideoFromPlaylist(playlist, video.id);
                },
                child: VideoListItem(
                  video: video,
                  onFavoriteToggle: controller.toggleFavorite,
                  onAddToPlaylist: (_) {},
                  showFavoriteButton: true,
                  showAddToPlaylistButton: false,
                  onTap: controller.playVideo,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

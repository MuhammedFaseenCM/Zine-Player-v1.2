import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/model/playlist.dart';
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
            return const Center(
              child: Text(
                'No videos in this playlist',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoListItem(
                video: video,
                onFavoriteToggle: controller.toggleFavorite,
                onAddToPlaylist: (_) {},
                showFavoriteButton: true,
                showAddToPlaylistButton: false, 
                onTap: controller.playVideo,
              );
            },
          );
        },
      ),
    );
  }
}
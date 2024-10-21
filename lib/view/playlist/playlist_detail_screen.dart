import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/components/video_list_item.dart';
import 'package:zine_player/model/playlist.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';

class PlaylistDetailScreen extends StatelessWidget {
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
        id: 'playlist_${playlist.id}',
        builder: (controller) {
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
                onFavoriteToggle: (v) => controller.toggleFavorite(v, playlist),
                onAddToPlaylist: (_) {}, // Not needed in playlist detail
                showFavoriteButton: true,
                showAddToPlaylistButton: false, onTap: (Video ) {  },
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';

class AddToPlaylistDialog extends StatelessWidget {
  final Video video;

  const AddToPlaylistDialog({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addToPlaylist),
      content: GetBuilder<PlaylistController>(
        init: PlaylistController(),
        id: 'playlists',
        builder: (playlistController) {
          if (playlistController.playlists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists available. Create a playlist first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: playlistController.playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name),
                  onTap: () {
                    playlistController.addVideoToPlaylist(playlist, video);
                    Get.back();
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text(AppStrings.cancel),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}
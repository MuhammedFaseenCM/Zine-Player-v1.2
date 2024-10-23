import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';

class AddToPlaylistDialog extends GetView<PlaylistController> {
  final Video video;

  const AddToPlaylistDialog({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addToPlaylist,
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: GetBuilder<PlaylistController>(
        id: 'playlists',
        builder: (_) {
          if (controller.playlists.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'No playlists available. Create a playlist first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  child: const Text('Create Playlist'),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name),
                  onTap: () {
                    controller.addVideoToPlaylist(playlist, video);
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

  // Function to show the create playlist dialog
  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter playlist name'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Create'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createPlaylist(nameController.text);
                Get.back(); // Close the create dialog
                Get.back(); // Close the add to playlist dialog
              } else {
                Get.snackbar('Error', 'Playlist name cannot be empty.',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
    );
  }
}

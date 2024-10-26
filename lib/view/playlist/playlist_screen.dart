import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/playlist/playlist_detail_screen.dart';
import 'package:zine_player/view/settings/settigs_drawer.dart';

class PlaylistScreen extends GetView<PlaylistController> {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.playlists),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: GetBuilder<PlaylistController>(
          id: 'playlists',
          builder: (_) {
            if (controller.playlists.isEmpty) {
              return const Center(
                child: Text(
                  'No playlists created yet',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.playlists.length,
              itemBuilder: (context, index) {
                final playlist = controller.playlists[index];
                return ListTile(
                    title: Text(playlist.name),
                    subtitle: Text(AppStrings.videosCount.replaceFirst(
                        '{count}', playlist.videoIds.length.toString())),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.deletePlaylist(playlist),
                    ),
                    onTap: () =>
                        Get.to(() => PlaylistDetailScreen(playlist: playlist)));
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final RxString errorText = ''.obs; // For validation error message

    Get.dialog(
      AlertDialog(
        title: const Text(
          AppStrings.createNewPlaylist,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: AppStrings.playlistName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => errorText.value.isNotEmpty
                ? Text(
                    errorText.value,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        actions: [
          TextButton(
            child: Text(AppStrings.cancel,
                style: TextStyle(color: Colors.grey[700])),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text(AppStrings.create),
            onPressed: () {
              if (nameController.text.isEmpty) {
                errorText.value = 'Playlist name cannot be empty';
              } else {
                controller.createPlaylist(nameController.text);
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }
}

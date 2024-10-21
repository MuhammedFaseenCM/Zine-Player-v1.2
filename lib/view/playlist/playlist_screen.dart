import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/playlist/playlist_controller.dart';
import 'package:zine_player/view/playlist/playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.playlists),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: GetBuilder<PlaylistController>(
          id: 'playlists',
          builder: (controller) {
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
    final PlaylistController controller = Get.find<PlaylistController>();

    Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.createNewPlaylist),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: AppStrings.playlistName),
        ),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancel),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text(AppStrings.create),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
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

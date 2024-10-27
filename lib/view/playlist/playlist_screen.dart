import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zine_player/model/playlist.dart';
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
              return Center(
                  child: Lottie.asset(
                    AppStrings.emptyLottie,
                    width: 200,
                    height: 200,
                  ),
                );
            }
            return ListView.builder(
              itemCount: controller.playlists.length,
              itemBuilder: (context, index) {
                final playlist = controller.playlists[index];
                return Dismissible(
                  key: Key(playlist.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    controller.deletePlaylist(playlist);
                  },
                  child: ListTile(
                    title: Text(playlist.name, style: Get.textTheme.titleLarge),
                    subtitle: Text(AppStrings.videosCount.replaceFirst(
                        '{count}', playlist.videoIds.length.toString())),
                    onLongPress: () => _showEditPlaylistDialog(context, playlist),
                    onTap: () => Get.to(() => PlaylistDetailScreen(playlist: playlist)),
                  ),
                );
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

  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
    final TextEditingController nameController = TextEditingController(text: playlist.name);
    final RxString errorText = ''.obs;

    Get.dialog(
      AlertDialog(
        title: const Text(
          AppStrings.editPlaylist,
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
            child: const Text(AppStrings.save),
            onPressed: () {
              if (nameController.text.isEmpty) {
                errorText.value = 'Playlist name cannot be empty';
              } else {
                controller.updatePlaylistName(playlist, nameController.text);
                Get.back();
              }
            },
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/video_folders/folder_videos/folder_videos_screen.dart';
import 'package:zine_player/view/video_folders/video_folder_controller.dart';

class FolderScreen extends GetView<FolderController> {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Folders',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Obx(() {
        if (controller.folders.isEmpty) {
          return Center(
            child: Text(
              'No folders found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.folders.length,
          itemBuilder: (context, index) {
            final folder = controller.folders[index];
            // final firstVideo = folder.videos.first;
            
            return ListTile(
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, size: 32),
              ),
              title: Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${folder.videoCount} videos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => Get.to(() => FolderVideosScreen(folder: folder)),
            );
          },
        );
      }),
    );
  }
}
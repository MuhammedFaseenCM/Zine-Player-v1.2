import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/model/folder.dart';
import 'package:zine_player/theme/app_theme.dart';
import 'package:zine_player/view/video_folders/folder_videos/folder_videos_screen.dart';

class FolderListItem extends StatelessWidget {
  final FolderModel folder;

  const FolderListItem({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.folder, size: 32, color: AppTheme.primaryColor),
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
  }
}

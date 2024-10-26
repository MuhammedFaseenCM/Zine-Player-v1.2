import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/video_folders/video_folder_controller.dart';
import 'package:zine_player/view/video_folders/widgets/folder_list_item.dart';

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
      body: GetBuilder<FolderController>(
  id: FolderController.foldersID,
  builder: (controller) {
    return ListView.builder(
      itemCount: controller.folders.length,
      itemBuilder: (context, index) {
        final folder = controller.folders[index];
        return FolderListItem(folder: folder);
      },
    );
  },
)
    );
  }
}
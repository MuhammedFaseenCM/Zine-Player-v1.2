import 'package:get/get.dart';
import 'package:zine_player/model/folder.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

// folder_controller.dart

class FolderController extends GetxController {
  List<FolderModel> folders = [];
  final VideoController videoController = Get.find<VideoController>();

  static const String foldersID = 'folders';

  @override
  void onInit() {
    super.onInit();
    // Initial organization
    organizeFolders();
    
    // Listen to video controller updates
    ever(videoController.videoListUpdated, (_) {
      organizeFolders();
    });
  }

  void organizeFolders() {
    if (videoController.videos.isEmpty) return;

    Map<String, List<Video>> folderMap = {};

    for (var video in videoController.videos) {
      if (!folderMap.containsKey(video.folderPath)) {
        folderMap[video.folderPath] = [];
      }
      folderMap[video.folderPath]!.add(video);
    }

    folders = folderMap.entries.map((entry) {
      return FolderModel(
        path: entry.key,
        name: entry.value.first.folderName,
        videos: entry.value,
        videoCount: entry.value.length,
      );
    }).toList();
    
    folders.sort((a, b) => b.videoCount.compareTo(a.videoCount));
    update([foldersID]);
  }
}
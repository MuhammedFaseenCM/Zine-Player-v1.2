import 'package:get/get.dart';
import 'package:zine_player/model/folder.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class FolderController extends GetxController {
  RxList<FolderModel> folders = <FolderModel>[].obs;
  final VideoController videoController = Get.find<VideoController>();

  @override
  void onInit() {
    super.onInit();
    organizeFolders();
    ever(videoController.videos, (_) => organizeFolders());
  }

  void organizeFolders() {
    Map<String, List<Video>> folderMap = {};

    for (var video in videoController.videos) {
      if (!folderMap.containsKey(video.folderPath)) {
        folderMap[video.folderPath] = [];
      }
      folderMap[video.folderPath]!.add(video);
    }

    folders.value = folderMap.entries.map((entry) {
      return FolderModel(
        path: entry.key,
        name: entry.value.first.folderName, // Use the folder name from video
        videos: entry.value,
        videoCount: entry.value.length,
      );
    }).toList();
    
    folders.sort((a, b) => b.videoCount.compareTo(a.videoCount));
  }
}

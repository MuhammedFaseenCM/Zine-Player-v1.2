import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/routes/routes_name.dart';
import 'package:zine_player/view/favorite_video_list/favorite_videos_controller.dart';


class VideoController extends GetxController {
  RxList<Video> videos = <Video>[].obs;
  RxList<Video> recentlyPlayed = <Video>[].obs;
  RxBool hasPermission = false.obs;
  RxBool isLoading = false.obs;
  final MethodChannel _channel = const MethodChannel('com.example.zine_player/device_info');
  final MethodChannel _mediaStoreChannel = const MethodChannel('com.example.zine_player/media_store');

  @override
  void onInit() {
    super.onInit();
    checkPermissionAndLoadVideos();
  }

  Future<void> checkPermissionAndLoadVideos() async {
    hasPermission.value = await requestStoragePermission();
    if (hasPermission.value) {
      await loadVideos();
      await loadRecentlyPlayed();
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkVersion = await _getAndroidSdkVersion();
      if (sdkVersion >= 30) {
        var status = await Permission.videos.status;
        if (!status.isGranted) {
          status = await Permission.videos.request();
        }
        return status.isGranted;
      } else if (sdkVersion >= 29) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        final int sdkVersion = await _channel.invokeMethod('getAndroidSDKVersion');
        return sdkVersion;
      }
    } on PlatformException catch (e) {
      print("Failed to get Android SDK version: ${e.message}");
    }
    return 0;
  }

  Future<void> loadVideos() async {
    isLoading.value = true;
    if (hasPermission.value) {
      if (Platform.isAndroid && await _getAndroidSdkVersion() >= 29) {
        videos.value = await _getVideosUsingMediaStore();
      } else {
        final directory = await getExternalStorageDirectory();
        videos.value = await getVideosFromDirectory(directory!);
      }
      await _updateFavoriteStatus();
    } else {
      print('Storage permission not granted');
    }
    isLoading.value = false;
  }


  Future<List<Video>> _getVideosUsingMediaStore() async {
    try {
      final List<dynamic> result = await _mediaStoreChannel.invokeMethod('getVideos');
      return result.map((video) {
        if (video is Map<Object?, Object?>) {
          try {
            return Video.fromMap(video);
          } catch (e) {
            print("Error parsing video data: $e");
            return null;
          }
        } else {
          print("Unexpected data type for video: ${video.runtimeType}");
          return null;
        }
      }).whereType<Video>().toList();
    } on PlatformException catch (e) {
      print("Failed to get videos: ${e.message}");
      return [];
    }
  }

  Future<List<Video>> getVideosFromDirectory(Directory directory) async {
    List<Video> videoFiles = [];
    List<FileSystemEntity> entities = await directory.list().toList();
    for (var entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp4')) {
        final folderPath = entity.parent.path;
        videoFiles.add(Video(
          id: entity.path,
          name: entity.path.split('/').last,
          uri: entity.path,
          duration: 0,
          size: await entity.length(),
          mimeType: 'video/mp4',
          folderPath: folderPath,
          folderName: folderPath.split('/').last,
        ));
      } else if (entity is Directory) {
        videoFiles.addAll(await getVideosFromDirectory(entity));
      }
    }
    return videoFiles;
  }

  Future<void> _updateFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    for (var video in videos) {
      video.isFavorite = favoriteIds.contains(video.id);
    }
  }

  Future<void> toggleFavorite(Video video) async {
    video.toggleFavorite();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteVideos') ?? [];
    if (video.isFavorite) {
      favoriteIds.add(video.id);
    } else {
      favoriteIds.remove(video.id);
    }
    await prefs.setStringList('favoriteVideos', favoriteIds);
    videos.refresh();

    // Update FavoriteVideoController if it's active
    if (Get.isRegistered<FavoriteVideosController>()) {
      Get.find<FavoriteVideosController>().loadFavorites();
    }
  }

  // Recently played screen section
    Future<void> loadRecentlyPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayedJson = prefs.getStringList('recentlyPlayed') ?? [];
    recentlyPlayed.value = recentlyPlayedJson
        .map((json) => Video.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
  }

  Future<void> saveRecentlyPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayedJson = recentlyPlayed
        .map((video) => jsonEncode(video.toMap()))
        .toList();
    await prefs.setStringList('recentlyPlayed', recentlyPlayedJson);
  }

  void addToRecentlyPlayed(Video video) {
    video.lastPlayed = DateTime.now();
    recentlyPlayed.removeWhere((v) => v.id == video.id);
    recentlyPlayed.insert(0, video);
    if (recentlyPlayed.length > 10) {
      recentlyPlayed.removeLast();
    }
    saveRecentlyPlayed();
  }

  Future<void> updateVideoPosition(Video video, Duration position) async {
    video.lastPosition = position;
    int index = recentlyPlayed.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      recentlyPlayed[index] = video;
      saveRecentlyPlayed();
    }
  }

  void playVideo(Video video) {
    addToRecentlyPlayed(video);
    Get.toNamed(
      ZPRouteNames.videoPlay,
      arguments: {
        'videoFile': video.uri,
        'videoTitle': video.name,
        'startPosition': video.lastPosition,
      },
    );
  }
}
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/controller/mixins/recently_played_mixin.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/controller/mixins/video_operations_mixin.dart';
import 'package:zine_player/model/video.dart';


class VideoController extends GetxController with VideoListMixin, VideoOperationsMixin, RecentlyPlayedMixin {

  final MethodChannel _channel = const MethodChannel('com.example.zine_player/device_info');
  final MethodChannel _mediaStoreChannel = const MethodChannel('com.example.zine_player/media_store');

  static const String videosID = 'videos';
  static const String permissionID = 'permission';
  static const String loadingID = 'loading';
  static const String recentlyPlayedID = 'recentlyPlayed';
  final List<Function> _listeners = [];
  bool _isInitialized = false;
  final videoListUpdated = false.obs;

  @override
  void Function() addListener(void Function() listener) {
    _listeners.add(listener);
    return listener;
  }

  @override
  void updateControllerState() {
    update([videosID]);
  }

   void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      checkPermissionAndLoadVideos();
      _isInitialized = true;
    }
  }

  Future<void> checkPermissionAndLoadVideos() async {
    hasPermission = await requestStoragePermission();
    update([permissionID]);
    if (hasPermission) {
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
  
  @override
  Future<void> loadVideos() async {
   setLoading(true);

    if (hasPermission) {
      if (Platform.isAndroid && await _getAndroidSdkVersion() >= 29) {
        videos = await _getVideosUsingMediaStore();
      } else {
        final directory = await getExternalStorageDirectory();
        videos = await getVideosFromDirectory(directory!);
      }
      await _updateFavoriteStatus();
      videoListUpdated.toggle();
      getFavoriteVideos();
    }

    setLoading(false);
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class PlayScreenController extends GetxController {
  late VideoPlayerController videoController;
  final String videoUri;
  final String videoTitle;
  final Duration startPosition;

  PlayScreenController({
    required this.videoUri,
    required this.videoTitle,
    required this.startPosition,
  });

  bool isInitialized = false;
  bool isPlaying = false;
  bool isControlsVisible = true;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPortrait = true;
  bool isLocked = false;
  bool isSeekIndicatorVisible = false;
  String seekIndicatorText = '';
  bool isDragging = false;
  double dragProgress = 0.0;

  static const String initId = 'init';
  static const String playPauseId = 'playPause';
  static const String controlsId = 'controls';
  static const String progressId = 'progress';
  static const String orientationId = 'orientation';
  static const String lockId = 'lock';
  static const String seekId = 'seek';

  Timer? _seekIndicatorTimer;

  @override
  void onInit() {
    super.onInit();
    initializeVideoPlayer();
    _hideStatusBar();
  }

  void initializeVideoPlayer() {
    if (videoUri.startsWith('content://')) {
      videoController = VideoPlayerController.contentUri(Uri.parse(videoUri));
    } else {
      videoController = VideoPlayerController.file(File(videoUri));
    }

    videoController.initialize().then((_) {
      isInitialized = true;
      totalDuration = videoController.value.duration;
      _updateOrientation();
      seekTo(startPosition);
      update([initId, orientationId]);
      play();
    }).catchError((error) {
      print("Error initializing video player: $error");
      // Handle the error, maybe show a snackbar or dialog to the user
    });

    videoController.addListener(_videoListener);
  }

  void _videoListener() {
    final newPosition = videoController.value.position;
    final newIsPlaying = videoController.value.isPlaying;

    if (newPosition != currentPosition) {
      currentPosition = newPosition;
      update([progressId]);
    }

    if (newIsPlaying != isPlaying) {
      isPlaying = newIsPlaying;
      update([playPauseId]);
    }
  }

  void _updateOrientation() {
    final aspectRatio = videoController.value.aspectRatio;
    if (aspectRatio < 1) {
      // Portrait video
      isPortrait = true;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // Landscape video
      isPortrait = false;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void play() {
    videoController.play();
    isPlaying = true;
    update([playPauseId]);
  }

  void pause() {
    videoController.pause();
    isPlaying = false;
    update([playPauseId]);
  }

  void togglePlayPause() {
    if (isLocked) return;
    isPlaying = !isPlaying;
    isPlaying ? videoController.play() : videoController.pause();
    update([playPauseId]);
  }

  void toggleControls() {
    if (isLocked) return;
    isControlsVisible = !isControlsVisible;
    update([controlsId]);
  }

  void seekTo(Duration position) {
    if (isLocked) return;
    videoController.seekTo(position);
  }

  void seekForward(int seconds) {
    if (isLocked) return;
    final newPosition = currentPosition + Duration(seconds: seconds);
    seekTo(newPosition);
    _showSeekIndicator('+$seconds seconds');
  }

  void seekBackward(int seconds) {
    if (isLocked) return;
    final newPosition = currentPosition - Duration(seconds: seconds);
    seekTo(newPosition);
    _showSeekIndicator('-$seconds seconds');
  }

  void _showSeekIndicator(String text) {
    seekIndicatorText = text;
    isSeekIndicatorVisible = true;
    update([seekId]);

    _seekIndicatorTimer?.cancel();
    _seekIndicatorTimer = Timer(const Duration(seconds: 1), () {
      isSeekIndicatorVisible = false;
      update([seekId]);
    });
  }

  void toggleLock() {
    isLocked = !isLocked;
    if (isLocked) {
      isControlsVisible = false;
    }
    update([lockId, controlsId, initId]);
  }

  void startDragging() {
    isDragging = true;
    update([progressId]);
  }

  void updateDragProgress(double progress) {
    dragProgress = progress.clamp(0.0, 1.0);
    update([progressId]);
  }

  void stopDragging() {
    isDragging = false;
    seekToPercentage(dragProgress);
    update([progressId]);
  }

  void seekToPercentage(double percentage) {
    if (isLocked) return;
    final Duration position = Duration(
        milliseconds: (percentage * totalDuration.inMilliseconds).round());
    seekTo(position);
  }

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> updateVideoPosition( Duration position) async {
    Video video = Get.find<VideoController>().recentlyPlayed.where((v) => v.uri == videoUri).first;
    video.lastPosition = position;
    int index = Get.find<VideoController>().recentlyPlayed.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      Get.find<VideoController>().recentlyPlayed[index] = video;
      await saveRecentlyPlayed();
    }
  }

  Future<void> saveRecentlyPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayedJson = Get.find<VideoController>().recentlyPlayed
        .map((video) => jsonEncode(video.toMap()))
        .toList();
    await prefs.setStringList('recentlyPlayed', recentlyPlayedJson);
  }

  @override
  void onClose() {
    updateVideoPosition( videoController.value.position);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    videoController.removeListener(_videoListener);
    videoController.dispose();
    super.onClose();
  }
}

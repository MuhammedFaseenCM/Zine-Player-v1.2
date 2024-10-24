import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PlayScreenController extends GetxController {
  // Constructor and Initial Properties
  late VideoPlayerController videoController;
  final String videoUri;
  final String videoTitle;
  final Duration startPosition;

  PlayScreenController({
    required this.videoUri,
    required this.videoTitle,
    required this.startPosition,
  });

  // Static IDs for GetBuilder
  static const String initId = 'init';
  static const String playPauseId = 'playPause';
  static const String controlsId = 'controls';
  static const String progressId = 'progress';
  static const String orientationId = 'orientation';
  static const String lockId = 'lock';
  static const String seekId = 'seek';
  static const String brightnessId = "brightness";
  static const String volumeId = "volume";

  // State Variables
  bool isInitialized = false;
  bool isPlaying = false;
  bool isControlsVisible = true;
  bool isPortrait = true;
  bool isLocked = false;
  bool isDragging = false;
  bool isMuted = false;

  // Indicator States
  bool isSeekIndicatorVisible = false;
  bool isVolumeIndicatorVisible = false;
  bool isBrightnessIndicatorVisible = false;

  // Values
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double dragProgress = 0.0;
  double playbackSpeed = 1.0;
  double volume = 1.0;
  double brightness = 0.5;
  String seekIndicatorText = '';
  String currentAspectRatio = 'fit';

  // Timers
  Timer? _seekIndicatorTimer;
  Timer? _volumeIndicatorTimer;
  Timer? _brightnessIndicatorTimer;
  Timer? _hideControlsTimer;

  // Constants
  final List<double> availablePlaybackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  String currentFit = 'contain'; // contain, fill, cover
  final List<String> availableFits = ['contain', 'fill', 'cover'];

  @override
  void onInit() {
    super.onInit();
    initializeVideoPlayer();
    _hideStatusBar();
  }

  // Initialization Methods
  void initializeVideoPlayer() {
    videoController = videoUri.startsWith('content://')
        ? VideoPlayerController.contentUri(Uri.parse(videoUri))
        : VideoPlayerController.file(File(videoUri));

    videoController.initialize().then((_) {
      isInitialized = true;
      totalDuration = videoController.value.duration;
      _updateOrientation();
      seekTo(startPosition);
      update([initId, orientationId]);
      play();
    }).catchError((error) {
      print("Error initializing video player: $error");
    });

    videoController.addListener(_videoListener);
  }

  void _videoListener() {
    if (videoController.value.position != currentPosition) {
      currentPosition = videoController.value.position;
      update([progressId]);
    }

    if (videoController.value.isPlaying != isPlaying) {
      isPlaying = videoController.value.isPlaying;
      update([playPauseId]);
    }
  }

  // Playback Controls
  void play() {
    videoController.play();
    isPlaying = true;
    update([playPauseId, initId]);
  }

  void pause() {
    videoController.pause();
    isPlaying = false;
    update([playPauseId, initId]);
  }

  void togglePlayPause() {
    if (isLocked) return;
    isPlaying ? pause() : play();
  }

  void seekTo(Duration position) {
    if (isLocked) return;
    videoController.seekTo(position);
    update([initId]);
  }

  void seekForward(int seconds) {
    if (isLocked) return;
    seekTo(currentPosition + Duration(seconds: seconds));
    _showSeekIndicator('+$seconds seconds');
  }

  void seekBackward(int seconds) {
    if (isLocked) return;
    seekTo(currentPosition - Duration(seconds: seconds));
    _showSeekIndicator('-$seconds seconds');
  }

  // UI Control Methods
  void toggleControls() {
    if (isLocked) return;
    
    isControlsVisible = !isControlsVisible;
    update([controlsId]);

    _hideControlsTimer?.cancel();
    if (isControlsVisible) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        isControlsVisible = false;
        update([controlsId]);
      });
    }
  }

  void toggleLock() {
    isLocked = !isLocked;
    isControlsVisible = !isLocked;
    update([lockId, controlsId, initId]);
  }

  // Progress Bar Methods
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
    seekTo(Duration(milliseconds: (percentage * totalDuration.inMilliseconds).round()));
  }

  // Volume and Brightness Controls
  void setVolume(double newVolume) {
    volume = newVolume.clamp(0.0, 1.0);
    videoController.setVolume(volume);
    isMuted = volume == 0;
    _showVolumeIndicator();
    update([initId]);
  }

  void toggleMute() {
    setVolume(isMuted ? 1.0 : 0.0);
    update([initId]);
  }

  void setBrightness(double value) {
    brightness = value.clamp(0.0, 1.0);
    _showBrightnessIndicator();
    update([initId]);
  }

  // Indicator Methods
  void _showVolumeIndicator() {
    isVolumeIndicatorVisible = true;
    update([volumeId]);

    _volumeIndicatorTimer?.cancel();
    _volumeIndicatorTimer = Timer(const Duration(seconds: 2), () {
      isVolumeIndicatorVisible = false;
      update([volumeId]);
    });
  }

  void _showBrightnessIndicator() {
    isBrightnessIndicatorVisible = true;
    update([brightnessId]);

    _brightnessIndicatorTimer?.cancel();
    _brightnessIndicatorTimer = Timer(const Duration(seconds: 2), () {
      isBrightnessIndicatorVisible = false;
      update([brightnessId]);
    });
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

  // Utility Methods
  void _updateOrientation() {
    isPortrait = videoController.value.aspectRatio < 1;
    SystemChrome.setPreferredOrientations(
      isPortrait
          ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
  }

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Add this method
  void toggleFit() {
    final currentIndex = availableFits.indexOf(currentFit);
    final nextIndex = (currentIndex + 1) % availableFits.length;
    currentFit = availableFits[nextIndex];
    update([initId]);
  }

  // Add this method to get the current BoxFit
  BoxFit getCurrentFit() {
    switch (currentFit) {
      case 'fill':
        return BoxFit.fill;
      case 'cover':
        return BoxFit.cover;
      default:
        return BoxFit.contain;
    }
  }

  // Add this method to get the fit icon
  IconData getFitIcon() {
    switch (currentFit) {
      case 'fill':
        return Icons.fit_screen;
      case 'cover':
        return Icons.rectangle;
      default:
        return Icons.fit_screen_outlined;
    }
  }

  // Cleanup
  @override
  void onClose() {
    _hideControlsTimer?.cancel();
    _volumeIndicatorTimer?.cancel();
    _brightnessIndicatorTimer?.cancel();
    _seekIndicatorTimer?.cancel();
    videoController.removeListener(_videoListener);
    videoController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.onClose();
  }
}
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:zine_player/model/subtitle.dart';
import 'package:zine_player/view/video_list/video_list_controller.dart';

class PlayScreenController extends GetxController {
  // Constructor and Initial Properties
  late VideoPlayerController videoController;
  final String videoUri;
  final String videoTitle;
  final Duration startPosition;
  String? subtitlePath;

  PlayScreenController({
    required this.videoUri,
    required this.videoTitle,
    required this.startPosition,
    this.subtitlePath,
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
  static const String gestureId = "gesture";
  static const String subtitleId = "subtitle";

  // State Variables
  bool isInitialized = false;
  bool isPlaying = false;
  bool isControlsVisible = true;
  bool isPortrait = true;
  bool isLocked = false;
  bool isDragging = false;
  bool isMuted = false;
  bool subtitlesEnabled = false;
  bool hasSubtitle = false;

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
  
  // Subtitle related
  List<Subtitle> subtitles = [];
  Subtitle? currentSubtitle;
  double subtitleDelay = 0.0; // in seconds

  // Timers
  Timer? _seekIndicatorTimer;
  Timer? _volumeIndicatorTimer;
  Timer? _brightnessIndicatorTimer;
  Timer? _hideControlsTimer;
  Timer? _subtitleTimer;

  // Constants
  final List<double> availablePlaybackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  String currentFit = 'contain'; // contain, fill, cover
  final List<String> availableFits = ['contain', 'fill', 'cover'];

  // Subtitle Style
  TextStyle subtitleStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 4,
        color: Colors.black,
      ),
    ],
  );

  @override
  void onInit() {
    super.onInit();
    initializeVideoPlayer();
    if (subtitlePath != null) {
      loadSubtitles();
    }
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
      videoController.setLooping(true);
    }).catchError((error) {
      print("Error initializing video player: $error");
      Get.snackbar(
        'Error',
        'Failed to initialize video player',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });

    videoController.addListener(_videoListener);
  }

  void _videoListener() {
    if (videoController.value.position != currentPosition) {
      currentPosition = videoController.value.position;
      _checkSubtitle();
      update([progressId]);
    }

    if (videoController.value.isPlaying != isPlaying) {
      isPlaying = videoController.value.isPlaying;
      update([playPauseId]);
    }
  }

  // Subtitle Methods
  Future<void> loadSubtitles() async {
    if (subtitlePath == null) return;
    
    try {
      final file = File(subtitlePath!);
      if (!file.existsSync()) return;

      final content = await file.readAsString();
      subtitles = await parseSubtitles(content);
      hasSubtitle = subtitles.isNotEmpty;
      subtitlesEnabled = hasSubtitle;
      update([subtitleId, initId]);
    } catch (e) {
      print('Error loading subtitles: $e');
      Get.snackbar(
        'Error',
        'Failed to load subtitles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickSubtitleFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt', 'vtt', 'ass'],
        allowMultiple: false,
      );

      if (result != null) {
        subtitlePath = result.files.single.path!;
        hasSubtitle = true;
        subtitles.clear();
        await loadSubtitles();
        subtitlesEnabled = true;
        update([subtitleId, controlsId]);
      }
    } catch (e) {
      print('Error picking subtitle: $e');
      Get.snackbar(
        'Error',
        'Failed to load subtitle file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<Subtitle>> parseSubtitles(String content) async {
    final List<Subtitle> subs = [];
    final lines = content.split('\n');
    int i = 0;

    while (i < lines.length) {
      if (lines[i].trim().isEmpty) {
        i++;
        continue;
      }

      // Skip index number
      if (RegExp(r'^\d+$').hasMatch(lines[i].trim())) {
        i++;
      }

      // Parse timestamp
      final timestamp = lines[i].trim();
      final times = timestamp.split(' --> ');
      if (times.length != 2) {
        i++;
        continue;
      }

      final start = _parseTimestamp(times[0]);
      final end = _parseTimestamp(times[1]);

      // Parse text
      i++;
      String text = '';
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        text += (text.isEmpty ? '' : '\n') + lines[i].trim();
        i++;
      }

      subs.add(Subtitle(
        start: start,
        end: end,
        text: text,
      ));
    }

    return subs;
  }

  Duration _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    final secondsParts = parts[2].split(',');
    
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }

  void _checkSubtitle() {
    if (!subtitlesEnabled || subtitles.isEmpty) return;

    final position = currentPosition + Duration(milliseconds: (subtitleDelay * 1000).round());
    currentSubtitle = subtitles.firstWhere(
      (subtitle) => position >= subtitle.start && position <= subtitle.end,
      orElse: () => Subtitle(start: Duration.zero, end: Duration.zero, text: ''),
    );
    update([subtitleId]);
  }

  void showSubtitleOptions() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Subtitle Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.closed_caption),
                title: const Text('Enable Subtitles'),
                trailing: Switch(
                  value: subtitlesEnabled,
                  onChanged: (value) {
                    subtitlesEnabled = value;
                    update([subtitleId]);
                    Get.back();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Load Subtitle File'),
                onTap: () {
                  Get.back();
                  pickSubtitleFile();
                },
              ),
              if (hasSubtitle)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Subtitle'),
                  onTap: () {
                    subtitlePath = null;
                    hasSubtitle = false;
                    subtitles.clear();
                    subtitlesEnabled = false;
                    update([subtitleId]);
                    Get.back();
                  },
                ),
              if (hasSubtitle)
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Subtitle Settings'),
                  onTap: () {
                    Get.back();
                    showSubtitleSettings();
                  },
                ),
              SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showSubtitleSettings() {
    double fontSize = subtitleStyle.fontSize ?? 16;
    double delay = subtitleDelay;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Subtitle Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Font Size: '),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: 12,
                        max: 30,
                        divisions: 18,
                        label: fontSize.round().toString(),
                        onChanged: (value) {
                          setState(() => fontSize = value);
                          updateSubtitleStyle(fontSize: value);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Delay: '),
                    Expanded(
                      child: Slider(
                        value: delay,
                        min: -5,
                        max: 5,
                        divisions: 100,
                        label: '${delay.toStringAsFixed(1)}s',
                        onChanged: (value) {
                          setState(() => delay = value);
                          subtitleDelay = value;
                          _checkSubtitle();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void updateSubtitleStyle({
    double? fontSize,
    Color? color,
    Color? backgroundColor,
  }) {
    subtitleStyle = subtitleStyle.copyWith(
      fontSize: fontSize,
      color: color,
      backgroundColor: backgroundColor,
    );
    update([subtitleId]);
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
    update([gestureId]);
  }

  void seekTo(Duration position) {
    if (isLocked) return;
    videoController.seekTo(position).then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        isPlaying = videoController.value.isPlaying;
      });
    });
    update([gestureId]);
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
        update([gestureId]);
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
    update([gestureId]);
  }

  void toggleMute() {
    setVolume(isMuted ? 1.0 : 0.0);
    update([initId]);
  }

  void setBrightness(double value) {
    brightness = value.clamp(0.0, 1.0);
    _showBrightnessIndicator();
    update([gestureId]);
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
    Get.find<VideoController>().updateVideoPosition(
      Get.find<VideoController>().videos.where((video) => video.uri == videoUri).first,
      currentPosition
    );
    _hideControlsTimer?.cancel();
    _volumeIndicatorTimer?.cancel();
    _brightnessIndicatorTimer?.cancel();
    _seekIndicatorTimer?.cancel();
    _subtitleTimer?.cancel();
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

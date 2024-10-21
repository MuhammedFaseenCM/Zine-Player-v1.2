import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';

class PlayScreen extends GetView<PlayScreenController> {
  const PlayScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.orientationId,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => !controller.isLocked,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: _buildVideoPlayer(),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.initId,
      builder: (_) {
        if (!controller.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.videoController.value.hasError) {
          return Center(
            child: Text(
              'Error: ${controller.videoController.value.errorDescription}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.videoController.value.aspectRatio,
                child: VideoPlayer(controller.videoController),
              ),
            ),
            GestureDetector(
              onTap: controller.toggleControls,
              onDoubleTap: controller.togglePlayPause,
              onHorizontalDragEnd: (details) {
                if (controller.isLocked) return;
                if (details.primaryVelocity! > 0) {
                  controller.seekBackward(10);
                } else if (details.primaryVelocity! < 0) {
                  controller.seekForward(10);
                }
              },
              child: Container(color: Colors.transparent),
            ),
            _buildControls(),
            _buildPlayPauseButton(),
            _buildLockButton(),
            _buildSeekIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildPlayPauseButton() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.playPauseId,
      builder: (_) {
        return Center(
          child: GestureDetector(
            onTap: controller.togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildCenterControls() {
  return GetBuilder<PlayScreenController>(
    id: PlayScreenController.playPauseId,
    builder: (_) {
      return Center(
        child: AnimatedOpacity(
          opacity: controller.isControlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: controller.togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildControls() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.controlsId,
      builder: (_) {
        return AnimatedOpacity(
          opacity: controller.isControlsVisible && !controller.isLocked ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AbsorbPointer(
            absorbing: !controller.isControlsVisible || controller.isLocked,
            child: Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopBar(),
                  _buildCenterControls(),
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              controller.videoTitle,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(64, 8, 8, 8),
      child: Column(
        children: [
          _buildProgressBar(),
          const SizedBox(height: 8),
          _buildTimeDisplay(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.progressId,
      builder: (_) {
        final double progress = controller.isDragging 
            ? controller.dragProgress
            : controller.currentPosition.inMilliseconds / controller.totalDuration.inMilliseconds;
        
        return GestureDetector(
          onHorizontalDragStart: (details) {
            controller.startDragging();
          },
          onHorizontalDragUpdate: (details) {
            final RenderBox box = Get.context!.findRenderObject() as RenderBox;
            final double percentage = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            controller.updateDragProgress(percentage);
          },
          onHorizontalDragEnd: (details) {
            controller.stopDragging();
          },
          onTapDown: (details) {
            final RenderBox box = Get.context!.findRenderObject() as RenderBox;
            final double percentage = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            controller.seekToPercentage(percentage);
          },
          child: SizedBox(
            height: 20,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  left: progress * (Get.width - 64 - 12),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.progressId,
      builder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.formatDuration(controller.currentPosition),
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              controller.formatDuration(controller.totalDuration),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockButton() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.lockId,
      builder: (_) {
        return Positioned(
          left: 16,
          bottom: 16,
          child: IconButton(
            icon: Icon(
              controller.isLocked ? Icons.lock : Icons.lock_open,
              color: Colors.white,
            ),
            onPressed: controller.toggleLock,
          ),
        );
      },
    );
  }

  Widget _buildSeekIndicator() {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.seekId,
      builder: (_) {
        return AnimatedOpacity(
          opacity: controller.isSeekIndicatorVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.seekIndicatorText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
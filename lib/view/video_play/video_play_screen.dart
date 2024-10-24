import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';

class PlayScreen extends GetView<PlayScreenController> {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !controller.isLocked,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _buildVideoPlayer(context),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.initId,
      builder: (_) {
        if (!controller.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Video Layer
            Center(
            child: AspectRatio(
              aspectRatio: controller.videoController.value.aspectRatio,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: SizedBox(
                  width: controller.videoController.value.size.width,
                  height: controller.videoController.value.size.height,
                  child: VideoPlayer(controller.videoController),
                ),
              ),
            ),
          ),
            // Gesture Layer with Controls
            _buildGestureDetector(context),

            GetBuilder<PlayScreenController>(
              id: PlayScreenController.controlsId,
              builder: (_) {
                return controller.isControlsVisible || !controller.isPlaying
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              controller.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                            onPressed: controller.togglePlayPause,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildGestureDetector(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!controller.isLocked) {
          controller.toggleControls();
        }
      },
      onDoubleTap: () {
        if (!controller.isLocked) {
          controller.togglePlayPause();
        }
      },
      onVerticalDragUpdate: (details) {
        if (controller.isLocked) return;

        final isRightSide = details.globalPosition.dx > Get.width / 2;
        final delta = -details.delta.dy / Get.height;

        if (isRightSide) {
          controller.setVolume(controller.volume + delta);
        } else {
          controller.setBrightness(controller.brightness + delta);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (controller.isLocked) return;

        final delta = details.delta.dx;
        final duration = controller.totalDuration.inMilliseconds.toDouble();
        final position = controller.currentPosition.inMilliseconds.toDouble();
        final change = (delta / Get.width) * duration;

        controller.seekTo(Duration(
          milliseconds: (position + change).clamp(0.0, duration).toInt(),
        ));
      },
      child: _buildControlsOverlay(context),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.controlsId,
      builder: (_) {
        return Stack(
          children: [
            // Main Controls
            AnimatedOpacity(
              opacity: controller.isControlsVisible && !controller.isLocked
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBar(),
                    const Spacer(),
                    _buildBottomControls(context),
                  ],
                ),
              ),
            ),

            // Additional Controls and Indicators
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildLockButton(),
            ),
            if (controller.isVolumeIndicatorVisible)
              Positioned(
                right: 20,
                top: Get.height / 2 - 50,
                child: _buildVolumeIndicator(),
              ),
            if (controller.isBrightnessIndicatorVisible)
              Positioned(
                left: 20,
                top: Get.height / 2 - 50,
                child: _buildBrightnessIndicator(),
              ),
            if (controller.isSeekIndicatorVisible)
              Center(child: _buildSeekIndicator()),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressBar(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                IconButton(
                    icon: Icon(
                      controller.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: controller.toggleMute,
                  ),
                  IconButton(
              icon: Icon(
                controller.getFitIcon(),
                color: Colors.white,
              ),
              onPressed: controller.toggleFit,
              tooltip: 'Aspect Ratio: ${controller.currentFit}',
            ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.progressId,
      builder: (_) {
        final double progress = controller.isDragging
            ? controller.dragProgress
            : controller.currentPosition.inMilliseconds /
                controller.totalDuration.inMilliseconds;

        return Row(
          children: [
            Text(
            controller.formatDuration(controller.currentPosition),
            style: const TextStyle(color: Colors.white),
          ),
            Expanded(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) => controller.startDragging(),
                onHorizontalDragUpdate: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final double percentage =
                      (details.localPosition.dx / box.size.width)
                          .clamp(0.0, 1.0);
                  controller.updateDragProgress(percentage);
                },
                onHorizontalDragEnd: (details) => controller.stopDragging(),
                onTapDown: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final double percentage =
                      (details.localPosition.dx / box.size.width)
                          .clamp(0.0, 1.0);
                  controller.seekToPercentage(percentage);
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: progress * context.width - 25,
                        top: -8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
          ),
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

  Widget _buildVolumeIndicator() {
    return _buildIndicator(
      icon: Icon(
        controller.isMuted ? Icons.volume_off : Icons.volume_up,
        color: Colors.white,
      ),
      value: controller.volume,
    );
  }

  Widget _buildBrightnessIndicator() {
    return _buildIndicator(
      icon: const Icon(Icons.brightness_6, color: Colors.white),
      value: controller.brightness,
    );
  }

  Widget _buildIndicator({
    required Icon icon,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        controller.seekIndicatorText,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

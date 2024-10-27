import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';
import 'package:zine_player/view/video_play/widgets/video_progress.dart';

class VideoControls extends StatelessWidget {
  final PlayScreenController controller;

  const VideoControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.playPauseId,
      builder: (_) {
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

            // Play/Pause Icon
            if (controller.isControlsVisible || !controller.isPlaying)
              Center(
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
              ),

            // Lock Button
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildLockButton(),
            ),
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
            icon: Icon(
              controller.hasSubtitle 
                ? (controller.subtitlesEnabled 
                    ? Icons.closed_caption 
                    : Icons.closed_caption_off)
                : Icons.subtitles,
              color: Colors.white,
            ),
            onPressed: controller.showSubtitleOptions,
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
        VideoProgressBar(controller: controller),
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
}

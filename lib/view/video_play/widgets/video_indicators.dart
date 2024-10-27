import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';

class VideoIndicators extends StatelessWidget {
  final PlayScreenController controller;

  const VideoIndicators({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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

class SubtitleLayer extends StatelessWidget {
  final PlayScreenController controller;

  const SubtitleLayer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.subtitleId,
      builder: (_) {
        if (!controller.subtitlesEnabled || 
            controller.currentSubtitle == null ||
            controller.currentSubtitle!.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.currentSubtitle!.text,
              textAlign: TextAlign.center,
              style: controller.subtitleStyle,
            ),
          ),
        );
      },
    );
  }
}

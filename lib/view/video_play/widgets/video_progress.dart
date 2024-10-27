import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:zine_player/components/progress_indicator.dart';
import 'package:zine_player/theme/app_theme.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';

class VideoProgressBar extends StatelessWidget {
  final PlayScreenController controller;

  const VideoProgressBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayScreenController>(
      id: PlayScreenController.progressId,
      builder: (_) {
        return Row(
          children: [
            Text(
              controller.formatDuration(controller.currentPosition),
              style: const TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: ZPProgressIndicator(
                    controller.videoController,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppTheme.primaryColor,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.grey,
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
}

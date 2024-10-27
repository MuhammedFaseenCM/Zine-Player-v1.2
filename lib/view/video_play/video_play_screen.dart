import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/video_play/video_play_controller.dart';
import 'package:zine_player/view/video_play/widgets/video_controls.dart';
import 'package:zine_player/view/video_play/widgets/video_indicators.dart';

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
          return Center(
            child: Lottie.asset(
              AppStrings.loadingLottie,
              width: 200,
              height: 200,
            ),
          );
        }

        return Stack(
          children: [
            // Video Layer
            Center(
              child: AspectRatio(
                aspectRatio: controller.videoController.value.aspectRatio,
                child: FittedBox(
                  fit: controller.getCurrentFit(),
                  child: SizedBox(
                    width: controller.videoController.value.size.width,
                    height: controller.videoController.value.size.height,
                    child: VideoPlayer(controller.videoController),
                  ),
                ),
              ),
            ),

            // Subtitle Layer
            if (controller.subtitlesEnabled)
              SubtitleLayer(controller: controller),

            // Gesture Layer with Controls
            VideoControls(controller: controller),

            // Indicators
            VideoIndicators(controller: controller),
          ],
        );
      },
    );
  }
}

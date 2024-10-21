import 'package:flutter/material.dart';
import 'package:zine_player/model/video.dart';
import 'package:zine_player/theme/app_theme.dart';
import 'package:zine_player/utils/format_utils.dart';
import 'package:zine_player/utils/strings.dart';

class VideoListItem extends StatelessWidget {
  final Video video;
  final Function(Video) onTap;
  final Function(Video) onFavoriteToggle;
  final Function(Video) onAddToPlaylist;
  final bool showFavoriteButton;
  final bool showAddToPlaylistButton;

  const VideoListItem({
    super.key,
    required this.video,
    required this.onFavoriteToggle,
    required this.onAddToPlaylist,
    this.showFavoriteButton = true,
    this.showAddToPlaylistButton = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: video.thumbnail != null
                ? Image.memory(video.thumbnail!, fit: BoxFit.cover)
                : const Icon(Icons.video_library, color: Colors.deepPurple),
          ),
        ),
        title: Text(
          video.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.duration.replaceFirst(
                '{duration}', FormatUtils.formatDuration(video.duration))),
            Text(AppStrings.size.replaceFirst(
                '{size}', FormatUtils.formatFileSize(video.size))),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFavoriteButton)
              IconButton(
                icon: Icon(
                  video.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: video.isFavorite ? AppTheme.primaryColor : null,
                ),
                onPressed: () => onFavoriteToggle(video),
              ),
            if (showAddToPlaylistButton)
              IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: () => onAddToPlaylist(video),
              ),
          ],
        ),
        onTap: () => onTap(video),
        // () {
          // Get.toNamed(
          //   ZPRouteNames.videoPlay,
          //   arguments: {
          //     'videoFile': video.uri,
          //     'videoTitle': video.name,
          //   },
          // );
        // },
      ),
    );
  }
}

// recently_played_mixin.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zine_player/controller/mixins/video_list_mixin.dart';
import 'package:zine_player/model/video.dart';

mixin RecentlyPlayedMixin on GetxController {
  List<Video> recentlyPlayed = [];
  static const String recentlyPlayedID = 'recentlyPlayed';

  Future<void> loadRecentlyPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayedJson =
        prefs.getStringList('recentlyPlayed') ?? [];
    recentlyPlayed = recentlyPlayedJson
        .map((json) => Video.fromMap(jsonDecode(json)))
        .toList()
      ..sort(
          (a, b) => b.lastPlayed?.compareTo(a.lastPlayed ?? DateTime(0)) ?? 0);
    update([recentlyPlayedID]);
  }

  Future<void> saveRecentlyPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayedJson =
        recentlyPlayed.map((video) => jsonEncode(video.toMap())).toList();
    await prefs.setStringList('recentlyPlayed', recentlyPlayedJson);
    update([
      recentlyPlayedID,
      VideoListMixin.videosID,
      VideoListMixin.favoritesID,
      VideoListMixin.playlistID,
      VideoListMixin.loadingID,
    ]);
  }

  void addToRecentlyPlayed(Video video) {
    video.lastPlayed = DateTime.now();
    recentlyPlayed.removeWhere((v) => v.id == video.id);
    recentlyPlayed.insert(0, video);
    if (recentlyPlayed.length > 10) {
      recentlyPlayed.removeLast();
    }
    saveRecentlyPlayed();
    update([recentlyPlayedID]);
  }

  Future<void> updateVideoPosition(Video video, Duration position) async {
    video.lastPosition = position;
    int index = recentlyPlayed.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      recentlyPlayed[index] = video;
      await saveRecentlyPlayed();
      update([recentlyPlayedID]);
    }
  }

  Future<void> clearRecentlyPlayed() async {
    recentlyPlayed.clear();
    await saveRecentlyPlayed();
    update([recentlyPlayedID]);
  }
}

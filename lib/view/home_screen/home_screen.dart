import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/view/home_screen/home_controller.dart';
import 'package:zine_player/view/settings/settigs_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          return controller.pages[controller.currentIndex.value];
        },
      ),
      bottomNavigationBar: GetBuilder<HomeController>(
        builder: (controller) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.currentIndex.value,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'Recent'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favorite'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_play), label: 'Playlist'),
            ],
          );
        },
      ),
    );
  }
}

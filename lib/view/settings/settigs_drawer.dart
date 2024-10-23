import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/routes/routes_name.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zine Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {
              Get.toNamed(ZPRouteNames.privacy);
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              // Show about dialog
              Get.defaultDialog(
                title: 'About',
                middleText: 'This app is developed by Muhammed Faseen C M.',
              );
            },
          ),
        ],
      ),
    );
  }
}

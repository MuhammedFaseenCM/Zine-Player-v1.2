import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zine_player/routes/routes.dart';
import 'package:zine_player/routes/routes_name.dart';
import 'package:zine_player/theme/app_theme.dart';
import 'package:zine_player/utils/strings.dart';
import 'package:zine_player/view/home_screen/home_binding.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: HomeBinding(),
      initialRoute: ZPRouteNames.home,
      getPages: ZPRoutes.routes,
    );
  }
}

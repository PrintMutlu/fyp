import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_new/provider/location_provider.dart';
import 'package:fyp_new/view/home_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controller/requirement_state_controller.dart';

void main() {
  runApp( ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: MainApp(),
  ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(RequirementStateController());

    final themeData = Theme.of(context);
    final primary = Colors.blue;

    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: primary,
        appBarTheme: themeData.appBarTheme.copyWith(
          elevation: 0.5,
          color: Colors.white,
          actionsIconTheme: themeData.primaryIconTheme.copyWith(
            color: primary,
          ),
          iconTheme: themeData.primaryIconTheme.copyWith(
            color: primary,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: primary,
      ),
      home: HomePage(),
    );
  }
}

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  final bool initialDarkMode;

  ThemeController({required this.initialDarkMode});

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = initialDarkMode;
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;

    Get.changeThemeMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }
}
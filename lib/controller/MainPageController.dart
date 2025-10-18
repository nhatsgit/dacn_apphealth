import 'package:dacn_app/pages/Overview/OverviewPage.dart';
import 'package:dacn_app/pages/Sleep/SleepPage.dart';
import 'package:dacn_app/pages/Water/WaterPage.dart';
import 'package:dacn_app/pages/Weight/WeightPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPageController extends GetxController {
  var selectedIndex = 0.obs;
  final List<Widget?> pages = [OverviewPage(), null, null, null];

  void updateIndex(int index) {
    selectedIndex.value = index;
    if (pages[index] == null) {
      pages[index] = getPage(index);
    }
  }

  Widget getPage(int index) {
    switch (index) {
      case 1:
        return WeightPage();
      case 2:
        return WaterPage();
      case 3:
        return SleepPage();
      default:
        return OverviewPage();
    }
  }
}

import 'package:dacn_app/pages/Auth/login.dart';
import 'package:dacn_app/pages/Auth/updateinfo.dart';
import 'package:dacn_app/pages/Diary/DiaryPage.dart';
import 'package:dacn_app/pages/Meal/AddMealRecordPage.dart';
import 'package:dacn_app/pages/Meal/FoodPage.dart';
import 'package:dacn_app/pages/Meal/MealRecordPage.dart';
import 'package:dacn_app/pages/Medication/MedicationPage.dart';
import 'package:dacn_app/pages/Overview/OverviewPage.dart';
import 'package:dacn_app/pages/Sleep/SleepPage.dart';
import 'package:dacn_app/pages/Water/WaterPage.dart';
import 'package:dacn_app/pages/Weight/WeightPage.dart';
import 'package:dacn_app/pages/Workout/ExcercisePage.dart';
import 'package:dacn_app/pages/Workout/WorkoutPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// NEW IMPORTS
import 'package:dacn_app/models/UserProfile.dart'; //
import 'package:dacn_app/services/UserServices.dart'; //
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainPageController extends GetxController {
  var selectedIndex = 0.obs;
  // Khai báo biến reactive cho UserProfile và trạng thái loading
  var userProfile = Rxn<UserProfile>(); //
  var isLoadingProfile = true.obs;

  final List<Widget?> pages = [
    OverviewPage(),
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile(); // Tải hồ sơ người dùng ngay khi Controller khởi tạo
  }

  // Hàm tải thông tin hồ sơ
  Future<void> fetchUserProfile() async {
    try {
      isLoadingProfile(true);
      // Giả định bạn có HttpRequest và UserService tương tự như các file khác
      final client = HttpRequest(http.Client());
      final profile = await UserService(client).fetchProfile(); //
      userProfile.value = profile;
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải thông tin hồ sơ: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingProfile(false);
    }
  }

  void updateIndex(int index) {
    selectedIndex.value = index;
    if (pages[index] == null) {
      pages[index] = getPage(index);
    }
  }

// ===============================================
  // 💡 HÀM ĐĂNG XUẤT MỚI
  // ===============================================
  Future<void> logout() async {
    try {
      // Xóa JWT khỏi SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Giả định JWT được lưu bằng key 'jwtToken' (hoặc key tương tự)
      await prefs.remove('jwt');

      // Thêm Get.deleteAll() để xóa Controller khỏi bộ nhớ (giúp giải phóng tài nguyên)
      Get.deleteAll();

      // Chuyển hướng đến LoginPage và xóa tất cả các trang khác
      Get.offAll(() => const LoginPage());
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể đăng xuất: $e",
          snackPosition: SnackPosition.BOTTOM);
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
      case 4:
        return ExercisePage();
      case 5:
        return MedicationPage();
      case 6:
        return WorkoutPage();
      case 7:
        // Thay thế ListFoodPage (không có import) bằng MealPage (có import)
        return FoodPage();
      case 9:
        // Thay thế ListFoodPage (không có import) bằng MealPage (có import)
        return MealRecordPage();
      case 8:
        // Thay thế ListFoodPage (không có import) bằng MealPage (có import)
        return UpdateInfoPage();
      default:
        return OverviewPage();
    }
  }
}

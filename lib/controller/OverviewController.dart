import 'package:dacn_app/models/IdealStats.dart';
import 'package:dacn_app/models/UserOverview.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/UserServices.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Thêm import này

class OverviewController extends GetxController {
  var userOverview = Rxn<UserOverview>();
  var idealStats = Rxn<IdealStats>();

  var isLoading = true.obs;

  // NEW: Trạng thái ngày được chọn (mặc định là hôm nay)
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu lần đầu với ngày hiện tại
    fetchData(selectedDate.value);
  }

  Future<void> fetchData(DateTime date) async {
    // NHẬN THAM SỐ DATE
    try {
      isLoading(true);
      final client = HttpRequest(http.Client());
      final userService = UserService(client);

      // Tải đồng thời: Overview theo ngày, Summary (Ideal Stats) thì không đổi
      final results = await Future.wait([
        userService.fetchOverview(date: date), // TRUYỀN DATE VÀO SERVICE
        userService.fetchSummary(),
      ]);

      userOverview.value = results[0] as UserOverview;
      idealStats.value = results[1] as IdealStats;
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể tải dữ liệu tổng quan: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ============== LOGIC CHUYỂN NGÀY ==================

  void goToPreviousDay() {
    // Giảm ngày đi 1
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    fetchData(selectedDate.value);
  }

  void goToNextDay() {
    DateTime nextDay = selectedDate.value.add(const Duration(days: 1));

    // So sánh ngày (chỉ cần so sánh ngày, tháng, năm)
    bool isToday = DateTime.now().year == selectedDate.value.year &&
        DateTime.now().month == selectedDate.value.month &&
        DateTime.now().day == selectedDate.value.day;

    if (!isToday) {
      selectedDate.value = nextDay;
      fetchData(selectedDate.value);
    }
  }

  // Getter để hiển thị tên ngày động: Today, Yesterday, hoặc dd/MM/yyyy
  String get formattedDateText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(selectedDate.value.year, selectedDate.value.month,
        selectedDate.value.day);

    if (date.isAtSameMomentAs(today)) {
      return "Hôm Nay";
    } else if (date.isAtSameMomentAs(yesterday)) {
      return "Hôm Qua";
    } else {
      // Định dạng ngày tháng
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // Kiểm tra xem có phải ngày hôm nay không (để vô hiệu hóa nút tiến)
  bool get isTodaySelected {
    final now = DateTime.now();
    return now.year == selectedDate.value.year &&
        now.month == selectedDate.value.month &&
        now.day == selectedDate.value.day;
  }

  // ============== LOGIC TÍNH TOÁN ==================

  double calculateProgress(double current, double ideal) {
    if (ideal <= 0 || current <= 0) return 0.0;
    return (current / ideal).clamp(0.0, 1.0);
  }

  double get waterProgress {
    if (userOverview.value == null || idealStats.value == null) return 0.0;
    return calculateProgress(
      userOverview.value!.waterToday.toDouble() / 1000,
      idealStats.value!.idealWaterMl / 1000,
    );
  }

  double get caloriesInProgress {
    if (userOverview.value == null || idealStats.value == null) return 0.0;
    return calculateProgress(
      userOverview.value!.caloriesInToday,
      idealStats.value!.idealCaloriesIn,
    );
  }

  double get caloriesOutProgress {
    if (userOverview.value == null || idealStats.value == null) return 0.0;
    return calculateProgress(
      userOverview.value!.caloriesOutToday,
      idealStats.value!.idealCaloriesOut,
    );
  }
}

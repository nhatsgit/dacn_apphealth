import 'dart:convert';
import 'package:dacn_app/models/IdealStats.dart';
import 'package:dacn_app/models/UserOverview.dart';
import 'package:dacn_app/models/UserProfile.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';

class UserService {
  final HttpRequest _request;

  UserService(this._request);

  /// GET /api/user/profile
  Future<UserProfile> fetchProfile() async {
    final response = await _request.get("user/profile");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  /// GET /api/user/ideal-weight
  Future<double> fetchIdealWeight() async {
    final response = await _request.get("user/ideal-weight");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception("Failed to load ideal weight");
    }
  }

  /// GET /api/user/ideal-water
  Future<double> fetchIdealWater() async {
    final response = await _request.get("user/ideal-water");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception("Failed to load ideal water");
    }
  }

  /// GET /api/user/ideal-calories-in
  Future<double> fetchIdealCaloriesIn() async {
    final response = await _request.get("user/ideal-calories-in");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception("Failed to load calories-in ideal");
    }
  }

  /// GET /api/user/ideal-calories-out
  Future<double> fetchIdealCaloriesOut() async {
    final response = await _request.get("user/ideal-calories-out");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception("Failed to load calories-out ideal");
    }
  }

  /// GET /api/user/summary
  Future<IdealStats> fetchSummary() async {
    final response = await _request.get("user/summary");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return IdealStats.fromJson(data);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  /// GET /api/user/overview
  Future<UserOverview> fetchOverview({DateTime? date}) async {
    // NHẬN THAM SỐ DATE
    String endpoint = "user/overview";
    if (date != null) {
      // Định dạng ngày tháng theo chuẩn YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      endpoint += "?date=$formattedDate";
    }

    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserOverview.fromJson(data);
    } else {
      throw Exception("Failed to load overview");
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? gender,
    String? dateOfBirth,
    double? height,
  }) async {
    final body = {
      "fullName": fullName,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "height": height,
      // Lưu ý: LatestWeight KHÔNG được gửi lên vì nó là record riêng
    };

    // Loại bỏ các giá trị null khỏi body trước khi gửi (tùy chọn)
    final Map<String, dynamic> filteredBody = body.entries
        .where((e) => e.value != null)
        .fold({}, (map, e) => map..[e.key] = e.value);

    final response = await _request.put("user/profile", filteredBody);

    if (response.statusCode != 200) {
      // API C# trả về 200 Ok, nếu không phải 200 thì là lỗi
      throw Exception("Failed to update user profile: ${response.body}");
    }
    // Nếu thành công (statusCode 200), không cần trả về gì.
  }
}

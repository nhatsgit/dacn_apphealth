import 'dart:convert';
// Giả định bạn đã import đúng đường dẫn cho các model
import 'package:dacn_app/models/Medication.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';

class MedicationService {
  final HttpRequest _request;
  static const String _basePath =
      "medications"; // Tương ứng với [Route("api/[controller]")] => api/medications

  MedicationService(this._request);

  // ✅ GET /api/medications?active=true&date=2025-10-16&pageNumber=1&pageSize=10
  /// Lấy danh sách nhắc nhở thuốc. Chỉ trả về Data (List<MedicationReminder>),
  /// nhưng vẫn sử dụng tham số phân trang để gọi API.
  Future<List<MedicationReminder>> fetchMedications({
    bool? active,
    DateTime? date,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    // Xây dựng chuỗi query string với các tham số phân trang
    final Map<String, dynamic> queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (active != null) {
      queryParams['active'] = active.toString();
    }
    if (date != null) {
      // Định dạng DateOnly theo chuẩn YYYY-MM-DD
      queryParams['date'] = DateFormat('yyyy-MM-dd').format(date);
    }

    final String queryString = Uri(queryParameters: queryParams).query;
    final String endpoint = "$_basePath?$queryString";

    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Sử dụng MedicationPagingResult để parse toàn bộ cấu trúc response...
      final pagingResult = MedicationPagingResult.fromJson(data);

      // ... nhưng CHỈ TRẢ VỀ danh sách thuốc (Data)
      return pagingResult.data;
    } else {
      throw Exception("Failed to load medication reminders: ${response.body}");
    }
  }

  // ✅ GET /api/medications/{id}
  /// Lấy thông tin nhắc nhở thuốc bằng Id.
  Future<MedicationReminder> fetchMedicationById(int id) async {
    final response = await _request.get("$_basePath/$id");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MedicationReminder.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("Medication reminder not found.");
    } else {
      throw Exception("Failed to load medication reminder: ${response.body}");
    }
  }

  // ✅ POST /api/medications
  /// Tạo nhắc nhở thuốc mới.
  Future<MedicationReminder> createMedication(
      CreateMedicationReminderDto dto) async {
    final body = dto.toJson();
    final response = await _request.post(_basePath, body);

    if (response.statusCode == 201) {
      // CreatedAtAction trả về 201 Created
      final data = json.decode(response.body);
      return MedicationReminder.fromJson(data);
    } else {
      throw Exception("Failed to create medication reminder: ${response.body}");
    }
  }

  // ✅ PUT /api/medications/{id}
  /// Cập nhật nhắc nhở thuốc.
  Future<void> updateMedication(int id, CreateMedicationReminderDto dto) async {
    final body = dto.toJson();
    final response = await _request.put("$_basePath/$id", body);

    if (response.statusCode != 204) {
      // Trả về 204 NoContent nếu thành công
      throw Exception("Failed to update medication reminder: ${response.body}");
    }
  }

  // ✅ DELETE /api/medications/{id}
  /// Xóa nhắc nhở thuốc.
  Future<void> deleteMedication(int id) async {
    final response = await _request.delete("$_basePath/$id");

    if (response.statusCode != 204) {
      // Trả về 204 NoContent nếu thành công
      throw Exception("Failed to delete medication reminder: ${response.body}");
    }
  }
}

// File: lib/models/AddWeightRequest.dart

import 'dart:convert';

class AddWeightRequest {
  final double weight;
  final String date; // Yêu cầu ở định dạng ISO 8601: YYYY-MM-DDTHH:mm:ss
  final String? note;

  AddWeightRequest({
    required this.weight,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'date': date,
      'note': note,
    };
  }

  String toEncodedJson() {
    return json.encode(toJson());
  }
}

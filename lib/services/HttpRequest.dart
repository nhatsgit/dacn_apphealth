import 'package:dacn_app/services/ApiConfig.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HttpRequest {
  final http.Client _client;

  HttpRequest(this._client);

  Future<http.Response> get(String endpoint) async {
    final token = await getJwt();
    final url = Uri.parse('${ApiConfig.baseAPIUrl}$endpoint');
    final response = await _client.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    return _handleResponse(response);
  }

  Future<http.Response> post(
      String endpoint, Map<String, dynamic>? body) async {
    final token = await getJwt();
    final url = Uri.parse('${ApiConfig.baseAPIUrl}$endpoint');
    final response = await _client.post(
      url,
      body: body != null ? json.encode(body) : null,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await getJwt();
    final url = Uri.parse('${ApiConfig.baseAPIUrl}$endpoint');
    final response = await _client.put(
      url,
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await getJwt();
    final url = Uri.parse('${ApiConfig.baseAPIUrl}$endpoint');
    final response = await _client.delete(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    return _handleResponse(response);
  }

  Future<String?> getJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await _logout();
      _redirectToLogin();
    }
    return response;
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }

  void _redirectToLogin() {
    Get.deleteAll();

    Get.offAllNamed('/login');
  }
}

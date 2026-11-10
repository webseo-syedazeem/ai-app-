import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiClient {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  String baseUrl;
  String userId;

  BackendApiClient({
    this.baseUrl = defaultBaseUrl,
    this.userId = '00000000-0000-0000-0000-000000000001',
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-user-id': userId,
      };

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 6));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 6));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

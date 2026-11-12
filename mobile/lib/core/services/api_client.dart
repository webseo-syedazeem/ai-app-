import 'dart:convert';
import 'package:http/http.dart' as http;

typedef ApiResult = ({
  bool ok,
  int statusCode,
  Map<String, dynamic>? data,
  String? error,
});

class BackendApiClient {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ai-app-two-liart.vercel.app/api',
  );

  String baseUrl;
  String userId;
  String? authToken;

  BackendApiClient({
    this.baseUrl = defaultBaseUrl,
    this.userId = '00000000-0000-0000-0000-000000000001',
    this.authToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-user-id': userId,
        if (authToken != null && authToken!.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      };

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  ApiResult _parseResult(http.Response res) {
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    } catch (_) {}

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    String? err;
    if (!ok) {
      final rawErr = json?['error'];
      if (rawErr is String && rawErr.trim().isNotEmpty) {
        err = rawErr.trim();
      } else {
        err = 'Request failed (${res.statusCode}). Please try again.';
      }
    }
    return (ok: ok, statusCode: res.statusCode, data: json, error: err);
  }

  Future<ApiResult> postResult(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 18));
      return _parseResult(res);
    } catch (_) {
      return (
        ok: false,
        statusCode: 0,
        data: null,
        error: 'Unable to reach server. Please check your connection.',
      );
    }
  }

  Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body) async {
    final result = await postResult(path, body);
    return result.ok ? result.data : null;
  }

  Future<Map<String, dynamic>?> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

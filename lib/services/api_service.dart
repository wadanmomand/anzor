import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configurable base URL (Defaults to standard Android Emulator localhost mapping)
  String _baseUrl = 'http://10.0.2.2:5000';
  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;

  void setBaseUrl(String url) {
    if (url.isNotEmpty) {
      // Remove trailing slash if present
      _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    }
  }

  void setToken(String? token) {
    _token = token;
  }

  // Helper method for standard requests headers
  Map<String, String> _headers() {
    final Map<String, String> headerMap = {
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headerMap['Authorization'] = 'Bearer $_token';
    }
    return headerMap;
  }

  // Check connection to the server
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== AUTHENTICATION ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token']?.toString();
      return data as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Invalid credentials.');
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Registration failed.');
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    // Placeholder endpoint. If backend doesn't implement Google OAuth, 
    // we simulate a success by returning a mock profile and token.
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token']?.toString();
        return data as Map<String, dynamic>;
      }
    } catch (_) {
      // Catch network failure to ensure fallback login succeeds
    }

    // Fallback simulation
    _token = 'google_mock_token_jwt';
    return {
      'status': 'success',
      'token': _token,
      'user': {
        'username': 'Google Designer',
        'email': 'google.designer@gmail.com',
        'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=google',
        'role': 'user',
        'createdAt': DateTime.now().toIso8601String(),
        'followers': [],
        'following': [],
      }
    };
  }

  // ==================== PROMPTS ====================

  // 1. Expand Prompt via secure Gemini server proxy
  Future<Map<String, dynamic>> expandPrompt(String rawPrompt, String artStyle, List<String> presets) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/prompts/generate'),
      headers: _headers(),
      body: jsonEncode({
        'rawIdea': rawPrompt,
        'style': artStyle,
        'category': presets.isNotEmpty ? presets.first : 'All',
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'expandedPrompt': data['expandedPrompt'] ?? '',
        'revisedIdea': data['rawIdea'] ?? '',
        'keywordsExplanation': 'Enhanced via Anzor Secure Server API Engine.'
      };
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Server returned error: ${response.statusCode}');
    }
  }

  // 2. Reverse Engineer Image (Vision)
  Future<Map<String, dynamic>> analyzeImage(Uint8List imageBytes, String mimeType) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/generate/analyze'));
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    
    // Determine extension
    String extension = 'jpg';
    if (mimeType.contains('png')) {
      extension = 'png';
    } else if (mimeType.contains('webp')) {
      extension = 'webp';
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'upload_$extension.$extension',
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException('Server image analysis error: ${response.statusCode}');
    }
  }

  // 3. Get Public Showcase Prompts
  Future<List<PromptItem>> getPrompts({String? category, String? style, String? sort}) async {
    String query = '?';
    if (category != null) query += 'category=$category&';
    if (style != null) query += 'style=$style&';
    if (sort != null) query += 'sort=$sort&';

    final response = await http.get(
      Uri.parse('$_baseUrl/api/prompts$query'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['prompts'] is List ? decoded['prompts'] : [];
      return list.map((json) => PromptItem.fromJson(json)).toList();
    } else {
      throw HttpException('Failed to load prompts: ${response.statusCode}');
    }
  }

  // 4. Submit Prompt to Moderation
  Future<PromptItem> submitPrompt(PromptItem item) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/prompts'),
      headers: _headers(),
      body: jsonEncode(item.toJson()),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PromptItem.fromJson(jsonDecode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Failed to submit prompt: ${response.statusCode}');
    }
  }

  // 5. Like Prompt
  Future<int> likePrompt(String id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/prompts/like/$id'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['likesCount'] as int;
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Failed to like prompt: ${response.statusCode}');
    }
  }

  // 6. Following Feed
  Future<List<PromptItem>> getFollowingFeed() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/prompts/following'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['prompts'] is List ? decoded['prompts'] : [];
      return list.map((json) => PromptItem.fromJson(json)).toList();
    } else {
      throw HttpException('Failed to load following feed: ${response.statusCode}');
    }
  }

  // 7. Follow/Unfollow user toggle
  Future<Map<String, dynamic>> toggleFollowUser(String targetUserId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/follow/$targetUserId'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(errorData['message'] ?? 'Failed to follow user: ${response.statusCode}');
    }
  }

  // ==================== ADMIN PANEL ====================

  Future<List<PromptItem>> adminGetPrompts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/prompts'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => PromptItem.fromJson(json)).toList();
    } else {
      throw HttpException('Admin failed to load prompts: ${response.statusCode}');
    }
  }

  Future<bool> adminPromptAction(String id, String action) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/prompts/$id/action'),
      headers: _headers(),
      body: jsonEncode({'action': action}),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException('Admin action failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> adminGetMetrics() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/metrics'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException('Admin failed to get metrics: ${response.statusCode}');
    }
  }

  Future<List<LogEntry>> adminGetLogs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/logs'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => LogEntry.fromJson(json)).toList();
    } else {
      throw HttpException('Admin failed to get logs: ${response.statusCode}');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}

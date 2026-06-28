import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLocale = 'app_locale';
  static const String _keyGeminiKey = 'gemini_api_key';
  static const String _keyAuthUser = 'auth_user';

  // Obtain file handles (Android/iOS only)
  Future<File> _getFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  // Generic file writer with Web LocalStorage fallback
  Future<void> _writeJsonToFile(String filename, dynamic data) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('web_db_$filename', jsonEncode(data));
        return;
      }
      final file = await _getFile(filename);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error writing to $filename: $e');
    }
  }

  // Generic file reader with Web LocalStorage fallback
  Future<dynamic> _readJsonFromFile(String filename) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final content = prefs.getString('web_db_$filename');
        if (content == null) return null;
        return jsonDecode(content);
      }
      final file = await _getFile(filename);
      if (!await file.exists()) {
        return null;
      }
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      print('Error reading from $filename: $e');
      return null;
    }
  }

  // ==================== SHAPED PREFERENCES ====================

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'dark'; // Defaults to premium Dark Mode
  }

  Future<void> saveLocale(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, lang);
  }

  Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocale) ?? 'en'; // Defaults to English
  }

  Future<void> saveGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGeminiKey, key);
  }

  Future<String> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGeminiKey) ?? '';
  }

  Future<void> saveAuthUser(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keyAuthUser);
    } else {
      await prefs.setString(_keyAuthUser, jsonEncode(user));
    }
  }

  Future<Map<String, dynamic>?> getAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_keyAuthUser);
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ==================== FILE DATA PERSISTENCE ====================

  // Prompt History
  Future<void> saveHistory(List<HistoryItem> history) async {
    final jsonList = history.map((item) => item.toJson()).toList();
    await _writeJsonToFile('history.json', jsonList);
  }

  Future<List<HistoryItem>> loadHistory() async {
    final data = await _readJsonFromFile('history.json');
    if (data == null || data is! List) return [];
    return data.map((json) => HistoryItem.fromJson(json)).toList();
  }

  // Saved Custom Collections
  Future<void> saveCollections(List<CollectionItem> collections) async {
    final jsonList = collections.map((item) => item.toJson()).toList();
    await _writeJsonToFile('collections.json', jsonList);
  }

  Future<List<CollectionItem>> loadCollections() async {
    final data = await _readJsonFromFile('collections.json');
    if (data == null || data is! List) return [];
    return data.map((json) => CollectionItem.fromJson(json)).toList();
  }

  // Bookmarked / Saved prompts full details (for offline viewing in community/collections)
  Future<void> saveOfflineSavedPrompts(List<PromptItem> prompts) async {
    final jsonList = prompts.map((item) => item.toJson()).toList();
    await _writeJsonToFile('bookmarked_prompts.json', jsonList);
  }

  Future<List<PromptItem>> loadOfflineSavedPrompts() async {
    final data = await _readJsonFromFile('bookmarked_prompts.json');
    if (data == null || data is! List) return [];
    return data.map((json) => PromptItem.fromJson(json)).toList();
  }
}

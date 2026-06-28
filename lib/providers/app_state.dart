import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final ApiService _api = ApiService();
  final GeminiService _gemini = GeminiService();

  // Settings & Localization
  String _locale = 'en';
  String _themeModeString = 'dark';
  String _geminiApiKey = '';
  String _backendUrlSetting = 'http://10.0.2.2:5000';
  bool _isOnline = false;
  bool _isLoading = false;
  int _activeTab = 0;

  String get locale => _locale;
  String get themeModeString => _themeModeString;
  String get geminiApiKey => _geminiApiKey;
  String get backendUrlSetting => _backendUrlSetting;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  int get activeTab => _activeTab;

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }


  ThemeMode get themeMode {
    if (_themeModeString == 'dark') return ThemeMode.dark;
    if (_themeModeString == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  // Authentication State
  Map<String, dynamic>? _currentUser;
  bool _isGuest = false;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _currentUser != null || _isGuest;
  bool get isAdmin => _currentUser != null && _currentUser!['role'] == 'admin';

  // AI Prompt Studio States
  String _originalIdea = '';
  String _expandedPrompt = '';
  String _creativeEnhancement = '';
  String _keywordsExplanation = '';
  List<String> _selectedStyles = [];
  List<String> _selectedPresets = [];
  bool _isStudioLoading = false;

  String get originalIdea => _originalIdea;
  String get expandedPrompt => _expandedPrompt;
  String get creativeEnhancement => _creativeEnhancement;
  String get keywordsExplanation => _keywordsExplanation;
  List<String> get selectedStyles => _selectedStyles;
  List<String> get selectedPresets => _selectedPresets;
  bool get isStudioLoading => _isStudioLoading;

  // AI Vision Reverse Engineering States
  bool _isVisionLoading = false;
  Map<String, dynamic>? _visionResult;
  Uint8List? _selectedVisionImage;

  bool get isVisionLoading => _isVisionLoading;
  Map<String, dynamic>? get visionResult => _visionResult;
  Uint8List? get selectedVisionImage => _selectedVisionImage;

  // History & Collections Data
  List<HistoryItem> _historyList = [];
  List<CollectionItem> _collections = [];
  List<PromptItem> _savedPrompts = []; // Bookmarks

  List<HistoryItem> get historyList => _historyList;
  List<CollectionItem> get collections => _collections;
  List<PromptItem> get savedPrompts => _savedPrompts;

  // Community Feed State
  List<PromptItem> _communityPrompts = [];
  List<PromptItem> _followingPrompts = [];
  String _activeCategoryFilter = 'All';

  List<PromptItem> get communityPrompts => _communityPrompts;
  String get activeCategoryFilter => _activeCategoryFilter;

  List<PromptItem> get filteredPrompts {
    if (_activeCategoryFilter == 'All') {
      return _communityPrompts;
    }
    return _communityPrompts.where((p) => p.category.toLowerCase() == _activeCategoryFilter.toLowerCase()).toList();
  }

  // Returns all prompts submitted by the currently logged-in user
  List<PromptItem> get userCreations {
    final name = _currentUser?['username'] ?? 'Anonymous';
    final approved = _communityPrompts.where((p) => p.author == name).toList();
    final pending = _adminPrompts.where((p) => p.author == name).toList();
    return [...pending, ...approved];
  }

  // Admin Dashboard States
  List<PromptItem> _adminPrompts = [];
  Map<String, dynamic> _serverMetrics = {
    'uptime': '0h 0m 0s',
    'systemHealth': 'Healthy',
    'memoryUsedMB': 0.0,
    'memoryTotalMB': 0.0,
    'nodeVersion': 'N/A',
    'totalGenerations': 0,
    'averageLatencyMs': 0,
    'errorRate': '0%'
  };
  List<LogEntry> _serverLogs = [];
  bool _isAdminLoading = false;

  List<PromptItem> get adminPrompts => _adminPrompts;
  Map<String, dynamic> get serverMetrics => _serverMetrics;
  List<LogEntry> get serverLogs => _serverLogs;
  bool get isAdminLoading => _isAdminLoading;

  // Notification System (Typed NotificationItem)
  List<NotificationItem> _notifications = [];
  bool _hasUnreadNotifications = false;

  List<NotificationItem> get notifications => _notifications;
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  // Creators & Follows Database
  List<CreatorProfile> _creators = [];
  List<CreatorProfile> get creators => _creators;

  // Initialized Callback trigger
  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load basic preferences
    _locale = await _storage.getLocale();
    _themeModeString = await _storage.getThemeMode();
    _geminiApiKey = await _storage.getGeminiApiKey();
    _currentUser = await _storage.getAuthUser();
    if (_currentUser == null) {
      _isGuest = false;
    } else {
      _isGuest = _currentUser!['isGuest'] == true;
      if (_currentUser!['token'] != null) {
        _api.setToken(_currentUser!['token']?.toString());
      }
    }

    // 2. Load File Persisted Data
    _historyList = await _storage.loadHistory();
    _collections = await _storage.loadCollections();
    _savedPrompts = await _storage.loadOfflineSavedPrompts();

    // Setup initial default collection if empty
    if (_collections.isEmpty) {
      _collections.add(CollectionItem(id: 'col_fav', name: 'Favorites', promptIds: []));
      await _storage.saveCollections(_collections);
    }

    // 3. Test Backend and Load Community Prompts
    _api.setBaseUrl(_backendUrlSetting);
    _isOnline = await _api.testConnection();

    _initMockCreators();
    await refreshCommunityFeed();
    await refreshFollowingFeed();
    _loadMockNotifications();

    _isLoading = false;
    notifyListeners();

    // Start background sync polling if online
    if (_isOnline) {
      Timer.periodic(const Duration(seconds: 15), (timer) {
        if (_isOnline && isAdmin) {
          adminFetchMetricsAndLogs(silent: true);
        }
      });
    }
  }

  // ==================== SETTINGS OPERATIONS ====================

  Future<void> toggleLocale() async {
    _locale = _locale == 'en' ? 'ur_roman' : 'en';
    await _storage.saveLocale(_locale);
    notifyListeners();
  }

  Future<void> setThemeModeString(String mode) async {
    _themeModeString = mode;
    await _storage.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    await _storage.saveGeminiApiKey(key);
    notifyListeners();
  }

  Future<void> setBackendUrl(String url) async {
    _backendUrlSetting = url;
    _api.setBaseUrl(url);
    _isOnline = await _api.testConnection();
    await refreshCommunityFeed();
    notifyListeners();
  }

  // ==================== AUTHENTICATION OPERATIONS ====================

  Future<void> loginUser(String email, String password, bool demoAdmin) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        final res = await _api.login(email.trim(), password);
        _currentUser = res['user'] as Map<String, dynamic>;
        _currentUser!['token'] = res['token']?.toString();
        _api.setToken(res['token']?.toString());
      } else {
        await Future.delayed(const Duration(milliseconds: 1000)); // simulation
        final bool isUserAdmin = demoAdmin || email.trim().toLowerCase() == 'admin@anzor.ai';
        _currentUser = {
          'username': isUserAdmin ? 'Admin Principal' : email.split('@')[0],
          'email': email,
          'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=${email.hashCode}',
          'role': isUserAdmin ? 'admin' : 'user',
          'totalPrompts': isUserAdmin ? 25 : 4,
          'createdAt': DateTime.now().toIso8601String()
        };
      }
      _isGuest = false;

      await _storage.saveAuthUser(_currentUser);
      await refreshCommunityFeed();
      await refreshFollowingFeed();
      
      triggerSimulatedPushNotification(
        'Login Successful!',
        'Welcome back, ${_currentUser!['username']}. You are in ${isAdmin ? "Admin" : "Standard"} Mode.',
      );
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        final res = await _api.googleLogin('google_id_token_placeholder');
        _currentUser = res['user'] as Map<String, dynamic>;
        _currentUser!['token'] = res['token']?.toString();
        _api.setToken(res['token']?.toString());
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
        _currentUser = {
          'username': 'Google Designer',
          'email': 'google.designer@gmail.com',
          'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=google',
          'role': 'user',
          'totalPrompts': 1,
          'createdAt': DateTime.now().toIso8601String()
        };
      }
      _isGuest = false;

      await _storage.saveAuthUser(_currentUser);
      await refreshCommunityFeed();
      await refreshFollowingFeed();

      triggerSimulatedPushNotification(
        'Google Login Complete',
        'Welcome Google Designer, synced with Anzor Cloud.',
      );
    } catch (e) {
      print('Google Login Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginGuest() async {
    _isGuest = true;
    _currentUser = null;
    _api.setToken(null);
    await _storage.saveAuthUser({'isGuest': true});
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isGuest = false;
    _api.setToken(null);
    await _storage.saveAuthUser(null);
    notifyListeners();
  }

  Future<void> updateUserProfile({required String username, String? avatarBase64, String? coverBase64, String? bio}) async {
    if (_currentUser == null) {
      _currentUser = {
        'username': username,
        'email': 'guest.user@anzor.ai',
        'avatar': avatarBase64 ?? 'https://api.dicebear.com/7.x/bottts/png?seed=guest',
        'coverBanner': coverBase64 ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80',
        'role': 'user',
        'totalPrompts': 0,
        'bio': bio ?? 'AI prompt enthusiast sharing my creative explorations with the world.',
        'createdAt': DateTime.now().toIso8601String()
      };
    } else {
      _currentUser = Map<String, dynamic>.from(_currentUser!);
      _currentUser!['username'] = username;
      if (avatarBase64 != null) {
        _currentUser!['avatar'] = avatarBase64;
      }
      if (coverBase64 != null) {
        _currentUser!['coverBanner'] = coverBase64;
      }
      if (bio != null) {
        _currentUser!['bio'] = bio;
      }
    }

    final oldName = currentUserProfile.username;
    final myProfileIndex = _creators.indexWhere((c) => c.username == oldName || c.username == username);
    if (myProfileIndex != -1) {
      _creators[myProfileIndex] = _creators[myProfileIndex].copyWith(
        username: username,
        avatar: avatarBase64 ?? _creators[myProfileIndex].avatar,
        coverBanner: coverBase64 ?? _creators[myProfileIndex].coverBanner,
        bio: bio ?? _creators[myProfileIndex].bio,
      );
    } else {
      final name = _currentUser!['username'];
      final avatar = _currentUser!['avatar'];
      final cover = _currentUser!['coverBanner'] ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80';
      final userBio = _currentUser!['bio'] ?? 'AI prompt enthusiast sharing my creative explorations with the world.';
      final newProfile = CreatorProfile(
        username: name,
        avatar: avatar,
        coverBanner: cover,
        bio: userBio,
        joinDate: 'June 2026',
        followers: [],
        following: ['NeonKitten', 'ArtisticSoul'],
      );
      _creators.add(newProfile);
    }

    await _storage.saveAuthUser(_currentUser);
    notifyListeners();
  }

  // ==================== AI GENERATOR OPERATIONS ====================

  void toggleStyle(String style) {
    if (_selectedStyles.contains(style)) {
      _selectedStyles.remove(style);
    } else {
      _selectedStyles.add(style);
    }
    notifyListeners();
  }

  void togglePreset(String preset) {
    if (_selectedPresets.contains(preset)) {
      _selectedPresets.remove(preset);
    } else {
      _selectedPresets.add(preset);
    }
    notifyListeners();
  }

  void clearGeneratorInputs() {
    _selectedStyles.clear();
    _selectedPresets.clear();
    notifyListeners();
  }

  void setOriginalIdeaAction(String idea) {
    _originalIdea = idea;
    notifyListeners();
  }

  Future<void> generatePromptAction(String idea) async {
    if (idea.trim().isEmpty) return;
    _originalIdea = idea;
    _isStudioLoading = true;
    notifyListeners();

    final String styleSelected = _selectedStyles.isNotEmpty ? _selectedStyles.first : 'Cinematic';

    try {
      Map<String, dynamic> result;
      if (_isOnline) {
        result = await _api.expandPrompt(idea, styleSelected, _selectedPresets);
      } else {
        result = await _gemini.generatePrompt(
          rawIdea: idea,
          apiKey: _geminiApiKey,
          artStyle: styleSelected,
          presets: _selectedPresets,
        );
      }

      _expandedPrompt = result['expandedPrompt'] ?? '';
      _creativeEnhancement = result['revisedIdea'] ?? '';
      _keywordsExplanation = result['keywordsExplanation'] ?? '';

      // Add to History list
      final newHistory = HistoryItem(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        rawIdea: idea,
        expandedPrompt: _expandedPrompt,
        explanation: _keywordsExplanation,
        style: styleSelected,
        presets: List.from(_selectedPresets),
        date: DateTime.now().toIso8601String(),
      );

      _historyList.insert(0, newHistory);
      await _storage.saveHistory(_historyList);

      // Log in offline metrics simulation
      if (!_isOnline) {
        _addOfflineLog('INFO', 'Gemini AI', 'Successfully expanded raw idea: "$idea" via Direct Gemini.');
      }
    } catch (e) {
      print('Generation Error: $e');
      _expandedPrompt = 'Error generating prompt. Check internet connection or Gemini key.';
      _creativeEnhancement = 'Failed to load enhancement.';
      _keywordsExplanation = e.toString();
    } finally {
      _isStudioLoading = false;
      notifyListeners();
    }
  }

  // ==================== IMAGE REVERSE ENGINEERING ====================

  void setVisionImage(Uint8List? bytes) {
    _selectedVisionImage = bytes;
    _visionResult = null;
    notifyListeners();
  }

  Future<void> analyzeVisionImage(String mimeType) async {
    if (_selectedVisionImage == null) return;
    _isVisionLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> result;
      if (_isOnline) {
        result = await _api.analyzeImage(_selectedVisionImage!, mimeType);
      } else {
        result = await _gemini.analyzeImage(
          imageBytes: _selectedVisionImage!,
          mimeType: mimeType,
          apiKey: _geminiApiKey,
        );
      }

      _visionResult = result;

      if (!_isOnline) {
        _addOfflineLog('INFO', 'Gemini AI', 'Image reverse-engineering analyze complete.');
      }
    } catch (e) {
      print('Vision Analyze Error: $e');
      _visionResult = {
        'prompt': 'Failed to reverse engineer image. Details: ${e.toString()}',
        'style': 'Error',
        'composition': 'Connection timed out',
        'lighting': 'N/A',
        'colors': 'N/A'
      };
    } finally {
      _isVisionLoading = false;
      notifyListeners();
    }
  }

  // ==================== COMMUNITY SHOWCASE & LIKES ====================

  void setCategoryFilter(String category) {
    _activeCategoryFilter = category;
    notifyListeners();
  }

  Future<void> refreshCommunityFeed() async {
    try {
      if (_isOnline) {
        _communityPrompts = await _api.getPrompts();
      } else {
        // standalone mock feed
        _communityPrompts = _getMockCommunityPrompts();
      }
    } catch (e) {
      print('Failed to refresh feed: $e');
      _communityPrompts = _getMockCommunityPrompts();
    }
    
    // Initialize isLikedByMe and likesCount for each community prompt
    final currentUsername = _currentUser?['username'] ?? 'Creative Guest';
    for (var i = 0; i < _communityPrompts.length; i++) {
      final p = _communityPrompts[i];
      _communityPrompts[i] = p.copyWith(
        isLikedByMe: p.likesList.contains(currentUsername),
        likesCount: p.likes,
      );
    }
    notifyListeners();
  }

  Future<void> refreshFollowingFeed() async {
    try {
      if (_isOnline) {
        _followingPrompts = await _api.getFollowingFeed();
        final currentUsername = _currentUser?['username'] ?? 'Creative Guest';
        for (var i = 0; i < _followingPrompts.length; i++) {
          final p = _followingPrompts[i];
          _followingPrompts[i] = p.copyWith(
            isLikedByMe: p.likesList.contains(currentUsername),
            likesCount: p.likes,
          );
        }
      }
    } catch (e) {
      print('Failed to refresh following feed: $e');
    }
    notifyListeners();
  }

  Future<void> likePromptAction(String id) async {
    await toggleLikePrompt(id);
  }

  Future<void> dislikePromptAction(String id) async {
    try {
      final index = _communityPrompts.indexWhere((p) => p.id == id);
      if (index != -1) {
        // Local simulation for dislikes
        _communityPrompts[index].dislikes += 1;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to dislike prompt: $e');
    }
  }

  // Submit prompt screen handler supporting image bytes encoding in Base64
  Future<bool> submitPromptAction({
    required String title,
    required String description,
    required String promptText,
    required String category,
    required String style,
    required String author,
    Uint8List? imageBytes,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    String finalImage = imageUrl ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80';
    if (imageBytes != null) {
      finalImage = 'data:image/jpeg;base64,' + base64Encode(imageBytes);
    }

    final String authorName = author.isEmpty ? currentUserProfile.username : author;
    final String authorPic = authorName == currentUserProfile.username 
        ? currentUserProfile.avatar 
        : 'https://api.dicebear.com/7.x/bottts/png?seed=$authorName';

    final newPrompt = PromptItem(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      prompt: promptText,
      description: description,
      author: authorName,
      authorAvatar: authorPic,
      category: category,
      style: style,
      likes: 0,
      dislikes: 0,
      status: 'pending',
      image: finalImage,
      createdAt: DateTime.now().toIso8601String(),
      likesList: [],
      savesList: [],
      commentsList: [],
    );

    try {
      if (_isOnline) {
        final createdPrompt = await _api.submitPrompt(newPrompt);
        _adminPrompts.insert(0, createdPrompt);
      } else {
        // Save to temporary offline admin queue
        _adminPrompts.insert(0, newPrompt);
        _addOfflineLog('INFO', 'System', 'New offline prompt submission: "$title" by $author');
      }

      // Trigger moderation simulation push notification in 4 seconds
      Timer(const Duration(seconds: 4), () {
        triggerSimulatedPushNotification(
          'Prompt Under Review!',
          'Your prompt "${title.substring(0, min(15, title.length))}..." is successfully submitted for approval.',
        );
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Submit error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== COLLECTIONS & BOOKMARKS ====================

  bool isBookmarked(String promptId) {
    return _savedPrompts.any((p) => p.id == promptId);
  }

  Future<void> toggleBookmark(PromptItem prompt) async {
    final exists = _savedPrompts.any((p) => p.id == prompt.id);
    if (exists) {
      _savedPrompts.removeWhere((p) => p.id == prompt.id);
      // Remove from Favorites list representation
      final favIndex = _collections.indexWhere((c) => c.id == 'col_fav');
      if (favIndex != -1) {
        _collections[favIndex].promptIds.remove(prompt.id);
      }
    } else {
      _savedPrompts.add(prompt);
      final favIndex = _collections.indexWhere((c) => c.id == 'col_fav');
      if (favIndex != -1) {
        _collections[favIndex].promptIds.add(prompt.id);
      }
    }

    await _storage.saveOfflineSavedPrompts(_savedPrompts);
    await _storage.saveCollections(_collections);
    notifyListeners();
  }

  Future<void> createCollection(String name) async {
    if (name.trim().isEmpty) return;
    final newCol = CollectionItem(
      id: 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      promptIds: [],
    );
    _collections.add(newCol);
    await _storage.saveCollections(_collections);
    notifyListeners();
  }

  Future<void> addPromptToCollection(String promptId, String collectionId) async {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1 && !_collections[index].promptIds.contains(promptId)) {
      _collections[index].promptIds.add(promptId);
      await _storage.saveCollections(_collections);
      notifyListeners();
    }
  }

  Future<void> removePromptFromCollection(String promptId, String collectionId) async {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      _collections[index].promptIds.remove(promptId);
      await _storage.saveCollections(_collections);
      notifyListeners();
    }
  }

  Future<void> updateHistoryItem(HistoryItem updatedItem) async {
    final idx = _historyList.indexWhere((h) => h.id == updatedItem.id);
    if (idx != -1) {
      _historyList[idx] = updatedItem;
      await _storage.saveHistory(_historyList);
      notifyListeners();
    }
  }

  // ==================== ADMIN PANEL DASHBOARD ====================

  Future<void> fetchAdminData() async {
    _isAdminLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        _adminPrompts = await _api.adminGetPrompts();
        _serverMetrics = await _api.adminGetMetrics();
        _serverLogs = await _api.adminGetLogs();
      } else {
        // Mock standalone admin data
        if (_adminPrompts.isEmpty) {
          _adminPrompts = _getMockAdminPrompts();
        }
        _serverMetrics = _getMockMetrics();
        if (_serverLogs.isEmpty) {
          _serverLogs = _getMockLogs();
        }
      }
    } catch (e) {
      print('Admin Load Error: $e');
    } finally {
      _isAdminLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminFetchMetricsAndLogs({bool silent = false}) async {
    if (!silent) {
      _isAdminLoading = true;
      notifyListeners();
    }

    try {
      if (_isOnline) {
        _serverMetrics = await _api.adminGetMetrics();
        _serverLogs = await _api.adminGetLogs();
      } else {
        _serverMetrics = _getMockMetrics();
        // Generate a random simulated log entry to keep logs active and live
        _addOfflineLog(
          _getRandomLogLevel(),
          _getRandomLogSource(),
          _getRandomLogMessage(),
        );
      }
    } catch (e) {
      print('Admin telemetry update fail: $e');
    } finally {
      if (!silent) {
        _isAdminLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> adminModeratePrompt(String id, String action) async {
    _isAdminLoading = true;
    notifyListeners();

    try {
      bool success = false;
      if (_isOnline) {
        success = await _api.adminPromptAction(id, action);
      } else {
        success = true;
      }

      if (success) {
        final promptIdx = _adminPrompts.indexWhere((p) => p.id == id);
        if (promptIdx != -1) {
          final prompt = _adminPrompts[promptIdx];
          
          if (action == 'approve') {
            final approvedItem = prompt.copyWith(status: 'approved');
            _communityPrompts.insert(0, approvedItem);
            _adminPrompts[promptIdx] = approvedItem;
            _addOfflineLog('INFO', 'System', 'Admin approved prompt: "${prompt.title}"');

            // Simulated push notification for success approval
            Timer(const Duration(milliseconds: 1500), () {
              triggerSimulatedPushNotification(
                'Prompt Approved! 🌟',
                'Your prompt "${prompt.title}" has been approved and is now live in the Community Hub.',
              );
            });

          } else if (action == 'reject') {
            _adminPrompts[promptIdx] = prompt.copyWith(status: 'rejected');
            _addOfflineLog('INFO', 'System', 'Admin rejected prompt: "${prompt.title}"');
          } else if (action == 'delete') {
            _adminPrompts.removeAt(promptIdx);
            _communityPrompts.removeWhere((p) => p.id == id);
            _addOfflineLog('INFO', 'System', 'Admin deleted prompt ID: $id');
          }
        }
      }
    } catch (e) {
      print('Admin Moderation Error: $e');
    } finally {
      _isAdminLoading = false;
      notifyListeners();
    }
  }

  // ==================== SIMULATED NOTIFICATION SYSTEM ====================

  void _loadMockNotifications() {
    _notifications = [
      NotificationItem(
        id: 'not_1',
        type: 'follow',
        senderName: 'NeonKitten',
        senderAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
        message: 'started following your creations.',
        timestamp: '10 minutes ago',
        read: false,
      ),
      NotificationItem(
        id: 'not_2',
        type: 'like',
        senderName: 'RetroRider',
        senderAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
        message: 'liked your prompt "Cyberpunk Teahouse".',
        timestamp: '2 hours ago',
        read: true,
      ),
    ];
    _hasUnreadNotifications = true;
  }

  void triggerSimulatedPushNotification(String title, String message) {
    final notif = NotificationItem(
      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
      type: 'like',
      senderName: 'Anzor AI',
      senderAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=system',
      message: message,
      timestamp: 'Just now',
      read: false,
    );
    _notifications.insert(0, notif);
    _hasUnreadNotifications = true;
    notifyListeners();
  }

  void triggerSocialNotification({
    required String type,
    required String senderName,
    required String senderAvatar,
    required String message,
    required String targetUser,
  }) {
    final newNotif = NotificationItem(
      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      timestamp: 'Just now',
      read: false,
    );
    _notifications.insert(0, newNotif);
    _hasUnreadNotifications = true;
    
    // Also trigger push banner overlay if targeted to currently active user
    if (targetUser == currentUserProfile.username) {
      triggerSimulatedPushNotification(
        type == 'follow' ? 'New Follower! 👥' : (type == 'like' ? 'New Like! ❤️' : 'New Comment! 💬'),
        '$senderName $message',
      );
    }
    notifyListeners();
  }

  void markNotificationsRead() {
    for (var n in _notifications) {
      n.read = true;
    }
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  // ==================== SOCIAL PROFILE & FOLLOW OPERATIONS ====================

  CreatorProfile get currentUserProfile {
    final name = _currentUser?['username'] ?? 'Creative Guest';
    final avatar = _currentUser?['avatar'] ?? 'https://api.dicebear.com/7.x/bottts/png?seed=guest';
    final cover = _currentUser?['coverBanner'] ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80';
    final role = _currentUser?['role'] ?? 'user';
    
    final index = _creators.indexWhere((c) => c.username == name);
    if (index != -1) {
      return _creators[index];
    } else {
      final newProfile = CreatorProfile(
        username: name,
        avatar: avatar,
        coverBanner: cover,
        bio: _currentUser?['bio'] ?? (role == 'admin' 
            ? 'Administrator of Anzor AI. Managing community and models.'
            : 'AI prompt enthusiast sharing my creative explorations with the world.'),
        joinDate: 'June 2026',
        followers: [],
        following: ['NeonKitten', 'ArtisticSoul'], // preset follows for richer home feed
        isFollowing: false,
        followersCount: 0,
      );
      _creators.add(newProfile);
      return newProfile;
    }
  }

  CreatorStats getCreatorStats(String username) {
    final userPrompts = _communityPrompts.where((p) => p.author == username).toList();
    final totalPosts = userPrompts.length;
    int totalLikes = 0;
    int totalSaves = 0;
    for (var p in userPrompts) {
      totalLikes += p.likesCount;
      totalSaves += p.savesList.length;
    }

    int baseXP = 0;
    int baseRep = 50;
    if (username == 'usman') {
      baseXP = 5400;
      baseRep = 85;
    } else if (username == 'NeonKitten') {
      baseXP = 3200;
      baseRep = 82;
    } else if (username == 'ArtisticSoul') {
      baseXP = 1800;
      baseRep = 75;
    } else if (username == 'RetroRider') {
      baseXP = 4200;
      baseRep = 88;
    } else if (username == 'BeastMaster') {
      baseXP = 2100;
      baseRep = 70;
    } else if (username == 'BookWorm') {
      baseXP = 800;
      baseRep = 62;
    } else if (username == 'Wanderlust') {
      baseXP = 1200;
      baseRep = 65;
    } else if (username == 'Sufyan Art') {
      baseXP = 2600;
      baseRep = 78;
    } else if (username == 'Emaaan') {
      baseXP = 400;
      baseRep = 55;
    } else if (username == 'Creative Guest' || username == 'Admin Principal' || username == (_currentUser?['username'] ?? '')) {
      baseXP = 2450;
      baseRep = 72;
    }

    final totalXp = baseXP + (totalPosts * 150) + (totalLikes * 25) + (totalSaves * 40);
    final totalViews = (totalLikes * 12) + (totalSaves * 8) + (totalPosts * 35) + 85;

    CreatorLevel level = CreatorLevel.beginner;
    if (totalXp >= 12000) {
      level = CreatorLevel.legend;
    } else if (totalXp >= 6000) {
      level = CreatorLevel.elite;
    } else if (totalXp >= 3000) {
      level = CreatorLevel.pro;
    } else if (totalXp >= 1500) {
      level = CreatorLevel.creator;
    } else if (totalXp >= 500) {
      level = CreatorLevel.rising;
    }

    int reputation = ((baseRep + (totalLikes * 2) + totalSaves - (totalPosts * 0.5)).clamp(0.0, 100.0)).toInt();

    final List<AchievementBadge> achievements = [];
    achievements.add(AchievementBadge(
      id: 'ach_member',
      title: 'Member Since \'26',
      description: 'Joined the exclusive Anzor AI network.',
      icon: 'verified_user',
      dateEarned: '2026-06-26',
    ));

    if (totalPosts >= 1 || username == 'usman' || username == 'NeonKitten' || username == 'RetroRider') {
      achievements.add(AchievementBadge(
        id: 'ach_creator',
        title: 'Creative Spark',
        description: 'Published first AI prompt design.',
        icon: 'wb_incandescent',
        dateEarned: '2026-06-26',
      ));
    }

    if (totalLikes >= 50 || totalXp >= 2000) {
      achievements.add(AchievementBadge(
        id: 'ach_liked',
        title: 'Trending Architect',
        description: 'Gained high recognition for prompt engineering.',
        icon: 'trending_up',
        dateEarned: '2026-06-26',
      ));
    }

    if (totalXp >= 4000 || username == 'usman' || username == 'RetroRider') {
      achievements.add(AchievementBadge(
        id: 'ach_elite',
        title: 'Anzor Vanguard',
        description: 'Unlocked Elite Creator level.',
        icon: 'stars',
        dateEarned: '2026-06-26',
      ));
    }

    if (totalSaves >= 5 || username == 'usman' || username == 'NeonKitten') {
      achievements.add(AchievementBadge(
        id: 'ach_saved',
        title: 'Prompt Legend',
        description: 'Prompts saved to collections by multiple creators.',
        icon: 'bookmark',
        dateEarned: '2026-06-26',
      ));
    }

    return CreatorStats(
      xp: totalXp,
      level: level,
      reputationScore: reputation,
      totalPosts: totalPosts == 0 && baseXP > 0 ? (baseXP / 350).ceil() : totalPosts,
      totalLikes: totalLikes == 0 && baseXP > 0 ? (baseXP / 50).ceil() : totalLikes,
      totalViews: totalViews,
      totalSaves: totalSaves == 0 && baseXP > 0 ? (baseXP / 150).ceil() : totalSaves,
      achievements: achievements,
    );
  }

  int getReputationScore(String username) {
    return getCreatorStats(username).reputationScore;
  }


  void _initMockCreators() {
    final followingList = ['NeonKitten', 'ArtisticSoul'];
    _creators = [
      CreatorProfile(
        username: 'usman',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
        coverBanner: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80',
        bio: 'Senior AI Creator & prompt specialist. Experimenting with futuristic designs and photorealistic 3D concepts.',
        joinDate: 'March 2026',
        followers: ['RetroRider', 'NeonKitten'],
        following: ['NeonKitten'],
        isFollowing: false,
        followersCount: 2,
      ),
      CreatorProfile(
        username: 'NeonKitten',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
        coverBanner: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&q=80',
        bio: 'Futuristic visual artist & Cyberpunk architect. Creating Neon Tokyo concepts.',
        joinDate: 'March 2026',
        followers: ['ArtisticSoul', 'RetroRider'],
        following: ['RetroRider'],
        isFollowing: followingList.contains('NeonKitten'),
        followersCount: 2,
      ),
      CreatorProfile(
        username: 'ArtisticSoul',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=ArtisticSoul',
        coverBanner: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=500&q=80',
        bio: 'Watercolor painter & magical realist. Blending tradition and digital canvas.',
        joinDate: 'April 2026',
        followers: ['RetroRider'],
        following: ['NeonKitten'],
        isFollowing: followingList.contains('ArtisticSoul'),
        followersCount: 1,
      ),
      CreatorProfile(
        username: 'RetroRider',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
        coverBanner: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80',
        bio: '80s arcade synthwave designer. Nostalgia rides and retro sunset gradients.',
        joinDate: 'January 2026',
        followers: ['NeonKitten', 'ArtisticSoul'],
        following: ['NeonKitten', 'ArtisticSoul'],
        isFollowing: followingList.contains('RetroRider'),
        followersCount: 2,
      ),
      CreatorProfile(
        username: 'BeastMaster',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=BeastMaster',
        coverBanner: 'https://images.unsplash.com/photo-1602491453979-02654b02720e?w=500&q=80',
        bio: 'Photorealistic wildlife camera artist. Capturing the majesty of wilderness.',
        joinDate: 'May 2026',
        followers: [],
        following: ['RetroRider'],
        isFollowing: followingList.contains('BeastMaster'),
        followersCount: 0,
      ),
      CreatorProfile(
        username: 'BookWorm',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=BookWorm',
        coverBanner: 'https://images.unsplash.com/photo-1568667256549-094345857637?w=500&q=80',
        bio: 'Gothic architecture student and lover of antique books. Dark academia aesthetics.',
        joinDate: 'February 2026',
        followers: [],
        following: [],
        isFollowing: followingList.contains('BookWorm'),
        followersCount: 0,
      ),
      CreatorProfile(
        username: 'Wanderlust',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=Wanderlust',
        coverBanner: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&q=80',
        bio: 'Explorer of hidden waterfall cascades. Pure natural landscapes and scenery.',
        joinDate: 'May 2026',
        followers: ['NeonKitten'],
        following: [],
        isFollowing: followingList.contains('Wanderlust'),
        followersCount: 1,
      ),
      CreatorProfile(
        username: 'Sufyan Art',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=SufyanArt',
        coverBanner: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500&q=80',
        bio: 'Blue fire anime concept designer. High contrast line art styling.',
        joinDate: 'January 2026',
        followers: ['Emaaan'],
        following: [],
        isFollowing: followingList.contains('Sufyan Art'),
        followersCount: 1,
      ),
      CreatorProfile(
        username: 'Emaaan',
        avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=Emaaan',
        coverBanner: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500&q=80',
        bio: 'Moody stone castles on jagged cliffs enthusiast. Foggy and vintage vibes.',
        joinDate: 'June 2026',
        followers: [],
        following: ['Sufyan Art'],
        isFollowing: followingList.contains('Emaaan'),
        followersCount: 0,
      ),
    ];
  }

  Future<void> toggleFollowUser(String targetUserId) async {
    final myProfile = currentUserProfile;
    final myName = myProfile.username;
    
    final targetIndex = _creators.indexWhere((c) => c.username == targetUserId);
    if (targetIndex == -1) return;
    final targetProfile = _creators[targetIndex];

    final isCurrentlyFollowing = targetProfile.isFollowing;
    final newIsFollowing = !isCurrentlyFollowing;
    
    int followersCount = targetProfile.followersCount;

    if (_isOnline) {
      try {
        final res = await _api.toggleFollowUser(targetUserId);
        followersCount = res['followersCount'] ?? followersCount;
      } catch (e) {
        print('Failed to follow/unfollow user on server: $e');
      }
    }

    List<String> newFollowing = List.from(myProfile.following);
    List<String> newFollowers = List.from(targetProfile.followers);

    if (newIsFollowing) {
      if (!newFollowing.contains(targetUserId)) {
        newFollowing.add(targetUserId);
      }
      if (!newFollowers.contains(myName)) {
        newFollowers.add(myName);
      }
      if (!_isOnline) {
        _addOfflineLog('INFO', 'User Session', 'Followed creator: $targetUserId');
      }
      
      triggerSocialNotification(
        type: 'follow',
        senderName: myName,
        senderAvatar: myProfile.avatar,
        message: 'started following your creations.',
        targetUser: targetUserId,
      );
    } else {
      newFollowing.remove(targetUserId);
      newFollowers.remove(myName);
      if (!_isOnline) {
        _addOfflineLog('INFO', 'User Session', 'Unfollowed creator: $targetUserId');
      }
    }

    final myIndex = _creators.indexWhere((c) => c.username == myName);
    if (myIndex != -1) {
      _creators[myIndex] = myProfile.copyWith(following: newFollowing);
    }
    
    _creators[targetIndex] = targetProfile.copyWith(
      followers: newFollowers,
      isFollowing: newIsFollowing,
      followersCount: followersCount,
    );
    
    if (_isOnline) {
      await refreshFollowingFeed();
    }
    
    notifyListeners();
  }

  void toggleFollow(String targetUsername) {
    toggleFollowUser(targetUsername);
  }

  // ==================== SOCIAL POST INTERACTION METHODS ====================

  void _updatePromptInAllLists(PromptItem updatedPrompt) {
    final communityIdx = _communityPrompts.indexWhere((p) => p.id == updatedPrompt.id);
    if (communityIdx != -1) {
      _communityPrompts[communityIdx] = updatedPrompt;
    }
    final followingIdx = _followingPrompts.indexWhere((p) => p.id == updatedPrompt.id);
    if (followingIdx != -1) {
      _followingPrompts[followingIdx] = updatedPrompt;
    }
  }

  Future<void> toggleLikePrompt(String promptId) async {
    final myName = currentUserProfile.username;
    final myAvatar = currentUserProfile.avatar;
    
    PromptItem? prompt;
    final communityIndex = _communityPrompts.indexWhere((p) => p.id == promptId);
    final followingIndex = _followingPrompts.indexWhere((p) => p.id == promptId);

    if (communityIndex != -1) {
      prompt = _communityPrompts[communityIndex];
    } else if (followingIndex != -1) {
      prompt = _followingPrompts[followingIndex];
    }

    if (prompt != null) {
      final newIsLikedByMe = !prompt.isLikedByMe;
      final newLikesCount = newIsLikedByMe 
          ? prompt.likesCount + 1 
          : max(0, prompt.likesCount - 1);

      List<String> newLikesList = List.from(prompt.likesList);
      
      if (newIsLikedByMe) {
        if (!newLikesList.contains(myName)) {
          newLikesList.add(myName);
        }
        _addOfflineLog('INFO', 'User Session', 'Liked prompt: ${prompt.title}');
        
        if (prompt.author != myName) {
          triggerSocialNotification(
            type: 'like',
            senderName: myName,
            senderAvatar: myAvatar,
            message: 'liked your prompt "${prompt.title}".',
            targetUser: prompt.author,
          );
        }
      } else {
        newLikesList.remove(myName);
        _addOfflineLog('INFO', 'User Session', 'Unliked prompt: ${prompt.title}');
      }
      
      int finalLikes = newLikesCount;
      if (_isOnline) {
        try {
          finalLikes = await _api.likePrompt(promptId);
        } catch (e) {
          print('Failed to like on server: $e');
        }
      }

      final updatedPrompt = prompt.copyWith(
        likesList: newLikesList,
        likes: finalLikes,
        isLikedByMe: newIsLikedByMe,
        likesCount: finalLikes,
      );

      _updatePromptInAllLists(updatedPrompt);
      notifyListeners();
    }
  }

  Future<void> toggleLikePromptAction(String id) async {
    await toggleLikePrompt(id);
  }

  Future<void> addCommentAction(String id, String content) async {
    if (content.trim().isEmpty) return;
    final myProfile = currentUserProfile;
    final myName = myProfile.username;
    
    final index = _communityPrompts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final prompt = _communityPrompts[index];
      final newComment = CommentItem(
        author: myName,
        authorAvatar: myProfile.avatar,
        content: content.trim(),
        timestamp: 'Just now',
      );
      
      List<CommentItem> newComments = List.from(prompt.commentsList);
      newComments.add(newComment);
      
      _communityPrompts[index] = prompt.copyWith(commentsList: newComments);
      _addOfflineLog('INFO', 'User Session', 'Added comment to prompt: ${prompt.title}');
      
      if (prompt.author != myName) {
        triggerSocialNotification(
          type: 'comment',
          senderName: myName,
          senderAvatar: myProfile.avatar,
          message: 'commented on your prompt "${prompt.title}": "${content.trim()}"',
          targetUser: prompt.author,
        );
      }
      notifyListeners();
    }
  }

  Future<void> toggleBookmarkSocial(String id) async {
    final myProfile = currentUserProfile;
    final myName = myProfile.username;
    
    final index = _communityPrompts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final prompt = _communityPrompts[index];
      List<String> newSaves = List.from(prompt.savesList);
      
      final isSaved = newSaves.contains(myName);
      if (isSaved) {
        newSaves.remove(myName);
        _addOfflineLog('INFO', 'User Session', 'Removed bookmark: ${prompt.title}');
      } else {
        newSaves.add(myName);
        _addOfflineLog('INFO', 'User Session', 'Bookmarked prompt: ${prompt.title}');
        
        if (prompt.author != myName) {
          triggerSocialNotification(
            type: 'save',
            senderName: myName,
            senderAvatar: myProfile.avatar,
            message: 'saved your prompt "${prompt.title}" to collections.',
            targetUser: prompt.author,
          );
        }
      }
      
      _communityPrompts[index] = prompt.copyWith(savesList: newSaves);
      toggleBookmark(prompt);
    }
  }

  // ==================== SEARCH & FEED ROUTING QUERIES ====================

  List<PromptItem> get followingPrompts {
    if (_isOnline && _followingPrompts.isNotEmpty) {
      return _followingPrompts;
    }
    return _communityPrompts.where((p) {
      final creatorIdx = _creators.indexWhere((c) => c.username == p.author);
      if (creatorIdx != -1) {
        return _creators[creatorIdx].isFollowing;
      }
      return currentUserProfile.following.contains(p.author);
    }).toList();
  }
  
  List<PromptItem> get trendingPrompts => List.from(_communityPrompts)..sort((a, b) => b.likes.compareTo(a.likes));
  
  List<PromptItem> get latestPrompts => List.from(_communityPrompts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PromptItem> searchPrompts(String query) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query.trim().toLowerCase();
    
    if (cleanQuery.startsWith('#')) {
      final tag = cleanQuery.substring(1);
      return _communityPrompts.where((p) => 
        p.prompt.toLowerCase().contains(tag) || 
        p.title.toLowerCase().contains(tag) ||
        p.style.toLowerCase().contains(tag) ||
        p.category.toLowerCase().contains(tag)
      ).toList();
    }
    
    return _communityPrompts.where((p) => 
      p.title.toLowerCase().contains(cleanQuery) || 
      p.prompt.toLowerCase().contains(cleanQuery) || 
      p.category.toLowerCase().contains(cleanQuery) ||
      p.style.toLowerCase().contains(cleanQuery)
    ).toList();
  }

  List<CreatorProfile> searchCreators(String query) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query.trim().toLowerCase();
    return _creators.where((c) => 
      c.username.toLowerCase().contains(cleanQuery) || 
      c.bio.toLowerCase().contains(cleanQuery)
    ).toList();
  }

  // ==================== MOCK DATA AND HELPER GENERATORS ====================

  void _addOfflineLog(String level, String source, String message) {
    _serverLogs.insert(0, LogEntry(
      timestamp: DateTime.now().toIso8601String(),
      level: level,
      source: source,
      message: message,
    ));
    if (_serverLogs.length > 30) {
      _serverLogs.removeLast();
    }
  }

  Map<String, dynamic> _getMockMetrics() {
    final random = Random();
    final totalGens = _historyList.length + 158;
    return {
      'uptime': '14h 32m ${random.nextInt(60)}s',
      'systemHealth': 'Healthy',
      'memoryUsedMB': 34.5 + random.nextDouble() * 4.0,
      'memoryTotalMB': 92.4,
      'nodeVersion': 'v20.10.0',
      'totalGenerations': totalGens,
      'averageLatencyMs': 950 + random.nextInt(150),
      'errorRate': '1.2%'
    };
  }

  List<LogEntry> _getMockLogs() {
    return [
      LogEntry(timestamp: DateTime.now().toIso8601String(), level: 'INFO', source: 'System', message: 'Anzor AI server running in standalone sandbox mode.'),
      LogEntry(timestamp: DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(), level: 'INFO', source: 'Gemini AI', message: 'Initialized generative client model gemini-1.5-flash.'),
      LogEntry(timestamp: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(), level: 'WARN', source: 'System', message: 'FCM push notification dispatcher token is simulated.'),
      LogEntry(timestamp: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(), level: 'INFO', source: 'Database', message: 'Local document collections.json loaded successfully.'),
    ];
  }

  String _getRandomLogLevel() {
    final levels = ['INFO', 'INFO', 'INFO', 'WARN', 'ERROR'];
    return levels[Random().nextInt(levels.length)];
  }

  String _getRandomLogSource() {
    final sources = ['System', 'Gemini AI', 'Database', 'API Gateway', 'User Session'];
    return sources[Random().nextInt(sources.length)];
  }

  String _getRandomLogMessage() {
    final messages = [
      'Prompt expansion request received via direct Gemini API.',
      'Active connection pool: 5 active connections.',
      'Memory utilization threshold check: Nominal.',
      'FCM push notification broadcast: 12 clients notified.',
      'Document collections.json auto-sync complete.',
      'AI Vision reverse-engineering image analytics requested.',
      'Garbage collector: Freed 8.4 MB of unused heap memory.',
      'Session token validation successful for user admin@anzor.ai.',
      'Cache hit ratio: 89.2% on standard collections.',
      'API gateway throughput: 1.2 requests/sec.'
    ];
    return messages[Random().nextInt(messages.length)];
  }

  List<PromptItem> _getMockAdminPrompts() {
    return [
      PromptItem(
        id: 'usr_mod_1',
        title: 'Mystical Fire Dragon',
        prompt: 'A giant mystical dragon made of blue fire flying around a snowy mountain peak, high contrast, anime line art style, detailed sky.',
        description: 'Anime dragon concept',
        author: 'Sufyan Art',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=SufyanArt',
        category: 'Anime',
        style: 'Anime & Manga',
        likes: 1,
        status: 'pending',
        image: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        likesList: [],
        savesList: [],
        commentsList: [],
      ),
      PromptItem(
        id: 'usr_mod_2',
        title: 'Gothic Castle in Fog',
        prompt: 'Moody architectural capture of an ancient gothic stone castle sitting on top of a jagged cliff, surrounded by thick white fog, golden hour lighting.',
        description: 'Vampire style vintage castle',
        author: 'Emaaan',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=Emaaan',
        category: 'Architecture',
        style: 'Cinematic',
        likes: 0,
        status: 'pending',
        image: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        likesList: [],
        savesList: [],
        commentsList: [],
      )
    ];
  }

  List<PromptItem> _getMockCommunityPrompts() {
    return [
      PromptItem(
        id: 'mock_usman_1',
        title: 'Cybernetic Genesis',
        prompt: 'Futuristic hybrid mechanical brain construct surrounded by warm glowing golden circuits, holographic projection nodes, detailed inter-wiring, deep navy void background, 8k resolution, cinematic 3D render.',
        description: 'Next-gen cybernetic neural engine visualization',
        author: 'usman',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
        category: 'Sci-Fi',
        style: '3D Render',
        likes: 342,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        likesList: ['NeonKitten', 'RetroRider'],
        savesList: ['NeonKitten'],
        commentsList: [
          CommentItem(author: 'NeonKitten', authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten', content: 'The depth on this is insane!', timestamp: '1h ago'),
        ],
      ),
      PromptItem(
        id: 'mock_usman_2',
        title: 'Celestial Guardian',
        prompt: 'Close-up side portrait of a majestic celestial knight wearing golden filigree armor with glowing sapphire inlay, volumetric golden aura, Unreal Engine 5 render style.',
        description: 'Epic medieval sci-fi warrior portrait',
        author: 'usman',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
        category: 'Fantasy',
        style: 'Concept Art',
        likes: 289,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        likesList: ['ArtisticSoul'],
        savesList: [],
        commentsList: [],
      ),
      PromptItem(
        id: 'mock_1',
        title: 'Cyberpunk Teahouse',
        prompt: 'A cozy traditional Japanese teahouse tucked between futuristic neon skyscrapers in Neo-Tokyo, rain-slicked asphalt, holographic cherry blossoms, cinematic volumetric lighting, cyber-fantasy aesthetic.',
        description: 'Futuristic teahouse concept',
        author: 'NeonKitten',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
        category: 'Sci-Fi',
        style: 'Cyberpunk',
        likes: 142,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        likesList: ['RetroRider', 'ArtisticSoul'],
        savesList: ['RetroRider'],
        commentsList: [
          CommentItem(author: 'RetroRider', authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider', content: 'Incredible details!', timestamp: '2h ago'),
        ],
      ),
      PromptItem(
        id: 'mock_2',
        title: 'Ethereal Forest Spirit',
        prompt: 'A majestic deer made of glowing roots and golden leaves standing in a mystical midnight forest, soft wet-on-wet watercolor runs, starry dust motes floating in shafts of moonlight, watercolor paper texture.',
        description: 'Magical watercolor painting',
        author: 'ArtisticSoul',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=ArtisticSoul',
        category: 'Fantasy',
        style: 'Watercolor',
        likes: 98,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        likesList: ['NeonKitten'],
        savesList: [],
        commentsList: [],
      ),
      PromptItem(
        id: 'mock_3',
        title: 'Retro Highway Sunset',
        prompt: 'Wide shot of a red sports car driving down a coastal highway towards a massive setting sun, 1980s synthwave style, warm vintage film look, Polaroid film grain, light leak streaks.',
        description: '80s synthwave polaroid aesthetic',
        author: 'RetroRider',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
        category: 'Realistic',
        style: 'Vintage Film',
        likes: 215,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        likesList: ['NeonKitten', 'ArtisticSoul'],
        savesList: ['ArtisticSoul'],
        commentsList: [],
      ),
      PromptItem(
        id: 'mock_4',
        title: 'Majestic White Lion',
        prompt: 'Extremely detailed head portrait of a royal white lion with golden eyes, cinematic studio lighting, dark charcoal background, highly detailed hair, photorealistic 8k, Unreal Engine 5 render style.',
        description: 'Fierce photorealistic lion',
        author: 'BeastMaster',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=BeastMaster',
        category: 'Animals',
        style: '3D Render',
        likes: 187,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1602491453979-02654b02720e?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        likesList: ['RetroRider'],
        savesList: [],
        commentsList: [],
      ),
      PromptItem(
        id: 'mock_5',
        title: 'Gothic Library Halls',
        prompt: 'Mysterious antique library with soaring gothic archways, tall stained-glass windows, dusty books piled high on mahogany shelves, golden sunbeams illuminating floating particles.',
        description: 'Dark academic aesthetic',
        author: 'BookWorm',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=BookWorm',
        category: 'Architecture',
        style: 'Painterly',
        likes: 120,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1568667256549-094345857637?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        likesList: ['ArtisticSoul'],
        savesList: [],
        commentsList: [],
      ),
      PromptItem(
        id: 'mock_6',
        title: 'Hidden Waterfall Oasis',
        prompt: 'Deep jungle waterfall cascading into a crystal clear turquoise pool, surrounded by exotic glowing flowers and giant ferns, volumetric sunrays filtering through a dense green canopy.',
        description: 'Serene nature scene',
        author: 'Wanderlust',
        authorAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=Wanderlust',
        category: 'Nature',
        style: 'Cinematic',
        likes: 154,
        status: 'approved',
        image: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        likesList: ['RetroRider'],
        savesList: [],
        commentsList: [],
      ),
    ];
  }
}

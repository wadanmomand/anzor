class PromptItem {
  final String id;
  final String title;
  final String prompt;
  final String description;
  final String author;
  final String authorAvatar;
  final String category;
  final String style;
  int likes;
  int dislikes;
  final String status; // 'pending', 'approved', 'rejected'
  final String image;
  final String createdAt;
  final List<String> likesList; // List of usernames who liked it
  final List<String> savesList; // List of usernames who bookmarked it
  final List<CommentItem> commentsList; // List of comments on this post
  final bool isLikedByMe;
  final int likesCount;

  String get ownerName => author;
  String get ownerAvatar => authorAvatar;

  List<String> get tagsList {
    if (category.toLowerCase() == 'sci-fi') return ['cyberpunk', 'neon', 'future', '4k'];
    if (category.toLowerCase() == 'fantasy') return ['watercolor', 'magical', 'celestial', 'dreamy'];
    if (category.toLowerCase() == 'realistic' || category.toLowerCase() == 'photography') return ['photorealistic', '8k', 'cinematic', 'hdr'];
    if (category.toLowerCase() == 'animals') return ['wildlife', 'macro', 'nature', 'unreal-engine'];
    if (category.toLowerCase() == 'architecture') return ['gothic', 'historical', 'foggy', 'dark-academia'];
    if (category.toLowerCase() == 'nature') return ['waterfall', 'forest', 'oasis', 'volumetric'];
    if (category.toLowerCase() == 'anime') return ['line-art', 'flame', 'illustrative', 'concept'];
    return ['creative', 'ai-generated', 'prompt-art'];
  }

  String get negativePrompt => 'ugly, deformed, blurry, low resolution, bad anatomy, duplicate, worst quality';
  String get artStyle => style;
  String get cameraAngle {
    final cat = category.toLowerCase();
    if (cat == 'sci-fi' || cat == 'architecture') return 'Wide Angle, 24mm';
    if (cat == 'portrait') return 'Close-up, Eye Level';
    return 'Three-Quarter View, Cinematic';
  }
  String get lighting {
    final cat = category.toLowerCase();
    if (cat == 'fantasy') return 'Volumetric, Starry Dust';
    if (cat == 'realistic' || cat == 'nature') return 'Golden Hour, Sunset Glares';
    return 'Cyberpunk Neon Glows, Ambient Shadowing';
  }
  String get aspectRatioVal => '4:5';

  PromptItem({
    required this.id,
    required this.title,
    required this.prompt,
    required this.description,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.style,
    this.likes = 0,
    this.dislikes = 0,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.likesList,
    required this.savesList,
    required this.commentsList,
    this.isLikedByMe = false,
    this.likesCount = 0,
  });

  factory PromptItem.fromJson(Map<String, dynamic> json) {
    var commentsJson = json['commentsList'] as List?;
    List<CommentItem> comments = commentsJson != null
        ? commentsJson.map((c) => CommentItem.fromJson(c)).toList()
        : [];

    final int likesVal = json['likes'] is int ? json['likes'] : (int.tryParse(json['likes']?.toString() ?? '0') ?? 0);

    return PromptItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Anonymous',
      authorAvatar: json['authorAvatar']?.toString() ?? '',
      category: json['category']?.toString() ?? 'All',
      style: json['style']?.toString() ?? 'Digital Art',
      likes: likesVal,
      dislikes: json['dislikes'] is int ? json['dislikes'] : (int.tryParse(json['dislikes']?.toString() ?? '0') ?? 0),
      status: json['status']?.toString() ?? 'pending',
      image: json['image']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      likesList: (json['likesList'] as List?)?.map((e) => e.toString()).toList() ?? [],
      savesList: (json['savesList'] as List?)?.map((e) => e.toString()).toList() ?? [],
      commentsList: comments,
      isLikedByMe: json['isLikedByMe'] == true,
      likesCount: json['likesCount'] is int 
          ? json['likesCount'] 
          : (int.tryParse(json['likesCount']?.toString() ?? likesVal.toString()) ?? likesVal),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'description': description,
      'author': author,
      'authorAvatar': authorAvatar,
      'category': category,
      'style': style,
      'likes': likes,
      'dislikes': dislikes,
      'status': status,
      'image': image,
      'createdAt': createdAt,
      'likesList': likesList,
      'savesList': savesList,
      'commentsList': commentsList.map((c) => c.toJson()).toList(),
      'isLikedByMe': isLikedByMe,
      'likesCount': likesCount,
    };
  }

  PromptItem copyWith({
    String? id,
    String? title,
    String? prompt,
    String? description,
    String? author,
    String? authorAvatar,
    String? category,
    String? style,
    int? likes,
    int? dislikes,
    String? status,
    String? image,
    String? createdAt,
    List<String>? likesList,
    List<String>? savesList,
    List<CommentItem>? commentsList,
    bool? isLikedByMe,
    int? likesCount,
  }) {
    return PromptItem(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      description: description ?? this.description,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      category: category ?? this.category,
      style: style ?? this.style,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      status: status ?? this.status,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      likesList: likesList ?? this.likesList,
      savesList: savesList ?? this.savesList,
      commentsList: commentsList ?? this.commentsList,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}

class CommentItem {
  final String author;
  final String authorAvatar;
  final String content;
  final String timestamp;

  CommentItem({
    required this.author,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      author: json['author']?.toString() ?? 'Anonymous',
      authorAvatar: json['authorAvatar']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? 'Just now',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

class CreatorProfile {
  final String username;
  final String avatar;
  final String coverBanner;
  final String bio;
  final String joinDate;
  final List<String> followers; // List of usernames following this user
  final List<String> following; // List of usernames this user follows
  final bool isFollowing;
  final int followersCount;

  CreatorProfile({
    required this.username,
    required this.avatar,
    required this.coverBanner,
    required this.bio,
    required this.joinDate,
    required this.followers,
    required this.following,
    this.isFollowing = false,
    this.followersCount = 0,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    var followersList = (json['followers'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return CreatorProfile(
      username: json['username']?.toString() ?? 'Creator',
      avatar: json['avatar']?.toString() ?? '',
      coverBanner: json['coverBanner']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      joinDate: json['joinDate']?.toString() ?? 'June 2026',
      followers: followersList,
      following: (json['following'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isFollowing: json['isFollowing'] == true,
      followersCount: json['followersCount'] is int 
          ? json['followersCount'] 
          : (int.tryParse(json['followersCount']?.toString() ?? followersList.length.toString()) ?? followersList.length),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatar,
      'coverBanner': coverBanner,
      'bio': bio,
      'joinDate': joinDate,
      'followers': followers,
      'following': following,
      'isFollowing': isFollowing,
      'followersCount': followersCount,
    };
  }

  CreatorProfile copyWith({
    String? username,
    String? avatar,
    String? coverBanner,
    String? bio,
    String? joinDate,
    List<String>? followers,
    List<String>? following,
    bool? isFollowing,
    int? followersCount,
  }) {
    return CreatorProfile(
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      coverBanner: coverBanner ?? this.coverBanner,
      bio: bio ?? this.bio,
      joinDate: joinDate ?? this.joinDate,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isFollowing: isFollowing ?? this.isFollowing,
      followersCount: followersCount ?? this.followersCount,
    );
  }
}

class NotificationItem {
  final String id;
  final String type; // 'follow', 'like', 'comment', 'save'
  final String senderName;
  final String senderAvatar;
  final String message;
  final String timestamp;
  bool read;

  NotificationItem({
    required this.id,
    required this.type,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'like',
      senderName: json['senderName']?.toString() ?? 'Someone',
      senderAvatar: json['senderAvatar']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? 'Just now',
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'timestamp': timestamp,
      'read': read,
    };
  }
}

class HistoryItem {
  final String id;
  final String rawIdea;
  final String expandedPrompt;
  final String explanation;
  final String style;
  final List<String> presets;
  final String date;

  HistoryItem({
    required this.id,
    required this.rawIdea,
    required this.expandedPrompt,
    required this.explanation,
    required this.style,
    required this.presets,
    required this.date,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString() ?? '',
      rawIdea: json['rawIdea']?.toString() ?? '',
      expandedPrompt: json['expandedPrompt']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      style: json['style']?.toString() ?? 'Cinematic',
      presets: (json['presets'] as List?)?.map((e) => e.toString()).toList() ?? [],
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawIdea': rawIdea,
      'expandedPrompt': expandedPrompt,
      'explanation': explanation,
      'style': style,
      'presets': presets,
      'date': date,
    };
  }
}

class CollectionItem {
  final String id;
  final String name;
  final List<String> promptIds;

  CollectionItem({
    required this.id,
    required this.name,
    required this.promptIds,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'My Collection',
      promptIds: (json['promptIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'promptIds': promptIds,
    };
  }
}

class LogEntry {
  final String timestamp;
  final String level; // 'INFO', 'WARN', 'ERROR'
  final String source; // 'System', 'Gemini AI', etc.
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      level: json['level']?.toString() ?? 'INFO',
      source: json['source']?.toString() ?? 'System',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'level': level,
      'source': source,
      'message': message,
    };
  }
}

class PromptModel {
  final String id;
  final String title;
  final String prompt;
  final String description;
  final String category;
  final String style;
  final String image;
  final String createdAt;
  final String status;
  
  // Social fields
  final String ownerId;
  final String ownerName;
  final String ownerAvatar;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;

  PromptModel({
    required this.id,
    required this.title,
    required this.prompt,
    required this.description,
    required this.category,
    required this.style,
    required this.image,
    required this.createdAt,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatar,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'All',
      style: json['style']?.toString() ?? 'Digital Art',
      image: json['image']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      status: json['status']?.toString() ?? 'pending',
      ownerId: json['ownerId']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? 'Anonymous',
      ownerAvatar: json['ownerAvatar']?.toString() ?? '',
      likesCount: json['likesCount'] is int ? json['likesCount'] : (int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0),
      commentsCount: json['commentsCount'] is int ? json['commentsCount'] : (int.tryParse(json['commentsCount']?.toString() ?? '0') ?? 0),
      isLikedByMe: json['isLikedByMe'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'description': description,
      'category': category,
      'style': style,
      'image': image,
      'createdAt': createdAt,
      'status': status,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLikedByMe': isLikedByMe,
    };
  }

  PromptModel copyWith({
    String? id,
    String? title,
    String? prompt,
    String? description,
    String? category,
    String? style,
    String? image,
    String? createdAt,
    String? status,
    String? ownerId,
    String? ownerName,
    String? ownerAvatar,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      description: description ?? this.description,
      category: category ?? this.category,
      style: style ?? this.style,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String coverBanner;
  final String bio;
  final String role;
  
  // Social fields
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final List<dynamic> savedPrompts;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.coverBanner,
    required this.bio,
    required this.role,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    required this.savedPrompts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var savedJson = json['savedPrompts'] as List?;
    List<dynamic> saved = savedJson != null ? List.from(savedJson) : [];

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      coverBanner: json['coverBanner']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      followersCount: json['followersCount'] is int ? json['followersCount'] : (int.tryParse(json['followersCount']?.toString() ?? '0') ?? 0),
      followingCount: json['followingCount'] is int ? json['followingCount'] : (int.tryParse(json['followingCount']?.toString() ?? '0') ?? 0),
      isFollowing: json['isFollowing'] == true,
      savedPrompts: saved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'coverBanner': coverBanner,
      'bio': bio,
      'role': role,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
      'savedPrompts': savedPrompts,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? coverBanner,
    String? bio,
    String? role,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    List<dynamic>? savedPrompts,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      coverBanner: coverBanner ?? this.coverBanner,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      savedPrompts: savedPrompts ?? this.savedPrompts,
    );
  }
}

enum CreatorLevel {
  beginner,
  rising,
  creator,
  pro,
  elite,
  legend,
}

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name/asset
  final String dateEarned;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.dateEarned,
  });
}

class CreatorStats {
  final int xp;
  final CreatorLevel level;
  final int reputationScore; // 0-100
  final int totalPosts;
  final int totalLikes;
  final int totalViews;
  final int totalSaves;
  final List<AchievementBadge> achievements;

  CreatorStats({
    required this.xp,
    required this.level,
    required this.reputationScore,
    required this.totalPosts,
    required this.totalLikes,
    required this.totalViews,
    required this.totalSaves,
    required this.achievements,
  });
}


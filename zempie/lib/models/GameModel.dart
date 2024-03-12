
import 'package:app/models/EmotionModel.dart';
import 'package:app/models/User.dart';

class GameModel {
  late bool isSubscribed;
  late bool activated;
  late int id;
  late int category;
  late String title;
  late String description;
  late String createdAt;
  late String pathname;
  late String version;
  late int controlType;
  late String hashtags;
  late int stage;
  late int countOver;
  late int countHeart;
  late String supportPlatform;
  late int gameType;
  late String urlGame;
  late String urlThumb;
  late String urlThumbWebp;
  late String urlThumbGif;
  late List<dynamic> urlBanner;
  late EmotionsModel emotions;
  late UserModel? user;
  late int commentCount;
  late int postCount;
  late int followerCount;
  late bool isFollow;
  late bool isLike;

  GameModel.fromJson(Map<String, dynamic> json)
      : activated = json['activated'] ?? true,
        isSubscribed = json['is_subscribed'] ?? false,
        id = json['id'] ?? 0,
        category = json['category'] ?? 0,
        title = json['title'] ?? "",
        description = json['description'] ?? "",
        createdAt = json['created_at'] ?? "",
        pathname = json['pathname'] ?? "",
        version = json['version'] ?? "",
        controlType = json['control_type'] ?? 0,
        hashtags = json['hashtags'] ?? "",
        stage = json['stage'] ?? 0,
        countOver = json['count_over'] ?? 0,
        countHeart = json['count_heart'] ?? 0,
        supportPlatform = json['support_platform'] ?? "",
        gameType = json['game_type'] ?? 0,
        urlGame = json['url_game'] ?? "",
        urlThumb = json['url_thumb'] ?? "",
        urlThumbWebp = json['url_thumb_webp'] ?? "",
        urlThumbGif = json['url_thumb_gif'] ?? "",
        urlBanner = json['url_banner'] != null ? json['url_banner'].map((jsonBanner) => jsonBanner as String).toList(): [],
        user = json["user"] != null ? UserModel.fromJson(json["user"]) : null,
        emotions = EmotionsModel.fromJson(json['emotions'] ?? {}),
        commentCount = json["comment_count"] ?? 0,
        postCount = json["post_count"] ?? 0,
        followerCount = json["follower_count"] ?? 0,
        isFollow = json["is_follow"] ?? false,
        isLike = json["is_like"] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'activated': activated,
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'pathname': pathname,
      'version': version,
      'control_type': controlType,
      'hashtags': hashtags,
      'stage': stage,
      'count_over': countOver,
      'count_heart': countHeart,
      'support_platform': supportPlatform,
      'game_type': gameType,
      'url_game': urlGame,
      'url_thumb': urlThumb,
      'url_thumb_webp': urlThumbWebp,
      'url_thumb_gif': urlThumbGif,
      'url_banner': urlBanner,
      'emotions': emotions.toJson(),
    };
  }
}

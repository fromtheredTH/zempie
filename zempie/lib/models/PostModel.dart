
import 'dart:convert';

import 'package:app/models/AttatchmentFile.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/User.dart';
import 'package:get/get.dart';

class PostModel {
  late bool liked;
  late bool? isPinned;
  late bool isRetweet;
  late String id;
  late String createdAt;
  late String updatedAt;
  late String deletedAt;
  late int userId;
  late int backgroundId;
  late String postType;
  late String functionType;
  late List<AttachmentFile> attachmentFiles;
  late String visibility;
  late String contents;
  late dynamic hashtags;
  late dynamic userTagIds;
  late int likeCount;
  late int commentCount;
  late int readCount;
  late int sharedCount;
  late dynamic scheduledFor;
  late String status;
  late dynamic retweetId;
  late bool isAllowDonate;
  late dynamic gameTagIds;
  late UserModel user;
  late PostedAtModel postedAt;

  PostModel.fromJson(Map<String, dynamic> json) :
        liked = json['liked'] ?? false,
        isPinned = json['is_pinned'],
        isRetweet = json['is_retweet'] ?? false,
        id = json['id'] ?? "",
        createdAt = json['created_at'] ?? "",
        updatedAt = json['updated_at'] ?? "",
        deletedAt = json['deleted_at'] ?? "",
        userId = json['user_id'] ?? 0,
        postType = json['post_type'] ?? "",
        functionType = json['function_type'] ?? "",
        attachmentFiles = json['attatchment_files'] != null ?
        json['attatchment_files'] is String ?
        jsonDecode(json["attatchment_files"])?.map((fileJson) => AttachmentFile.fromJson(fileJson)).toList().cast<AttachmentFile>() ?? []
            : (json["attatchment_files"] as List<dynamic>).isEmpty ? [] :
        json["attatchment_files"][0] is List<dynamic> ? [] : json["attatchment_files"].map((fileJson) => AttachmentFile.fromJson(fileJson)).toList().cast<AttachmentFile>() : [],
        visibility = json['visibility'] ?? "",
        contents = json['contents'] ?? "",
        hashtags = json['hashtags'],
        userTagIds = json['user_tagIds'],
        likeCount = json['like_cnt'] ?? 0,
        commentCount = json['comment_cnt'] ?? 0,
        readCount = json['read_cnt'] ?? 0,
        sharedCount = json['shared_cnt'] ?? 0,
        scheduledFor = json['scheduled_for'],
        status = json['status'] ?? "",
        retweetId = json['retweet_id'],
        isAllowDonate = json['is_allow_donate'] != null ? json["is_allow_donate"] is int ? json["is_allow_donate"] == 1 : false : false,
        backgroundId = json['background_id'] ?? -1,
        gameTagIds = json['game_tagIds'],
        user = UserModel.fromJson(json['user'] ?? {}),
        postedAt = PostedAtModel.fromJson(json['posted_at'] ?? {});

  Map<String, dynamic> toJson() {
    return {
      'liked': liked,
      'is_pinned': isPinned,
      'is_retweet': isRetweet,
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'user_id': userId,
      'post_type': postType,
      'function_type': functionType,
      'attatchment_files': attachmentFiles.map((file) => file.toJson()).toList(),
      'visibility': visibility,
      'contents': contents,
      'hashtags': hashtags,
      'user_tagIds': userTagIds,
      'like_cnt': likeCount,
      'comment_cnt': commentCount,
      'read_cnt': readCount,
      'shared_cnt': sharedCount,
      'scheduled_for': scheduledFor,
      'status': status,
      'retweet_id': retweetId,
      'is_allow_donate': isAllowDonate,
      'background_id': backgroundId,
      'game_tagIds': gameTagIds,
      'user': user.toJson(),
      'posted_at': postedAt.toJson(),
    };
  }
}

class PostedAtModel {
  late String createdAt;
  late String updatedAt;
  late String deletedAt;
  late List<GameModel> games;
  late List<CommunityModel> communities;
  late dynamic portfolioIds;
  late String id;
  late String postsId;
  late String channelId;

  PostedAtModel.fromJson(Map<String, dynamic> json)
      : createdAt = json['created_at'] ?? "",
        updatedAt = json['updated_at'] ?? "",
        deletedAt = json['deleted_at'] ?? "",
        games = json["games"] == null ? [] : json["games"].map((gameJson) => GameModel.fromJson(gameJson)).toList().cast<GameModel>(),
        communities = json["communities"] == null ? [] : json["communities"].map((communityJson) => CommunityModel.fromJson(communityJson["community"])).toList().cast<CommunityModel>(),
        portfolioIds = json['portfolio_ids'],
        id = json['id'] ?? "",
        postsId = json['posts_id'] ?? "",
        channelId = json['channel_id'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'games': games,
      'communities': communities,
      'portfolio_ids': portfolioIds,
      'id': id,
      'posts_id': postsId,
      'channel_id': channelId,
    };
  }
}

class PostLikeModel {
  late String id;
  late String postId;
  late UserModel user;

  PostLikeModel.fromJson(Map<String, dynamic> json) :
        id = json['id'] ?? "",
        postId = json['post_id'] ?? "",
        user = UserModel.fromJson(json['user'] ?? {});
}


import 'package:app/models/User.dart';

class PostReplyModel {
  late String id;
  late String contents;
  late int likeCount;
  late String createdAt;
  late String updatedAt;
  late UserModel user;
  late bool isLike;
  String postId;
  String parentId;
  late List<PostReplyModel> childrenComments;

  PostReplyModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        contents = json['contents'] ?? "",
        likeCount = json['like_cnt'] ?? 0,
        createdAt = json['created_at'] ?? "",
        updatedAt = json['updated_at'] ?? "",
        user = UserModel.fromJson(json['user'] ?? {}),
        parentId = json["parent_id"] ?? "",
        postId = json["post_id"] ?? "",
        childrenComments = json["children_comments"] == null
            ? [] : json["children_comments"].map((commentJson) =>
            PostReplyModel.fromJson(commentJson)).toList().cast<PostReplyModel>(),
        isLike = json["is_liked"] ?? false;
}
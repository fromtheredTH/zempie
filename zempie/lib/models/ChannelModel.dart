
import 'package:app/models/User.dart';

class ChannelModel {
  late String id;
  late int userId;
  late String communityId;
  late String title;
  late String description;
  late String profileImg;
  late String state;
  late String createdAt;
  late String updatedAt;
  late String deletedAt;

  ChannelModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        userId = json['user_id'] ?? 0,
        title = json['title'] ?? "",
        communityId = json['community_id'] ?? "",
        description = json['description'] ?? "",
        createdAt = json['created_at'] ?? "",
        updatedAt = json['updated_at'] ?? "",
        deletedAt = json["deleted_at"] ?? "",
        profileImg = json["profile_img"] ?? "",
        state = json['state'] ?? "";

  Map<String, dynamic> toJson() => {
    'id': communityId,
    'channel_id': id
  };
}
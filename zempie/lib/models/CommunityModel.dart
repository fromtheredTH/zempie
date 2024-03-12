
import 'package:app/models/ChannelModel.dart';

class CommunityModel {
  late bool isSubscribed;
  late bool isPrivate;
  late dynamic userBlock;
  late String createdAt;
  late String updatedAt;
  late String deletedAt;
  late String id;
  late String ownerId;
  late String managerId;
  late String submanagerId;
  late String name;
  late String url;
  late String description;
  late String profileImg;
  late String bannerImg;
  late int memberCnt;
  late int postsCnt;
  late int visitCnt;
  late String state;
  late bool isCertificated;
  late List<ChannelModel> channels;

  CommunityModel.fromJson(Map<String, dynamic> json) {
    try {
      isSubscribed = json["is_subscribed"] ?? false;
      isPrivate = json["is_private"] ?? false;
      userBlock = json["user_block"];
      createdAt = json["created_at"] ?? "";
      updatedAt = json["updated_at"] ?? "";
      deletedAt = json["deleted_at"] ?? "";
      id = json["id"] ?? "";
      ownerId = json["owner_id"] ?? "";
      managerId = json["manager_id"] ?? "";
      submanagerId = json["submanager_id"] ?? "";
      name = json["name"] ?? "";
      url = json["url"] ?? "";
      description = json["description"] ?? "";
      profileImg = json["profile_img"] ?? "";
      bannerImg = json["banner_img"] ?? "";
      memberCnt = json["member_cnt"] ?? 0;
      postsCnt = json["posts_cnt"] ?? 0;
      visitCnt = json["visit_cnt"] ?? 0;
      state = json["state"] ?? "";
      isCertificated = json["is_certificated"] ?? false;
      channels = json["channels"] != null ? json["channels"].map((channelJson) => ChannelModel.fromJson(channelJson)).toList().cast<ChannelModel>() : [];
    } catch (e) {
      print("Error parsing Community: $e");
      // 예외 처리 코드 추가 가능
    }
  }
}

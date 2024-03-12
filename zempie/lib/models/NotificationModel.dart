

import 'package:app/models/User.dart';

class NotificationModel {
  late int id;
  late String contents;
  late String targetId = "";
  late bool isRead = false;
  late int type;
  late String createdAt = "";
  late UserModel user;

  NotificationModel.fromJson(Map<String,dynamic> json) :
      id = json["id"] ?? 0,
        contents = json["contents"] ?? "",
        targetId = json["target_id"] ?? "",
        isRead = json["is_read"] ?? true,
        type = json["type"] ?? 0,
        createdAt = json["created_at"] ?? "",
        user = UserModel.fromJson(json["user"] ?? {});

}
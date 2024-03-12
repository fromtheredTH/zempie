
import 'package:app/models/User.dart';

class ReplyModel {
  late int id;
  late String content;
  late int countGood;
  late int countBad;
  late int countReply;
  late String createdAt;
  late String updatedAt;
  late UserModel user;
  late dynamic? target;
  late int myReply;
  late bool isLike;

  ReplyModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 1,
        content = json['content'] ?? "",
        countGood = json['count_good'] ?? 0,
        countBad = json['count_bad'] ?? 0,
        countReply = json['count_reply'] ?? 0,
        createdAt = json['created_at'] ?? "",
        updatedAt = json['updated_at'] ?? "",
        user = UserModel.fromJson(json['user'] ?? {}),
        target = json['description'],
        isLike = json["is_like"] ?? false,
        myReply = json['my_reply'] ?? 0;
}
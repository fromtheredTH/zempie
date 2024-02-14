import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:app/models/dto/unread_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_unread_res_model.g.dart';

@JsonSerializable()
class ChatUnreadResModel {
  List<UnreadDto> result;

  ChatUnreadResModel({required this.result});

  factory ChatUnreadResModel.fromJson(Map<String, dynamic> json) {
    return _$ChatUnreadResModelFromJson(json);
  }
}

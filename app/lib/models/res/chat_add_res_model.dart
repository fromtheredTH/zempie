import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_add_res_model.g.dart';

@JsonSerializable()
class ChatAddResModel {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int room_id;
  ChatMsgDto message;

  ChatAddResModel({required this.room_id, required this.message});

  factory ChatAddResModel.fromJson(Map<String, dynamic> json) {
    return _$ChatAddResModelFromJson(json);
  }
}

import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_msg_res_model.g.dart';

@JsonSerializable()
class ChatMsgResModel {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int totalCount;
  List<ChatMsgDto> result;
  PageInfoDto? pageInfo;

  ChatMsgResModel({required this.totalCount, required this.result, this.pageInfo});

  factory ChatMsgResModel.fromJson(Map<String, dynamic> json) {
    return _$ChatMsgResModelFromJson(json);
  }
}

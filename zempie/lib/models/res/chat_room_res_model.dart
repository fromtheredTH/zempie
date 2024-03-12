import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room_res_model.g.dart';

@JsonSerializable()
class ChatRoomResModel {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int totalCount;
  List<ChatRoomDto> result;
  PageInfoDto? pageInfo;
  List<ChatRoomDto>? updated_rooms;

  ChatRoomResModel({required this.totalCount, required this.result, this.pageInfo, this.updated_rooms});

  factory ChatRoomResModel.fromJson(Map<String, dynamic> json) {
    return _$ChatRoomResModelFromJson(json);
  }
}

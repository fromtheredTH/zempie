import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room_dto.g.dart';

@JsonSerializable()
class ChatRoomDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int id;
  String? last_chat_at;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int last_chat_id;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int creator_id;
  String? creator_uid;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int is_group_room;
  String? created_at;
  String? updated_at;
  String? deleted_at;
  bool? has_name;
  String? name;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int unread_count;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int unread_start_id;
  ChatMsgDto? last_message;
  List<UserDto>? joined_users;

  ChatRoomDto(
      {required this.id,
      this.last_chat_at,
      required this.last_chat_id,
      required this.creator_id,
      required this.creator_uid,
      required this.is_group_room,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.has_name,
      this.name,
      required this.unread_count,
      required this.unread_start_id,
      this.last_message,
      this.joined_users});

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) => _$ChatRoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomDtoToJson(this);
}

@JsonSerializable()
class ChatRoomListDto {
  late final List<ChatRoomDto> result;

  ChatRoomListDto({required this.result});

  factory ChatRoomListDto.fromJson(Map<String, dynamic> json) => _$ChatRoomListDtoFromJson(json);

  Map toJson() => _$ChatRoomListDtoToJson(this);
}

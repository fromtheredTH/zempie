import 'dart:typed_data';

import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_msg_dto.g.dart';

/// Converts to and from [Uint8List] and [List]<[int]>.
class Uint8ListConverter implements JsonConverter<Uint8List?, List<int>?> {
  /// Create a new instance of [Uint8ListConverter].
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(List<int>? json) {
    if (json == null) return null;

    return Uint8List.fromList(json);
  }

  @override
  List<int>? toJson(Uint8List? object) {
    if (object == null) return null;

    return object.toList();
  }
}

@JsonSerializable()
class ChatMsgDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int id;
  String? unsended_at;
  String? contents;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int room_id;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int sender_id;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int type;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int parent_id;
  String? created_at;
  String? updated_at;
  String? deleted_at;
  UserDto? sender;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int chat_idx;
  ChatMsgDto? parent_chat;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int? unread_count;

  int? audioTime;
  bool? isPlayAudio;

  ChatMsgDto(
      {required this.id,
      this.unsended_at,
      this.contents,
      required this.room_id,
      required this.sender_id,
      required this.type,
      required this.parent_id,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.sender,
      required this.chat_idx,
      this.parent_chat,
      this.unread_count,
      this.audioTime,
      this.isPlayAudio});

  factory ChatMsgDto.fromJson(Map<String, dynamic> json) => _$ChatMsgDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMsgDtoToJson(this);
}

@JsonSerializable()
class ChatMsgListDto {
  List<ChatMsgDto>? list;

  ChatMsgListDto();

  factory ChatMsgListDto.fromJson(Map<String, dynamic> json) => _$ChatMsgListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMsgListDtoToJson(this);
}

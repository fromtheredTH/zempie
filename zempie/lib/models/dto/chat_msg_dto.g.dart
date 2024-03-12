// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_msg_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMsgDto _$ChatMsgDtoFromJson(Map<String, dynamic> json) => ChatMsgDto(
      id: fromJsonInt(json['id']),
      unsended_at: json['unsended_at'] as String?,
      contents: json['contents'] as String?,
      room_id: fromJsonInt(json['room_id']),
      sender_id: fromJsonInt(json['sender_id']),
      type: fromJsonInt(json['type']),
      parent_id: fromJsonInt(json['parent_id']),
      created_at: json['created_at'] as String?,
      updated_at: json['updated_at'] as String?,
      deleted_at: json['deleted_at'] as String?,
      sender: json['sender'] == null
          ? null
          : UserDto.fromJson(json['sender'] as Map<String, dynamic>),
      chat_idx: fromJsonInt(json['chat_idx']),
      parent_chat: json['parent_chat'] == null
          ? null
          : ChatMsgDto.fromJson(json['parent_chat'] as Map<String, dynamic>),
      unread_count: fromJsonInt(json['unread_count']),
      audioTime: json['audioTime'] as int?,
      isPlayAudio: json['isPlayAudio'] as bool?,
    );

Map<String, dynamic> _$ChatMsgDtoToJson(ChatMsgDto instance) =>
    <String, dynamic>{
      'id': toJsonInt(instance.id),
      'unsended_at': instance.unsended_at,
      'contents': instance.contents,
      'room_id': toJsonInt(instance.room_id),
      'sender_id': toJsonInt(instance.sender_id),
      'type': toJsonInt(instance.type),
      'parent_id': toJsonInt(instance.parent_id),
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'deleted_at': instance.deleted_at,
      'sender': instance.sender,
      'chat_idx': toJsonInt(instance.chat_idx),
      'parent_chat': instance.parent_chat,
      'unread_count': toJsonInt(instance.unread_count),
      'audioTime': instance.audioTime,
      'isPlayAudio': instance.isPlayAudio,
    };

ChatMsgListDto _$ChatMsgListDtoFromJson(Map<String, dynamic> json) =>
    ChatMsgListDto()
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) => ChatMsgDto.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ChatMsgListDtoToJson(ChatMsgListDto instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

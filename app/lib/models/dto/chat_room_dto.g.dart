// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomDto _$ChatRoomDtoFromJson(Map<String, dynamic> json) => ChatRoomDto(
      id: fromJsonInt(json['id']),
      last_chat_at: json['last_chat_at'] as String?,
      last_chat_id: fromJsonInt(json['last_chat_id']),
      creator_id: fromJsonInt(json['creator_id']),
      creator_uid: json['creator_uid'] as String?,
      is_group_room: fromJsonInt(json['is_group_room']),
      created_at: json['created_at'] as String?,
      updated_at: json['updated_at'] as String?,
      deleted_at: json['deleted_at'] as String?,
      has_name: json['has_name'] as bool?,
      name: json['name'] as String?,
      unread_count: fromJsonInt(json['unread_count']),
      unread_start_id: fromJsonInt(json['unread_start_id']),
      last_message: json['last_message'] == null
          ? null
          : ChatMsgDto.fromJson(json['last_message'] as Map<String, dynamic>),
      joined_users: (json['joined_users'] as List<dynamic>?)
          ?.map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatRoomDtoToJson(ChatRoomDto instance) =>
    <String, dynamic>{
      'id': toJsonInt(instance.id),
      'last_chat_at': instance.last_chat_at,
      'last_chat_id': toJsonInt(instance.last_chat_id),
      'creator_id': toJsonInt(instance.creator_id),
      'creator_uid': instance.creator_uid,
      'is_group_room': toJsonInt(instance.is_group_room),
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'deleted_at': instance.deleted_at,
      'has_name': instance.has_name,
      'name': instance.name,
      'unread_count': toJsonInt(instance.unread_count),
      'unread_start_id': toJsonInt(instance.unread_start_id),
      'last_message': instance.last_message,
      'joined_users': instance.joined_users,
    };

ChatRoomListDto _$ChatRoomListDtoFromJson(Map<String, dynamic> json) =>
    ChatRoomListDto(
      result: (json['result'] as List<dynamic>)
          .map((e) => ChatRoomDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatRoomListDtoToJson(ChatRoomListDto instance) =>
    <String, dynamic>{
      'result': instance.result,
    };

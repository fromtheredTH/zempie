// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomResModel _$ChatRoomResModelFromJson(Map<String, dynamic> json) =>
    ChatRoomResModel(
      totalCount: fromJsonInt(json['totalCount']),
      result: (json['result'] as List<dynamic>)
          .map((e) => ChatRoomDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageInfo: json['pageInfo'] == null
          ? null
          : PageInfoDto.fromJson(json['pageInfo'] as Map<String, dynamic>),
      updated_rooms: (json['updated_rooms'] as List<dynamic>?)
          ?.map((e) => ChatRoomDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatRoomResModelToJson(ChatRoomResModel instance) =>
    <String, dynamic>{
      'totalCount': toJsonInt(instance.totalCount),
      'result': instance.result,
      'pageInfo': instance.pageInfo,
      'updated_rooms': instance.updated_rooms,
    };

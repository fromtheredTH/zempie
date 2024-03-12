// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_add_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatAddResModel _$ChatAddResModelFromJson(Map<String, dynamic> json) =>
    ChatAddResModel(
      room_id: fromJsonInt(json['room_id']),
      message: ChatMsgDto.fromJson(json['message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatAddResModelToJson(ChatAddResModel instance) =>
    <String, dynamic>{
      'room_id': toJsonInt(instance.room_id),
      'message': instance.message,
    };

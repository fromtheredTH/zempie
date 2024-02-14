// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_unread_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUnreadResModel _$ChatUnreadResModelFromJson(Map<String, dynamic> json) =>
    ChatUnreadResModel(
      result: (json['result'] as List<dynamic>)
          .map((e) => UnreadDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatUnreadResModelToJson(ChatUnreadResModel instance) =>
    <String, dynamic>{
      'result': instance.result,
    };

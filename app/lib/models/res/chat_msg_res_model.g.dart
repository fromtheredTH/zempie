// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_msg_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMsgResModel _$ChatMsgResModelFromJson(Map<String, dynamic> json) =>
    ChatMsgResModel(
      totalCount: fromJsonInt(json['totalCount']),
      result: (json['result'] as List<dynamic>)
          .map((e) => ChatMsgDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageInfo: json['pageInfo'] == null
          ? null
          : PageInfoDto.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatMsgResModelToJson(ChatMsgResModel instance) =>
    <String, dynamic>{
      'totalCount': toJsonInt(instance.totalCount),
      'result': instance.result,
      'pageInfo': instance.pageInfo,
    };

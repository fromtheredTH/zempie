// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadDto _$UnreadDtoFromJson(Map<String, dynamic> json) => UnreadDto(
      user_id: fromJsonInt(json['user_id']),
      last_read_id: fromJsonInt(json['last_read_id']),
    );

Map<String, dynamic> _$UnreadDtoToJson(UnreadDto instance) => <String, dynamic>{
      'user_id': toJsonInt(instance.user_id),
      'last_read_id': toJsonInt(instance.last_read_id),
    };

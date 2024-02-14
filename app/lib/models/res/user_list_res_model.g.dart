// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserListResModel _$UserListResModelFromJson(Map<String, dynamic> json) =>
    UserListResModel(
      totalCount: fromJsonInt(json['totalCount']),
      result: (json['result'] as List<dynamic>)
          .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageInfo: json['pageInfo'] == null
          ? null
          : PageInfoDto.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserListResModelToJson(UserListResModel instance) =>
    <String, dynamic>{
      'totalCount': toJsonInt(instance.totalCount),
      'result': instance.result,
      'pageInfo': instance.pageInfo,
    };

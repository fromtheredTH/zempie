// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfoResModel _$UserInfoResModelFromJson(Map<String, dynamic> json) =>
    UserInfoResModel(
      result: UserResModel.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserInfoResModelToJson(UserInfoResModel instance) =>
    <String, dynamic>{
      'result': instance.result,
    };

UserResModel _$UserResModelFromJson(Map<String, dynamic> json) => UserResModel(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserResModelToJson(UserResModel instance) =>
    <String, dynamic>{
      'user': instance.user,
    };

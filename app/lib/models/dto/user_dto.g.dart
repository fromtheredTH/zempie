// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: fromJsonInt(json['id']),
      banned: fromJsonInt(json['banned']),
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      nickname: json['nickname'] as String?,
      channel_id: json['channel_id'] as String?,
      picture: json['picture'] as String?,
      banner_img: json['banner_img'] as String?,
      email: json['email'] as String?,
      is_developer: fromJsonInt(json['is_developer']),
      last_log_in: json['last_log_in'] as String?,
      created_at: json['created_at'] as String?,
      updated_at: json['updated_at'] as String?,
      deleted_at: json['deleted_at'] as String?,
      is_blocked: json['is_blocked'] as bool?,
      follow_you: json['follow_you'] as bool?,
      is_following: json['is_following'] as bool?,
      block_you: json['block_you'] as bool?,
      mutes_you: json['mutes_you'] as bool?,
      is_muted: json['is_muted'] as bool?,
      profile_img: json['profile_img'] as String?,
      followers_cnt: fromJsonInt(json['followers_cnt']),
      followings_cnt: fromJsonInt(json['followings_cnt']),
      type: json['type'] as String?,
      selected: json['selected'] as bool? ?? false,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': toJsonInt(instance.id),
      'banned': toJsonInt(instance.banned),
      'uid': instance.uid,
      'name': instance.name,
      'nickname': instance.nickname,
      'channel_id': instance.channel_id,
      'picture': instance.picture,
      'banner_img': instance.banner_img,
      'email': instance.email,
      'is_developer': toJsonInt(instance.is_developer),
      'last_log_in': instance.last_log_in,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'deleted_at': instance.deleted_at,
      'is_blocked': instance.is_blocked,
      'follow_you': instance.follow_you,
      'is_following': instance.is_following,
      'block_you': instance.block_you,
      'mutes_you': instance.mutes_you,
      'is_muted': instance.is_muted,
      'profile_img': instance.profile_img,
      'followers_cnt': toJsonInt(instance.followers_cnt),
      'followings_cnt': toJsonInt(instance.followings_cnt),
      'type': instance.type,
      'selected': instance.selected,
    };

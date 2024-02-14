import 'package:json_annotation/json_annotation.dart';
import 'package:app/helpers/bind_json.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int id;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int banned;
  String? uid;
  String? name;
  String? nickname;
  String? channel_id;
  String? picture;
  String? banner_img;
  String? email;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int is_developer;
  String? last_log_in;
  String? created_at;
  String? updated_at;
  String? deleted_at;
  bool? is_blocked;
  bool? follow_you;
  bool? is_following;
  bool? block_you;
  bool? mutes_you;
  bool? is_muted;
  String? profile_img;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int followers_cnt;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int followings_cnt;
  String? type;

  bool selected = false;

  UserDto(
      {required this.id,
      required this.banned,
      this.uid,
      this.name,
      this.nickname,
      this.channel_id,
      this.picture,
      this.banner_img,
      this.email,
      required this.is_developer,
      this.last_log_in,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.is_blocked,
      this.follow_you,
      this.is_following,
      this.block_you,
      this.mutes_you,
      this.is_muted,
      this.profile_img,
      required this.followers_cnt,
      required this.followings_cnt,
      this.type,
      this.selected = false});

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

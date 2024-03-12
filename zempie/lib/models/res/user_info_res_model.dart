import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_info_res_model.g.dart';

@JsonSerializable()
class UserInfoResModel {
  UserResModel result;

  UserInfoResModel({required this.result});

  factory UserInfoResModel.fromJson(Map<String, dynamic> json) {
    return _$UserInfoResModelFromJson(json);
  }
}

@JsonSerializable()
class UserResModel {
  UserDto user;

  UserResModel({required this.user});

  factory UserResModel.fromJson(Map<String, dynamic> json) {
    return _$UserResModelFromJson(json);
  }
}

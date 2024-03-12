import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_list_res_model.g.dart';

@JsonSerializable()
class UserListResModel {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int totalCount;
  List<UserDto> result;
  PageInfoDto? pageInfo;

  UserListResModel({required this.totalCount, required this.result, this.pageInfo});

  factory UserListResModel.fromJson(Map<String, dynamic> json) {
    return _$UserListResModelFromJson(json);
  }
}

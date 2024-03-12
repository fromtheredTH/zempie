import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/file_dto.dart';
import 'package:app/models/dto/page_info_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_res_model.g.dart';

@JsonSerializable()
class UploadResModel {
  List<FileDto> result;

  UploadResModel({required this.result});

  factory UploadResModel.fromJson(Map<String, dynamic> json) {
    return _$UploadResModelFromJson(json);
  }
}

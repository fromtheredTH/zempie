import 'package:json_annotation/json_annotation.dart';
import 'package:app/helpers/bind_json.dart';

part 'page_info_dto.g.dart';

@JsonSerializable()
class PageInfoDto {
  bool? hasNextPage;

  PageInfoDto({this.hasNextPage});

  factory PageInfoDto.fromJson(Map<String, dynamic> json) => _$PageInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PageInfoDtoToJson(this);
}

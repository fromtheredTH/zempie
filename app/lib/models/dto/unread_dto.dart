import 'package:json_annotation/json_annotation.dart';
import 'package:app/helpers/bind_json.dart';

part 'unread_dto.g.dart';

@JsonSerializable()
class UnreadDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int user_id;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int? last_read_id;

  UnreadDto({required this.user_id, this.last_read_id});

  factory UnreadDto.fromJson(Map<String, dynamic> json) => _$UnreadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadDtoToJson(this);
}

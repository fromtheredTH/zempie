import 'package:app/helpers/bind_json.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_dto.g.dart';

@JsonSerializable()
class FileDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int priority;
  String? url;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int size;
  String? type;
  String? name;
  bool? is_blind;

  FileDto({required this.priority, this.url, required this.size, this.type, this.name, this.is_blind});

  factory FileDto.fromJson(Map<String, dynamic> json) => _$FileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FileDtoToJson(this);
}

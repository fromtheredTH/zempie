// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadResModel _$UploadResModelFromJson(Map<String, dynamic> json) =>
    UploadResModel(
      result: (json['result'] as List<dynamic>)
          .map((e) => FileDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UploadResModelToJson(UploadResModel instance) =>
    <String, dynamic>{
      'result': instance.result,
    };

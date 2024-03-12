

import 'dart:io';

import 'package:app/models/dto/file_dto.dart';

class PostFileModel {
  late int index;
  late String type; // image, video
  FileDto? dto;
  late File file;
  late File? videoThumbnail;
  bool isBlur = false;

  PostFileModel(int index, String type,File file,File? videoTumbnail) {
    this.index = index;
    this.type = type;
    this.file = file;
    this.videoThumbnail = videoTumbnail;
  }
}
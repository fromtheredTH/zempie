import 'dart:io';

import 'package:app/models/res/upload_res_model.dart';
import 'package:app/models/res/user_info_res_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'global.dart';

part 'app_api_p.g.dart';

@RestApi(baseUrl: API_PLATFORM_URL)
abstract class ApiP {
  factory ApiP(Dio dio, {String baseUrl}) = _ApiP;

  @GET("/user/info")
  Future<UserInfoResModel> userInfo(@Header("Authorization") String bearerToken);

  @POST("/community/att")
  @MultiPart()
  Future<UploadResModel> uploadFile(
      @Header("Authorization") String bearerToken, @Part(name: "files") List<File> files);
}


import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:app/models/GameModel.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Constants/Constants.dart';
import '../Constants/ImageUtils.dart';
import '../helpers/common_util.dart';
import '../models/dto/file_dto.dart';

class DioClient {
  static final String communityBaseUrl = "https://api-extn-com.zempie.com/api/v1"; // 커뮤니티 개발서버
  static final String platformBaseUrl = "https://api-extn-pf.zempie.com/api/v1"; // 플랫폼 개발서버
  // static final String communityBaseUrl = "https://api-community.zempie.com/api/v1"; // 커뮤니티 개발서버
  // static final String platformBaseUrl = "https://api.zempie.com/api/v1"; // 플랫폼 개발서버

  static Dio getInstance(String baseUrl) {
    Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: 45),
          receiveTimeout: Duration(seconds: 30),
          validateStatus: (status) {
            return status! <= 400;
          },
        )
    );
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
          if(!token.isEmpty) {
            options.headers["Authorization"] = "${token}";
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 400) {
            showToast(response.data["error"]["message"]);
            return handler.reject(
                DioException(requestOptions: response.requestOptions));
          } else {
            return handler.next(response);
          }
        },
        onError: (DioError e, handler) async {
          print("::: Api error : $e");

          if (e.response == null) {
            showToast("taost_nework_unable".tr());
          } else {
            try {
              print(e.response?.requestOptions.path);
            } catch (error) {

            }
            try {
              String errorMsg = e.response?.data["message"];
                showToast(errorMsg);
              return;
            } catch (errMsg) {
              print(errMsg);
            }
          }
          return handler.next(e);
        }));
    return dio;
  }

  static Future<Response> getRandomPostings(int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/randomPost", queryParameters: queryData);
  }

  static Future<Response> getUserPostings(String userChannelId, int size, int page){
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/users/${userChannelId}", queryParameters: queryData);
  }

  static Future<Response> getDiscoverTimelinePostings(int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/discover/timeline", queryParameters: queryData);
  }

  static Future<Response> getFollowingPostings(int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/mine", queryParameters: queryData);
  }

  static Future<Response> getCommunities(String communityId, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/communities/${communityId}", queryParameters: queryData);
  }

  static Future<Response> getCommunityChannels(String communityId, String channelId, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/communities/${communityId}/channel/${channelId}", queryParameters: queryData);
  }

  static Future<Response> getTimelineUsers(String channelId, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/users/${channelId}", queryParameters: queryData);
  }

  static Future<Response> getTimelineGames(String gamePath, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/games/${gamePath}", queryParameters: queryData);
  }

  static Future<Response> getDiscovers(int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/discover", queryParameters: queryData);
  }

  static Future<Response> getDiscoverPostings(int size, int page, String postId) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size,
      "post_id":postId
    };
    return getInstance(communityBaseUrl).get("/discover/timeline", queryParameters: queryData);
  }

  static Future<Response> likePost(String postId) {

    return getInstance(communityBaseUrl).post("/post/${postId}/like");
  }

  static Future<Response> unLikePost(String postId) {

    return getInstance(communityBaseUrl).post("/post/${postId}/unlike");
  }

  static Future<Response> searchTotal(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "q" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchPosts(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "posting" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchGame(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "gametitle" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchCommunity(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "community" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchUsers(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "username" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> getGameDetail(String gamePath) {
    return getInstance(platformBaseUrl).get("/launch/game/${gamePath}");
  }

  static Future<Response> getGameTimelines(String gamePath, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/timeline/games/${gamePath}", queryParameters: queryData);
  }

  static Future<Response> getGameReplies(int gameId, int limit, int page, String? sort) {
    Map<String, dynamic> queryData = {
      "game_id" : gameId,
      "limit" : limit,
      "offset" : page*limit,
      "sort" : sort
    };
    return getInstance(platformBaseUrl).get("/game/reply", queryParameters: queryData);
  }

  static Future<Response> getGameReReplies(int parentId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "reply_id" : parentId,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(platformBaseUrl).get("/game/rereply", queryParameters: queryData);
  }

  static Future<Response> deleteGameReply(int replyId) {
    return getInstance(platformBaseUrl).delete("/game/replies/${replyId}");
  }

  static Future<Response> postGameReplyLike(int replyId, bool isLike) {
    Map<String, dynamic> queryData = {
      "reply_id" : replyId,
      "reaction" : isLike ? 1 : 0,
    };
    return getInstance(platformBaseUrl).post("/game/reply/reaction", queryParameters: queryData);
  }


  static Future<Response> getGameFollowers(int gameId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/game/${gameId}/list/follower");
  }

  static Future<Response> postGameFollow(int gameId) {
    final formData = jsonEncode({
      "target_game_id": gameId
    });
    return getInstance(communityBaseUrl).post("/user/game-follow", data: formData);
  }
  static Future<Response> postGameUnFollow(int gameId) {
    final formData = jsonEncode({
      "target_game_id": gameId
    });
    return getInstance(communityBaseUrl).post("/user/game-unfollow", data: formData);
  }

  static Future<Response> postUserFollow(int userId) {
    final formData = jsonEncode({
      "target_user_id": userId
    });
    return getInstance(communityBaseUrl).post("/user/follow", data: formData);
  }

  static Future<Response> postUserUnFollow(int userId) {
    final formData = jsonEncode({
      "target_user_id": userId
    });
    return getInstance(communityBaseUrl).post("/user/unfollow", data: formData);
  }

  static Future<Response> postUserBlock(int userId) {
    return getInstance(communityBaseUrl).post("/member/${userId}/block");
  }

  static Future<Response> getCommunityTimelines(String communityId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/timeline/communities/${communityId}", queryParameters: queryData);
  }

  static Future<Response> getCommunityChannelTimelines(String communityId, String channelId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/timeline/communities/${communityId}/channel/${channelId}", queryParameters: queryData);
  }

  static Future<Response> getCommunityDetail(String communityId) {
    return getInstance(communityBaseUrl).get("/community/${communityId}");
  }

  static Future<Response> getCommunitySubscribe(String communityId) {
    return getInstance(communityBaseUrl).post("/community/${communityId}/subscribe");
  }

  static Future<Response> getCommunityUnSubscribe(String communityId) {
    return getInstance(communityBaseUrl).post("/community/${communityId}/unsubscribe");
  }

  static Future<Response> getCommunityList(String sort, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit,
      "sort" : sort
    };
    return getInstance(communityBaseUrl).get("/community/list", queryParameters: queryData);
  }

  static Future<Response> getMyCommunityList(String sort, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit,
      "sort" : sort
    };
    return getInstance(communityBaseUrl).get("/user/${Constants.user.id}/list/community", queryParameters: queryData);
  }

  static Future<Response> getCommunityUsers(String communityId, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/community/${communityId}/members", queryParameters: queryData);
  }

  static Future<Response> getPostLikeUsers(String postId, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/post/${postId}/like/list", queryParameters: queryData);
  }

  static Future<Response> getUserFollowings(int userId, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/user/${userId}/list/following/user", queryParameters: queryData);
  }

  static Future<Response> getUserFollowers(int userId, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/user/${userId}/list/follower", queryParameters: queryData);
  }


  static Future<Response> sendGameComment(int gameId, String content, int? parentId) {
    final formData = jsonEncode({
      "game_id": gameId,
      "reply_id": parentId,
      "content": content
    });
    return getInstance(platformBaseUrl).post("/game/reply", data: formData);
  }

  static Future<Response> getGameReply(String commentId) {
    return getInstance(platformBaseUrl).get("/game/reply/${commentId}");
  }

  static Future<Response> editGameComment(int replyId, String content) {
    final formData = jsonEncode({
      "content": content
    });
    return getInstance(platformBaseUrl).put("/game/replies/${replyId}", data: formData);
  }

  static Future<Response> removeGameComment(int replyId) {
    return getInstance(platformBaseUrl).delete("/game/replies/${replyId}");
  }



  static Future<Response> getPostComments(String postId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page,
      "sort" : "RECENT"
    };
    return getInstance(communityBaseUrl).get("/post/${postId}/comment/list", queryParameters: queryData);
  }

  static Future<Response> getPostComment(String commentId) {
    return getInstance(communityBaseUrl).get("/post/comments/${commentId}");
  }

  static Future<Response> getPostReReplies(String parentId, int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page
    };
    return getInstance(communityBaseUrl).get("/post/comments/${parentId}/list", queryParameters: queryData);
  }

  static Future<Response> postPostReplyLike(String replyId) {
    return getInstance(communityBaseUrl).post("/post/comments/${replyId}/like");
  }

  static Future<Response> postPostReplyUnLike(String replyId) {
    return getInstance(communityBaseUrl).post("/post/comments/${replyId}/unlike");
  }

  static Future<Response> sendPostComment(String postId, String content, String? parentId) {
    final formData = jsonEncode({
      "type":"COMMENT",
      "is_private":false,
      "post_id": postId,
      "reply_id": parentId,
      "contents": content,
      "parent_id":parentId
    });
    return getInstance(communityBaseUrl).post("/post/comment", data: formData);
  }

  static Future<Response> editPostComment(String replyId, String content) {
    final formData = jsonEncode({
      "contents": content
    });
    return getInstance(communityBaseUrl).patch("/post/comment/${replyId}", data: formData);
  }

  static Future<Response> removePostComment(String replyId) {
    return getInstance(communityBaseUrl).delete("/post/comments/${replyId}");
  }
  static Future<Response> removePost(String postId) {
    return getInstance(communityBaseUrl).delete("/post/${postId}");
  }

  static Future<Response> getUserGameList(int userId) {
    return getInstance(communityBaseUrl).get("/user/${userId}/list/following/game");
  }

  static Future<Response> getUserCommunityList(int userId, int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page,
    };
    return getInstance(communityBaseUrl).get("/user/${userId}/list/community", queryParameters: queryData);
  }

  static Future<Response> getPost(String postId){
    return getInstance(communityBaseUrl).get("/post/${postId}");
  }

  static Future<Response> uploadPosting(String content, List<FileDto> files, List<Map<String,dynamic>> channels, GameModel? game, int? backgroundId){
    final dataMap = Map<String,dynamic>();
    
    dataMap["contents"] = content;
    if(files.isNotEmpty)
      dataMap["attatchment_files"] = files.map((e) => e.toJson()).toList();
    if(channels.isNotEmpty)
      dataMap["communities"] = channels;
    if(backgroundId != null)
      dataMap["background_id"] = backgroundId;
    if(game != null)
      dataMap["games"] = [game].map((e) => e.toJson()).toList();

    final formData = jsonEncode(dataMap);
    return getInstance(communityBaseUrl).post("/post", data: formData);
  }

  static Future<Response> editPosting(String postingId, String content, List<FileDto> files, List<Map<String,dynamic>> channels, GameModel? game, int? backgroundId){
    final dataMap = Map<String,dynamic>();

    dataMap["contents"] = content;
    if(files.isNotEmpty)
      dataMap["attatchment_files"] = files.map((e) => e.toJson()).toList();
    if(channels.isNotEmpty)
      dataMap["communities"] = channels;
    if(backgroundId != null)
      dataMap["background_id"] = backgroundId;
    if(game != null)
      dataMap["games"] = [game].map((e) => e.toJson()).toList();

    final formData = jsonEncode(dataMap);
    return getInstance(communityBaseUrl).patch("/post/${postingId}", data: formData);
  }

  static Future<Response> translate(String content){
    Map<String, dynamic> queryData = {
      "text" : content,
      "target" : Constants.translationCode,
    };
    return getInstance(platformBaseUrl).post("/translate", data: queryData);
  }

  static Future<Response> checkNickname(String nickname) {
    final formData = jsonEncode({
      "nickname":nickname
    });
    return getInstance(platformBaseUrl).post("/user/has-nickname", data: formData);
  }

  static Future<Response> checkEmail(String email) {
    final formData = jsonEncode({
      "email":email
    });
    return getInstance(platformBaseUrl).post("/user/has-email", data: formData);
  }

  static Future<Response> getTranslationList() {
    return getInstance(platformBaseUrl).get("/lang-list");
  }

  static Future<Response> signUp(String nickname, String name) {
    final formData = jsonEncode({
      "nickname":nickname,
      "name" : name
    });
    return getInstance(platformBaseUrl).post("/user/sign-up", data: formData);
  }

  static Future<Response> updateProfile(String? jobDept, String? jobGroup, String? jobPosition, String? country, String? city, String? interestGameGenre, String? interestGenre) {
    final formData = jsonEncode({
      "job_dept":jobDept,
      "job_group":jobGroup,
      "job_position":jobPosition,
      "country":country,
      "city":city,
      "interest_game_genre":interestGameGenre,
      "state_msg": interestGenre
    });
    return getInstance(platformBaseUrl).post("/user/profile", data: formData);
  }

  static Future<Response> updateAllProfile(String? jobDept, String? jobGroup, String? jobPosition, String? country, String? city, String? interestGameGenre, String? interestGenre, String linkName, String link, String description) {
    final formData = jsonEncode({
      "job_dept":jobDept,
      "job_group":jobGroup,
      "job_position":jobPosition,
      "country":country,
      "city":city,
      "interest_game_genre":interestGameGenre,
      "state_msg": interestGenre,
      "link_name": linkName,
      "link": link,
      "description": description
    });
    return getInstance(platformBaseUrl).post("/user/profile", data: formData);
  }

  static Future<Response> updateAccount(String name, String nickname) {
    final formData = jsonEncode({
      "name":name,
      "nickname":nickname,
      "lang" : Constants.languageCode == "ko" ? 1 : 2
    });
    return getInstance(platformBaseUrl).post("/user/update/account", data: formData);
  }

  static Future<Response> getCountryList() {

    return getInstance(platformBaseUrl).get("/country-list");
  }

  static Future<Response> getBgList() {
    return getInstance(platformBaseUrl).get("/post-bg");
  }

  static Future<Response> getUserQR() {
    return getInstance(platformBaseUrl).get("/user/qr");
  }

  static Future<Response> getNotification(int limit, int offset, String date) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : offset,
      "from" : date
    };
    return getInstance(communityBaseUrl).get("/notification",queryParameters: queryData);
  }

  static Future<Response> getUser(String nickname) {
    return getInstance(platformBaseUrl).get("/user/${nickname}");
  }
  static Future<Response> updateUserProfile(File? profileFile, File? bannerFile, bool? rmPicture, bool? rmBanner) async {

    Dio dio = getInstance(platformBaseUrl);
    dio.options.contentType = "multipart/form-data";

    final dataMap = Map<String,dynamic>();

    if(profileFile != null){
      File sendFile = await ImageUtils.resizeImageFile(profileFile);
      dataMap["file"] = MultipartFile.fromFileSync(sendFile.path);
    }

    if(bannerFile != null){
      File sendFile = await ImageUtils.resizeImageFile(bannerFile);
      dataMap["banner_file"] = MultipartFile.fromFileSync(sendFile.path);
    }
    if(rmPicture != null) {
      dataMap["rm_picture"] = rmPicture;
    }
    if(rmBanner != null) {
      dataMap["rm_banner"] = rmBanner;
    }

    FormData formData = FormData.fromMap(dataMap);


    return dio.post("/user/update/info", data: formData);
  }

  static Future<Response> settingQuestion(String text, String email) {
    final formData = jsonEncode({
      "text":text,
      "email":email
    });
    return getInstance(platformBaseUrl).post("/support/inquiry", data: formData);
  }

  static Future<Response> getBlockUsers(int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/user/block-list", queryParameters: queryData);
  }

  static Future<Response> userUnBlock(int userId) {
    return getInstance(communityBaseUrl).post("/member/${userId}/unblock");
  }

  static Future<Response> setDMAlarmRange(int range) {
    final formData = jsonEncode({
      "type":"chat",
      "range":range
    });
    return getInstance(platformBaseUrl).patch("/user/alarm-setting", data: formData);
  }

  static Future<Response> getUserChatRoom(int userId) {
    Map<String, dynamic> queryData = {
      "limit" : 1,
      "offset" : 0,
      "perfact": true,
      "user_ids" : userId
    };
    return getInstance(platformBaseUrl).get("/user/alarm-setting", queryParameters: queryData);
  }

  static Future<Response> setAlarm(String type, bool value) {
    final formData = jsonEncode({
      "type":type,
      "state":value
    });
    return getInstance(platformBaseUrl).patch("/user/alarm", data: formData);
  }

  static Future<Response> alramRead() {
    return getInstance(communityBaseUrl).put("/notification/read-all");
  }

  static Future<Response> reportPost(String id, String enums, String reason) {
    final formData = jsonEncode({
      "post_id": id,
      "report_reason":enums,
      "reason":reason
    });
    return getInstance(communityBaseUrl).post("/post/report", data: formData);
  }

  static Future<Response> reportComment(int id, String enums, String reason) {
    final formData = jsonEncode({
      "comment_id": id,
      "report_reason":enums,
      "reason":reason
    });
    return getInstance(communityBaseUrl).post("/comment/report", data: formData);
  }

  static Future<Response> reportUser(int id, String enums, String reason) {
    final formDataMap = {
      "target_id": id,
      "reason_num":enums,
      "reason":reason
    };
    FormData formData = FormData.fromMap(formDataMap);
    return getInstance(platformBaseUrl).post("/report/user", data: formData);
  }

  static Future<Response> reportGameComment(int id, String enums, String reason) {
    final formDataMap = {
      "target_id": id,
      "reason_num":enums,
      "reason":reason
    };
    FormData formData = FormData.fromMap(formDataMap);

    return getInstance(platformBaseUrl).post("/report/game-comment", data: formData);
  }

  static Future<Response> reportGame(int id, String enums, String reason) {
    final formDataMap = {
      "target_id": id,
      "reason_num":enums,
      "reason":reason
    };
    FormData formData = FormData.fromMap(formDataMap);

    return getInstance(platformBaseUrl).post("/report/game", data: formData);
  }

  static Future<Response> getChatRoomFromMessage(String id) {

    return getInstance(communityBaseUrl).get("/messages/${id}");
  }

  static Future<Response> deleteNotification(int id) {

    return getInstance(communityBaseUrl).delete("/notification/${id}");
  }
}
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/res/chat_add_res_model.dart';
import 'package:app/models/res/chat_msg_res_model.dart';
import 'package:app/models/res/chat_room_res_model.dart';
import 'package:app/models/res/chat_unread_res_model.dart';
import 'package:app/models/res/upload_res_model.dart';
import 'package:app/models/res/user_list_res_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'global.dart';

part 'app_api_c.g.dart';

@RestApi(baseUrl: API_COMMUNITY_URL)
abstract class ApiC {
  factory ApiC(Dio dio, {String baseUrl}) = _ApiC;

  @POST("/fcm")
  Future<String> setFcmToken(
    @Header("Authorization") String bearerToken,
    @Body() String body,
  );

  @DELETE("/fcm")
  Future<String> delFcmToken(
    @Header("Authorization") String bearerToken,
    @Query("token") String token,
  );

  @GET("/chat/rooms")
  Future<ChatRoomResModel> chatRoomList(
    @Header("Authorization") String bearerToken,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @GET("/search")
  Future<UserListResModel> userSearchList(
    @Header("Authorization") String bearerToken,
    @Query("q") String q,
    @Query("username") String username,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @GET("/user/{user_id}/list/following")
  Future<UserListResModel> userFollowingList(
    @Path("user_id") int userId,
    @Header("Authorization") String bearerToken,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @POST("/chat/room")
  Future<ChatRoomDto> createChatRoom(
    @Header("Authorization") String bearerToken,
    @Body() String body,
  );

  @DELETE("/chat/rooms/{room_id}")
  Future<String> leaveChatRoom(
    @Path("room_id") int roomId,
    @Header("Authorization") String bearerToken,
  );

  @POST("/chat/room-name")
  Future<String> changeRoomName(
    @Header("Authorization") String bearerToken,
    @Body() String body,
  );

  @GET("/chat/{room_id}/info")
  Future<ChatRoomDto> getChatRoomInfo(
    @Path("room_id") int roomId,
    @Header("Authorization") String bearerToken,
  );

  @GET("/chat/rooms/{room_id}")
  Future<ChatMsgResModel> chatList(
    @Path("room_id") int roomId,
    @Header("Authorization") String bearerToken,
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("order") String order,
  );

  @DELETE("/chat/{chat_id}")
  Future<String> deleteChat(
    @Path("chat_id") int chatId,
    @Header("Authorization") String bearerToken,
  );

  @POST("/chat")
  Future<ChatAddResModel> addChat(
    @Header("Authorization") String bearerToken,
    @Body() String body,
  );

  @GET("/chat/rooms/{room_id}/ri")
  Future<ChatUnreadResModel> getChatUnread(
    @Path("room_id") int roomId,
    @Header("Authorization") String bearerToken,
  );
}

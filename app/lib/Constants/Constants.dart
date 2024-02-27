
import 'package:app/models/res/btn_bottom_sheet_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global/app_api_p.dart';
import '../models/dto/chat_room_dto.dart';
import '../models/dto/user_dto.dart';
import '../utils/ChatRoomUtils.dart';
import 'ImageConstants.dart';

class Constants {
  static List<ChatRoomDto> localChatRooms = [];
  static UserDto? me;

  static Future<void> fetchChatRooms() async {
    Constants.localChatRooms = await ChatRoomUtils.getChatRooms();
  }

  static Future<void> getMe(ApiP apiP) async {
    apiP.userInfo("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}").then((value) async {
      me = value.result.user;
    }).catchError((Object obj) {});
  }
}
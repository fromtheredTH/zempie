//user level
const String API_COMMUNITY_URL = "https://api-extn-com.zempie.com/api/v1/";
const String API_PLATFORM_URL = "https://api-extn-pf.zempie.com/api/v1";

int gLang = 0; //Overall language: if isLogin user.lang else local_service.lang
String gPushKey = "";
int gChatRoomUid = 0;
int gCurrentId = 0;

enum eChatType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
  HTML,
}

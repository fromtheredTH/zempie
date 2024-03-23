
import 'dart:convert';
import 'dart:typed_data';

import 'package:app/Constants/utils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/BackgroundModel.dart';
import 'package:app/models/CountryModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/models/res/btn_bottom_sheet_model.dart';
import 'package:app/pages/screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/app_api_p.dart';
import '../global/global.dart';
import '../helpers/common_util.dart';
import '../models/CommunityModel.dart';
import '../models/MatchEnumModel.dart';
import '../models/NotificationModel.dart';
import '../models/TranslationModel.dart';
import '../models/User.dart';
import '../models/dto/chat_room_dto.dart';
import '../models/dto/user_dto.dart';
import '../pages/screens/onboard_screen.dart';
import '../utils/ChatRoomUtils.dart';
import 'ImageConstants.dart';

class Constants {
  static List<ChatRoomDto> localChatRooms = [];
  static UserModel user = UserModel.fromJson({});
  static List<UserModel> myFollowings = [];
  static List<CommunityModel> followCommunities = [];
  static List<GameModel> followGames = [];
  static List<BackgroundModel> bgLists = [];
  static Uint8List? userQrCode;
  static List<NotificationModel> notifications = [];
  static String languageCode = "";
  static String translationCode = "";
  static String translationName = "";
  static List<TranslationModel> translationModel = [];
  static String cachingKey = "";

  static List<String> reportUserLists = [
    "적합하지 않은 콘텐츠 게시",
    "타인 사칭",
    "만 12세 미만 계정",
    "욕설 및 혐오 표현 사용",
    "기타"
  ];

  static List<String> reportLists = [
    "개인정보보호 위반",
    "불쾌하거나 민감한 콘텐츠",
    "불법 콘텐츠",
    "허가되지 않은 광고",
    "지식재산권 침해",
    "기타",
  ];

  static String versionName = "";

  static List<CountryModel> allCountries = [];
  static MatchEnumModel getProfileJobGroup(String id) {
    for(int i=0;i<jobGroups.length;i++){
      if(jobGroups[i].idx.toString() == id){
        return jobGroups[i];
      }
    }
    return MatchEnumModel(100, "ETC", "기타", "ETC", Colors.white);
  }

  static String getNameList(List<MatchEnumModel> items) {
    String result = "";
    if(items.isNotEmpty)
      result = items[0].koName;

    for(int i=1;i<items.length;i++){
      result += ", ${items[i].koName}";
    }
    return result;
  }

  static Future<void> getTranslateCodeList() async {
    var response = await DioClient.getTranslationList();
    translationModel = response.data["result"].map((json) => TranslationModel.fromJson(json)).toList().cast<TranslationModel>();
    print(response);
  }

  static List<MatchEnumModel> jobGroups = [
    MatchEnumModel(1, "CREATOR", "창작자", "CREATOR", Colors.white),
    MatchEnumModel(2,  "VOICE", "음향", "VOICE", Colors.white),
    MatchEnumModel(3, "PUBLISHER", "퍼블리셔", "PUBLISHER", Colors.white),
    MatchEnumModel(4, "INVESTOR", "투자자", "INVESTOR", Colors.white),
    MatchEnumModel(5, "REVIEWER", "리뷰어", "REVIEWER", Colors.white),
    MatchEnumModel(6, "HRM", "인사담당자", "HRM", Colors.white),
    MatchEnumModel(7, "MARKETER", "마케터", "MARKETER", Colors.white),
    MatchEnumModel(8, "BUSINESS", "영업", "BUSINESS", Colors.white),
    MatchEnumModel(9, "SOLUTION", "솔루션", "SOLUTION", Colors.white),
    MatchEnumModel(100, "ETC", "기타", "ETC", Colors.white)
  ];
  static MatchEnumModel getProfileJobPosition(String id) {
    for(int i=0;i<jobPositions.length;i++){
      if(jobPositions[i].idx.toString() == id){
        return jobPositions[i];
      }
    }
    return MatchEnumModel(100, id, id, id, Colors.white);
  }
  static MatchEnumModel getCountr(String id) {
    for(int i=0;i<jobPositions.length;i++){
      if(jobPositions[i].idx.toString() == id){
        return jobPositions[i];
      }
    }
    return MatchEnumModel(100, id, id, id, Colors.white);
  }
  static List<MatchEnumModel> jobPositions = [
    MatchEnumModel(0,  "DEV", "개발", "DEV", Color(0xff2b7dc8)),
    MatchEnumModel(1, "ART", "퍼블리셔", "ART", Color(0xffce4a73)),
    MatchEnumModel(2, "GD", "투자자", "GD", Color(0xffb38950)),
    MatchEnumModel(3, "QA", "리뷰어", "QA", Color(0xff947182)),
    MatchEnumModel(4, "SFX", "인사담당자", "SFX", Color(0xffe2e2a5)),
  ];

  static List<MatchEnumModel> interestGameGenres = [
    MatchEnumModel(0, "ACTION", "액션", "ACTION", Colors.white),
    MatchEnumModel(1, "ADVENTURE", "어드벤처", "ADVENTURE", Colors.white),
    MatchEnumModel(2, "STRATEGY", "전략", "STRATEGY", Colors.white),
    MatchEnumModel(3, "ROLLPLAY", "RPG", "ROLLPLAY", Colors.white),
    MatchEnumModel(4, "SIMULATION", "시뮬레이션", "SIMULATION", Colors.white),
    MatchEnumModel(5, "SPORTS", "스포츠", "SPORTS", Colors.white),
    MatchEnumModel(6, "PUZZLE", "퍼즐", "PUZZLE", Colors.white),
    MatchEnumModel(7, "SHOOTING", "슈팅", "SHOOTING", Colors.white),
    MatchEnumModel(8, "HORROR", "호러", "HORROR", Colors.white),
    MatchEnumModel(9, "FPS", "FPS", "FPS", Colors.white),
    MatchEnumModel(10, "RYTHYM", "리듬", "RYTHYM", Colors.white),
    MatchEnumModel(11, "RACING", "레이싱", "RACING", Colors.white),
    MatchEnumModel(12, "VISUALNOVEL", "비주얼 노벨", "VISUALNOVEL", Colors.white),
    MatchEnumModel(100, "ETC", "기타", "ETC", Colors.white)
  ];

  static List<MatchEnumModel> interestGenres = [
    MatchEnumModel(1, "FIND_JOB", "이직/구직중", "FIND_JOB", Colors.white),
    MatchEnumModel(2, "RECRUITING", "채용중", "RECRUITING", Colors.white),
    MatchEnumModel(3, "FINE_GAME_PARTNER", "게임 개발 파트너 구인중", "FINE_GAME_PARTNER", Colors.white),
    MatchEnumModel(4, "FIND_GAME_INFO", "흥미로운 게임정보 탐색중", "FIND_GAME_INFO", Colors.white),
    MatchEnumModel(5, "FIND_NEW_GAME", "새로운 게임 탐색중", "FIND_NEW_GAME", Colors.white),
    MatchEnumModel(6, "DEVELOPING_GAME", "게임 개발중", "DEVELOPING_GAME", Colors.white),
    MatchEnumModel(7, "COMMUNICATING", "커뮤니티 소통중", "COMMUNICATING", Colors.white),
    MatchEnumModel(100, "ETC", "기타", "ETC", Colors.white)
  ];

  static List<PostModel> discoverPosts = [];
  static bool initDiscoverHasNextPage = false;

  static List<PostModel> timelinePosts = [];
  static bool initTimelineHasNextPage = false;

  static List<CommunityModel> allRecommands = [];
  static bool hasNextAllRecommand = false;

  static List<CommunityModel> allNews = [];
  static bool hasNextAllNew = false;

  static List<CommunityModel> allMembers = [];
  static bool hasNextAllMember = false;

  static List<CommunityModel> allVisits = [];
  static bool hasNextAllVisit = false;

  static List<CommunityModel> myRecents = [];
  static bool hasNextmyRecent = false;

  static List<CommunityModel> myMembers = [];
  static bool hasNextmyMember = false;

  static List<CommunityModel> myVisits = [];
  static bool hasNextmyVisit = false;

  static Future<void> fetchChatRooms() async {
    Constants.localChatRooms = await ChatRoomUtils.getChatRooms();
  }

  static Future<void> getUserInfo(bool isShowLoading, BuildContext context, ApiP apiP) async {
    if(isShowLoading)
      Utils.showDialogWidget(context);
    print(await FirebaseAuth.instance.currentUser?.getIdToken());
    String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
    apiP.userInfo(token).then((value) async {
      Constants.user = UserModel.fromJson(value.data["result"]["user"]);
      await initPosts();
      initBgList();
      initDiscoverPosts();
      initCommunities();
      initCountryModels();
      getQrCode();
      getVersionInfo();
      initNotificationLists();
      getTranslateCodeList();
      gCurrentId = Constants.user.id;

      bool hasFollowerNext = true;
      int followerPage = 0;
      while(hasFollowerNext) {
        var followerRseponse = await DioClient.getUserFollowings(user.id, 100, followerPage);
        List<UserModel> followers = followerRseponse.data["result"] == null ? [] : followerRseponse
            .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
            UserModel>();
        followerPage += 1;
        hasFollowerNext = followerRseponse.data["pageInfo"]?["hasNextPage"] ?? false;
        for(int i=0;i<followers.length;i++){
          if(followers[i].nickname.isEmpty){
            followers.removeAt(i);
            i--;
          }
        }
        myFollowings.addAll(followers);
      }

      bool hasCommunityNext = true;
      int communityPage = 0;
      while(hasCommunityNext) {
        var response = await DioClient.getUserCommunityList(user.id, 100, communityPage);
        List<CommunityModel> communities = response.data["result"] == null ? [] : response
            .data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<
            CommunityModel>();
        communityPage += 1;
        hasCommunityNext = response.data["pageInfo"]?["hasNextPage"] ?? false;
        followCommunities.addAll(communities);
      }

      var gameResponse = DioClient.getUserGameList(user.id);
      gameResponse.then(
              (response) {
                followGames = response.data["result"] == null ? [] : response
                    .data["result"].map((json) => GameModel.fromJson(json)).toList().cast<
                    GameModel>();
              }
      );

      // Get.back();
      Get.offAll(BottomNavBarScreen(),transition: Transition.rightToLeft);
    }).catchError((Object obj) {
      showToast("connection_failed".tr());
      if(isShowLoading)
        Get.back();
    });
  }

  static void removeGameFollow(int id){
    for(int i=0;i<followGames.length;i++){
      if(followGames[i].id == id){
        followGames.removeAt(i);
        break;
      }
    }
  }

  static Future<void> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    versionName = packageInfo.version;
  }

  static void addGameFollow(GameModel game){
    bool isExist = false;
    for(int i=0;i<followGames.length;i++){
      if(followGames[i].id == game.id){
        isExist = true;
        break;
      }
    }
    if(!isExist){
      followGames.add(game);
    }
  }

  static void removeCommunityFollow(String id){
    for(int i=0;i<followCommunities.length;i++){
      if(followCommunities[i].id == id){
        followCommunities.removeAt(i);
        break;
      }
    }
  }

  static void addCommunityFollow(CommunityModel communityModel){
    bool isExist = false;
    for(int i=0;i<followCommunities.length;i++){
      if(followCommunities[i].id == communityModel.id){
        isExist = true;
        break;
      }
    }
    if(!isExist){
      followCommunities.add(communityModel);
    }
  }

  static Future<void> initBgList() async {
    var response = await DioClient.getBgList();
    bgLists = response.data["result"] == null ? [] : response.data["result"].map((json) => BackgroundModel.fromJson(json)).toList().cast<BackgroundModel>();
    print(response);
  }

  static BackgroundModel getBg(int id) {
    for(int i=0;i<bgLists.length;i++){
      if(bgLists[i].id == id){
        return bgLists[i];
      }
    }
    return bgLists[0];
  }

  static Future<void> initDiscoverPosts() async {
    var response = await DioClient.getDiscovers(10, 0);
    discoverPosts = response.data["result"] == null ? [] : response
        .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
        PostModel>();
    initDiscoverHasNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
  }

  static Future<void> initPosts() async {
    var response = await DioClient.getFollowingPostings(5, 0);
    timelinePosts = response.data["result"] == null ? [] : response
        .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
        PostModel>();
    initTimelineHasNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
  }

  static Future<void> initCommunities() async {
    var allRecommandResponse = DioClient.getCommunityList("created_at", 10, 0);
    allRecommandResponse.then(
            (response) {
              allRecommands = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              hasNextAllRecommand = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var allNewResponse = DioClient.getCommunityList("created_at", 10, 0);
    allNewResponse.then(
            (response) {
              allNews = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              hasNextAllNew = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var allMemberResponse = DioClient.getCommunityList("member_cnt", 10, 0);
    allMemberResponse.then(
            (response) {
              allMembers = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              hasNextAllMember = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var allVisitResponse = DioClient.getCommunityList("visit_cnt", 10, 0);
    allVisitResponse.then(
            (response) {
              allVisits = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              hasNextAllVisit = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var myRecentResponse = DioClient.getMyCommunityList("created_at", 10, 0);
    myRecentResponse.then(
            (response) {
              myRecents = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              for(int i=0;i<myRecents.length;i++){
                myRecents[i].isSubscribed = true;
              }
              hasNextmyRecent = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var myMemberResponse = DioClient.getMyCommunityList("member_cnt", 10, 0);
    myMemberResponse.then(
            (response) {
              myMembers = response.data["result"] == null
                  ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
              for(int i=0;i<myMembers.length;i++){
                myMembers[i].isSubscribed = true;
              }
              hasNextmyMember = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );

    var myVisitResponse = DioClient.getMyCommunityList("visit_cnt", 10, 0);
    myVisitResponse.then(
            (response) {
          myVisits = response.data["result"] == null
              ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
          for(int i=0;i<myVisits.length;i++){
            myVisits[i].isSubscribed = true;
          }
          hasNextmyVisit = response.data["pageInfo"]?["hasNextPage"] ?? false;
        }
    );
  }

  static Future<void> initCountryModels() async {
    allCountries.clear();
    var response = await DioClient.getCountryList();
    allCountries = response.data["result"] != null ? response.data["result"].map((json) => CountryModel.fromJson(json)).toList().cast<CountryModel>() : [];
  }

  static String getCountryName(String code) {
    for(int i=0;i<allCountries.length;i++){
      if(allCountries[i].code == code){
        return allCountries[i].nameModel.ko;
      }
    }
    return "대한민국";
  }

  static CountryModel getCountryModel(String code) {
    for(int i=0;i<allCountries.length;i++){
      if(allCountries[i].code == code){
        return allCountries[i];
      }
    }
    return allCountries[0];
  }

  static String getUserStateMsg(String code) {
    List<String> items = code.split(",");
    String result = "";
    for(int i=0;i<items.length;i++){
      for(int k=0;k<interestGenres.length;k++){
        if(interestGenres[k].idx.toString() == items[i]) {
          if(result.isEmpty) {
            result += interestGenres[k].koName;
          }else{
            result += ", ${interestGenres[k].koName}";
          }
          break;
        }
      }
    }

    return result;
  }

  static List<MatchEnumModel> getUserStateList(String code) {
    List<String> items = code.split(",");
    List<MatchEnumModel> result = [];
    for(int i=0;i<items.length;i++){
      for(int k=0;k<interestGenres.length;k++){
        if(interestGenres[k].idx.toString() == items[i]) {
          result.add(interestGenres[k]);
          break;
        }
      }
    }

    return result;
  }

  static List<MatchEnumModel> getUserGameGenryList(String code) {
    List<String> items = code.split(",");
    List<MatchEnumModel> result = [];
    for(int i=0;i<items.length;i++){
      for(int k=0;k<interestGameGenres.length;k++){
        if(interestGameGenres[k].idx.toString() == items[i]) {
          result.add(interestGameGenres[k]);
          break;
        }
      }
    }

    return result;
  }

  static Future<void> getQrCode() async {
    var response = await DioClient.getUserQR();
    print(response);
    String data = response.data["result"]["qr"];
    userQrCode = Base64Decoder().convert(data);
  }

  static Future<void> initNotificationLists() async {
    DateTime notiTime = DateTime.now().subtract(Duration(days: 60));
    DateFormat format = DateFormat("yyyy-MM-dd 00:00:00");
    var response = await DioClient.getNotification(100, 0, format.format(notiTime));
    notifications = response.data["result"].map((json) => NotificationModel.fromJson(json)).toList().cast<NotificationModel>();
  }

  static String getNotificationStr(int type) {
    if(type == 8){
      return "님이 회원님을 팔로우했습니다.";
    }else if(type == 9){
      return "님이 답글을 달았습니다.";
    }else if(type == 4) {
      return "님이 포스팅에 댓글을 남겼습니다.";
    }else if(type == 5){
      return "님이 댓글에 좋아요를 눌렀습니다.";
    }else if(type == 3){
      return "님이 회원님의 포스팅에 좋아요를 눌렀습니다.";
    }else if(type == 10){
      return "님이 메시지를 보냈습니다.";
    }else if(type == 11){
      return "님이 포스트에 멘션 했습니다.";
    }else if(type == 19){
      return "님이 게임 댓글에서 멘션 했습니다.";
    }else if(type == 20){
      return "님이 게임에 댓글을 달았습니다.";
    }

    return "";
  }

  static String getNotificationTime(String createdAt) {
    DateTime now = DateTime.now();
    DateTime createdTime = DateTime.parse(createdAt);
    Duration difference = now.difference(createdTime);
    if(difference.inDays < 1){
      if(difference.inHours < 1){
        if(difference.inMinutes < 1){
          return "${difference.inSeconds}초";
        }
        return "${difference.inMinutes}분";
      }
      return "${difference.inHours}시간";
    }else{
      DateFormat formatter = DateFormat('MM월 dd일 a hh:mm');
      String strToday = formatter.format(createdTime);
      return strToday;
    }
  }
}
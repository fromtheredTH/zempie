
import 'package:app/models/CoinModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ProfileModel.dart';
import 'package:app/models/SettingModel.dart';

import '../pages/components/item/mentionable_text_field/src/mentionable_text_field.dart';

class UserModel extends Mentionable{
  late int id;
  late String uid;
  late String name;
  late String nickname;
  late String channelId;
  late String email;
  late String picture;
  late String urlBanner;
  late bool isDeveloper;
  late bool idVerified;
  late int followingCnt;
  late int followerCnt;
  late UserMeta meta;
  late ProfileModel profile;
  late SettingModel setting;
  late CoinModel coin;
  late List<GameModel> games;
  late bool emailVerified;
  late bool followYou;
  late bool isFollowing;
  late bool blockYou;
  late bool isBlocked;
  late bool mutesYou;
  late bool isMuted;
  late VerifiedInfoModel verifiedInfo;

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        uid = json['uid'] ?? "",
        name = json['name'] ?? "",
        nickname = json['nickname'] ?? "",
        channelId = json['channel_id'] ?? "",
        email = json['email'] ?? "",
        picture = json['picture'] ?? json["profile_img"] ?? "",
        urlBanner = json['url_banner'] ?? "",
        isDeveloper = json['is_developer'] != null ? json['is_developer'] is int ? json['is_developer'] == 1 ? true : false : json['is_developer'] : false,
        idVerified = json['id_verified'] ?? false,
        followYou = json['follow_you'] ?? false,
        isFollowing = json['is_following'] ?? false,
        blockYou = json['block_you'] != null ? json['block_you'] is int ? json['block_you'] == 1 ? true : false : json['block_you'] : false,
        isBlocked = json['is_blocked'] ?? false,
        mutesYou = json['mutes_you'] != null ? json['mutes_you'] is int ? json['mutes_you'] == 1 ? true : false : json['mutes_you'] : false,
        isMuted = json['is_muted'] ?? false,
        followingCnt = json['following_cnt'] ?? 0,
        followerCnt = json['follower_cnt'] ?? 0,
        meta = UserMeta.fromJson(json['meta'] ?? {}),
        profile = ProfileModel.fromJson(json['profile'] ?? {}),
        setting = SettingModel.fromJson(json['setting'] ?? {}),
        coin = CoinModel.fromJson(json['coin'] ?? {}),
        verifiedInfo = VerifiedInfoModel.fromJson(json["verified_info"] ?? {}),
        games = json['games'] != null ? json["games"].map((gameJson) => GameModel.fromJson(gameJson)).toList().cast<GameModel>() : [],
        emailVerified = json['email_verified'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'channel_id': channelId,
      'email': email,
      'picture': picture,
      'url_banner': urlBanner,
      'is_developer': isDeveloper == 1,
      'id_verified': idVerified,
      'following_cnt': followingCnt,
      'follower_cnt': followerCnt,
      'meta': meta.toJson(),
      'profile': profile.toJson(),
      'setting': setting.toJson(),
      'coin': coin.toJson(),
      'games': games.map((game) => game.toJson()).toList(),
      'email_verified': emailVerified,
    };
  }

  @override
  // TODO: implement mentionLabel
  String get mentionLabel => "${nickname}";
}

class UserMeta {
  late int unreadNotiCount;

  UserMeta.fromJson(Map<String, dynamic> json)
      : unreadNotiCount = json['unread_noti_count'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'unread_noti_count': unreadNotiCount
    };
  }
}

class VerifiedInfoModel {
  late String mobileNum;
  late String birthdate;

  VerifiedInfoModel.fromJson(Map<String, dynamic> json)
      : mobileNum = json['mobile_num'] ?? "",
        birthdate = json['birthdate'] ?? "";
}


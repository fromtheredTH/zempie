
class SettingModel {
  late int theme;
  late dynamic themeExtra;
  late int language;
  late bool battle;
  late bool beat;
  late bool alarm;
  late DmModel dm;
  late LikeModel like;
  late ReplyModel reply;
  late FollowModel follow;

  SettingModel.fromJson(Map<String, dynamic> json)
      : theme = json['theme'] ?? 0,
        themeExtra = json['theme_extra'],
        language = json['language'] ?? 0,
        battle = json['battle'] ?? false,
        beat = json['beat'] ?? false,
        alarm = json['alarm'] ?? false,
        dm = DmModel.fromJson(json['dm'] ?? {}),
        like = LikeModel.fromJson(json['like'] ?? {}),
        reply = ReplyModel.fromJson(json['reply'] ?? {}),
        follow = FollowModel.fromJson(json['follow'] ?? {});

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'theme_extra': themeExtra,
      'language': language,
      'battle': battle,
      'beat': beat,
      'alarm': alarm,
      'dm': dm.toJson(),
      'like': like.toJson(),
      'reply': reply.toJson(),
      'follow': follow.toJson(),
    };
  }
}

class DmModel {
  late bool state;
  late int range;

  DmModel.fromJson(Map<String, dynamic> json)
      : state = json['state'] ?? false,
        range = json['range'] ?? 2;

  Map<String, dynamic> toJson() {
    return {'state': state, 'range': range};
  }
}

class LikeModel {
  late bool state;
  late int range;

  LikeModel.fromJson(Map<String, dynamic> json)
      : state = json['state'] ?? false,
        range = json['range'] ?? 1;

  Map<String, dynamic> toJson() {
    return {'state': state, 'range': range};
  }
}

class ReplyModel {
  late bool state;
  late int range;

  ReplyModel.fromJson(Map<String, dynamic> json)
      : state = json['state'] ?? false,
        range = json['range'] ?? 1;

  Map<String, dynamic> toJson() {
    return {'state': state, 'range': range};
  }
}

class FollowModel {
  late bool state;
  late int range;

  FollowModel.fromJson(Map<String, dynamic> json)
      : state = json['state'] ?? false,
        range = json['range'] ?? 1;

  Map<String, dynamic> toJson() {
    return {'state': state, 'range': range};
  }
}

class ProfileModel {
  late int level;
  late int exp;
  late String stateMsg;
  late String description;
  late String urlBanner;
  late String jobDept;
  late String jobGroup;
  late String jobPosition;
  late String country;
  late String city;
  late String interestGameGenre;
  late String linkName;
  late String link;
  late String languages;

  ProfileModel.fromJson(Map<String, dynamic> json)
      : level = json['level'] ?? 1,
        exp = json['exp'] ?? 0,
        stateMsg = json['state_msg'] ?? "",
        description = json['description'] ?? "",
        urlBanner = json['url_banner'] ?? "",
        jobDept = json['job_dept'] ?? "",
        jobGroup = json['job_group'] ?? "",
        jobPosition = json['job_position'] ?? "",
        country = json['country'] ?? "",
        city = json['city'] ?? "",
        interestGameGenre = json['interest_game_genre'] ?? "",
        linkName = json['link_name'] ?? "",
        link = json['link'] ?? "",
        languages = json['languages'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'exp': exp,
      'state_msg': stateMsg,
      'description': description,
      'url_banner': urlBanner,
      'job_dept': jobDept,
      'job_group': jobGroup,
      'job_position': jobPosition,
      'country': country,
      'city': city,
      'interest_game_genre': interestGameGenre,
      'link_name': linkName,
      'link': link,
      'languages': languages,
    };
  }
}

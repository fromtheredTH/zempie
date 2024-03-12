
class CountryModel {
  late String code;
  late CountryNameModel nameModel;

  CountryModel.fromJson(Map<String, dynamic> json)
      : code = json['code'] ?? true,
        nameModel = CountryNameModel.fromJson(json["name"] ?? {});
}


class CountryNameModel {
  late String en;
  late String ko;

  CountryNameModel.fromJson(Map<String, dynamic> json)
      : en = json['en'] ?? "",
        ko = json["ko"] ?? "";
}


class TranslationModel {
  late String en;
  late String origin;
  late String code;

  TranslationModel.fromJson(Map<String, dynamic> json)
      : en = json['en'] ?? "",
        code = json['code'] ?? "",
        origin = json['origin'] ?? "";
}
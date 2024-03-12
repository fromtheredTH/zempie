
class EmotionsModel {
  late int e1;
  late int e2;
  late int e3;
  late int e4;
  late int e5;

  EmotionsModel.fromJson(Map<String, dynamic> json)
      : e1 = json['e1'] ?? 0,
        e2 = json['e2'] ?? 0,
        e3 = json['e3'] ?? 0,
        e4 = json['e4'] ?? 0,
        e5 = json['e5'] ?? 0;

  Map<String, dynamic> toJson() {
    return {'e1': e1, 'e2': e2, 'e3': e3, 'e4': e4, 'e5': e5};
  }
}

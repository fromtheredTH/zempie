
class CoinModel {
  late int zem;
  late int pie;

  CoinModel.fromJson(Map<String, dynamic> json)
      : zem = json['zem'] ?? 0,
        pie = json['pie'] ?? 0;

  Map<String, dynamic> toJson() {
    return {'zem': zem, 'pie': pie};
  }
}


class BackgroundModel {
  int id;
  String imgUrl;
  String hexColor;
  bool isPublic;

  BackgroundModel.fromJson(Map<String,dynamic> json) :
      id = json["id"] ?? 0,
  imgUrl = json["img_url"] ?? "",
  hexColor = json["hex_color"] ?? 0xffffffff,
  isPublic = json["is_public"] ?? true;
  
}
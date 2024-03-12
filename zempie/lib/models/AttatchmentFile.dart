
class AttachmentFile {
  late int priority;
  late String url;
  late String size;
  late String type;
  late String name;
  late bool isBlind;
  late String thumbnail;

  AttachmentFile.fromJson(Map<String, dynamic> json)
      : priority = json['priority'] ?? 0,
        url = json['url'] ?? "",
        size = json['size'].toString() ?? "",
        type = json['type'] ?? "",
        name = json['name'] ?? "",
        isBlind = json['is_blind'] ?? false,
        thumbnail = json['thumbnail'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'priority': priority,
      'url': url,
      'size': size,
      'type': type,
      'name': name,
      'is_blind': isBlind,
      'thumbnail': thumbnail,
    };
  }
}

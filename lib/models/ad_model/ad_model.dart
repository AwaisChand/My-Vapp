class AdModel {
  int? status;
  String? message;
  List<AdItem> data;

  AdModel({this.status, this.message, this.data = const []});

  AdModel.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        message = json['message'],
        data = json['data'] != null
            ? (json['data'] as List).map((e) => AdItem.fromJson(e)).toList()
            : [];
}

class AdItem {
  int? id;
  String? title;
  String? description;
  String? mediaType;
  String? mediaUrl;
  int? viewTimeSeconds;
  String? redirectUrl;

  AdItem({
    this.id,
    this.title,
    this.description,
    this.mediaType,
    this.mediaUrl,
    this.viewTimeSeconds,
    this.redirectUrl,
  });

  AdItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        mediaType = json['media_type'],
        mediaUrl = json['media_url'],
        viewTimeSeconds = json['view_time_seconds'] is int
            ? json['view_time_seconds']
            : int.tryParse('${json['view_time_seconds']}'),
        redirectUrl = json['redirect_url'];
}

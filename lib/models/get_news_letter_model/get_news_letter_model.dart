import '../../utils/json_cast.dart';

class GetNewsLetterModel {
  String? message;
  int? status;
  List<Data>? data;

  GetNewsLetterModel({this.message, this.status, this.data});

  GetNewsLetterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = JsonCast.asInt(json['status']);
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? imageUrl;
  String? mediaType;
  String? attachmentUrl;
  String? expiryDate;
  bool? isExpired;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.title,
        this.imageUrl,
        this.mediaType,
        this.attachmentUrl,
        this.expiryDate,
        this.isExpired,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = JsonCast.asInt(json['id']);
    title = json['title'];
    imageUrl = json['image_url'] ?? json['media_url'];
    mediaType = json['media_type'];
    attachmentUrl = json['attachment_url'];
    expiryDate = json['expiry_date'];
    isExpired = json['is_expired'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image_url'] = imageUrl;
    data['attachment_url'] = attachmentUrl;
    data['expiry_date'] = expiryDate;
    data['is_expired'] = isExpired;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

import '../../utils/json_cast.dart';

class CheckBirthdayModel {
  String? dob;
  int? status;
  String? formattedDob;
  String? upcomingDate;
  int? daysRemaining;

  CheckBirthdayModel({
    this.dob,
    this.status,
    this.formattedDob,
    this.upcomingDate,
    this.daysRemaining,
  });

  CheckBirthdayModel.fromJson(Map<String, dynamic> json) {
    dob = json['dob'];
    status = JsonCast.asInt(json['status']);
    formattedDob = json['formatted_dob'];
    upcomingDate = json['upcoming_date'];
    daysRemaining = JsonCast.asInt(json['days_remaining']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dob'] = dob;
    data['status'] = status;
    data['formatted_dob'] = formattedDob;
    data['upcoming_date'] = upcomingDate;
    data['days_remaining'] = daysRemaining;
    return data;
  }
}

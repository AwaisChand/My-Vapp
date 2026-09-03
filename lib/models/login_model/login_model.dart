class LoginModel {
  String? message;
  String? accessToken;
  String? tokenType;
  User? user;

  LoginModel({this.message, this.accessToken, this.tokenType, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? companyName;
  String? email;
  Null emailVerifiedAt;
  String? phone;
  String? avatar;
  String? avatarUrl;
  String? country;
  String? code;
  Null address;
  String? description;
  Null permissions;
  String? role;
  String? teamRole;
  String? status;
  String? dob;
  Null emailVerificationCode;
  String? createdAt;
  String? updatedAt;
  Null stripeId;
  Null pmType;
  Null pmLastFour;
  Null trialEndsAt;
  String? otp;
  String? otpExpiresAt;

  User(
      {this.id,
        this.name,
        this.firstName,
        this.lastName,
        this.companyName,
        this.email,
        this.emailVerifiedAt,
        this.phone,
        this.avatar,
        this.avatarUrl,
        this.country,
        this.code,
        this.address,
        this.description,
        this.permissions,
        this.role,
        this.teamRole,
        this.status,
        this.dob,
        this.emailVerificationCode,
        this.createdAt,
        this.updatedAt,
        this.stripeId,
        this.pmType,
        this.pmLastFour,
        this.trialEndsAt,
        this.otp,
        this.otpExpiresAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    companyName = json['company_name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    avatar = json['avatar'];
    avatarUrl = json['avatar_url'];
    country = json['country'];
    code = json['code'];
    address = json['address'];
    description = json['description'];
    permissions = json['permissions'];
    role = json['role'];
    teamRole = json['team_role'];
    status = json['status'];
    dob = json['dob'];
    emailVerificationCode = json['email_verification_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    stripeId = json['stripe_id'];
    pmType = json['pm_type'];
    pmLastFour = json['pm_last_four'];
    trialEndsAt = json['trial_ends_at'];
    otp = json['otp'];
    otpExpiresAt = json['otp_expires_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['company_name'] = companyName;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['avatar_url'] = avatarUrl;
    data['country'] = country;
    data['code'] = code;
    data['address'] = address;
    data['description'] = description;
    data['permissions'] = permissions;
    data['role'] = role;
    data['team_role'] = teamRole;
    data['status'] = status;
    data['dob'] = dob;
    data['email_verification_code'] = emailVerificationCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['stripe_id'] = stripeId;
    data['pm_type'] = pmType;
    data['pm_last_four'] = pmLastFour;
    data['trial_ends_at'] = trialEndsAt;
    data['otp'] = otp;
    data['otp_expires_at'] = otpExpiresAt;
    return data;
  }
}

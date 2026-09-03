class AppUrl {
  static const String _envBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://myvapp.app/',
  );

  static String get baseUrl {
    if (_envBase.endsWith('/')) return _envBase;
    return '$_envBase/';
  }

  // Auth
  static var loginEndPoint = '${baseUrl}api/auth/signin';
  static var logoutEndPoint = '${baseUrl}api/auth/signout';

  // Password & profile
  static var sendOtpEndPoint = '${baseUrl}api/password/send-otp';
  static var verifyOtpEndPoint = '${baseUrl}api/password/verify-otp';
  static var resendOtpEndPoint = '${baseUrl}api/password/resend-otp';
  static var resetPasswordEndPoint = '${baseUrl}api/password/reset';
  static var userProfileEndPoint = '${baseUrl}api/password/profile';
  static var settingsEndPoint = '${baseUrl}api/password/settings';

  // Customer dashboard
  static var dashboardEndPoint = '${baseUrl}api/dashboard';
  static var profileEndPoint = '${baseUrl}api/profile';
  static var languageEndPoint = '${baseUrl}api/language';

  // Cashback & loyalty
  static var redeemPointsHistoryEndPoint = '${baseUrl}api/redeemed-points';
  static var redeemNowEndPoint = '${baseUrl}api/redeemed-now';
  static var loyaltyPointsEndPoint = '${baseUrl}api/loyalty-points';

  // Orders
  static var orderHistoryEndPoint = '${baseUrl}api/orders';

  // Promotions
  static var couponsEndPoint = '${baseUrl}api/coupons';
  static var applyCouponEndPoint = '${baseUrl}api/apply-coupon';
  static var offersEndPoint = '${baseUrl}api/offers';
  static var birthdayEndPoint = '${baseUrl}api/birthday';
  static var checkBirthdayEndPoint = '${baseUrl}api/check-birthday';

  // Content
  static var getNewsLetterEndPoint = '${baseUrl}api/newsletters';
  static var getNewsLetterDetailEndPoint = '${baseUrl}api/newsletter';
  static var adsEndPoint = '${baseUrl}api/ads';

  // Vape calculator & Vapofumeur
  static var vapeSavingsEndPoint = '${baseUrl}api/vape-savings';
  static var vapeSlipsHistoryEndPoint = '${baseUrl}api/vape-savings/slips/history';
  static var vapeSlipsEndPoint = '${baseUrl}api/vape-savings/slips';

  static String vapeSavingDeleteEndPoint(int id) => '${baseUrl}api/vape-savings/$id';
}

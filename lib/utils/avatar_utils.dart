import '../res/app_url.dart';

class AvatarUtils {
  static String resolve({String? avatarUrl, String? avatar}) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        return avatar;
      }
      return '${AppUrl.baseUrl}avatars/$avatar';
    }
    return '${AppUrl.baseUrl}avatars/avatar.png';
  }

  static bool hasCustomAvatar({String? avatarUrl, String? avatar}) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      final lower = avatarUrl.toLowerCase();
      if (!lower.contains('avatar.png')) {
        return true;
      }
    }

    if (avatar != null && avatar.isNotEmpty) {
      final lower = avatar.toLowerCase();
      if (lower != 'avatar.png' && !lower.endsWith('/avatar.png')) {
        return true;
      }
    }

    return false;
  }
}

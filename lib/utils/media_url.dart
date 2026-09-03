import 'package:lim_crm/res/app_url.dart';

class MediaUrl {
  static String resolve(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    final parsed = Uri.tryParse(value);
    if (parsed == null) return value;

    final base = Uri.parse(AppUrl.baseUrl);
    final host = parsed.host.toLowerCase();
    final needsRewrite = host.isEmpty ||
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0';

    if (!needsRewrite) return value;

    return parsed
        .replace(
          scheme: base.scheme.isEmpty ? 'http' : base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
        )
        .toString();
  }

  static bool isImage(String url) {
    final path = _path(url);
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].any(path.endsWith);
  }

  static bool isVideo(String url) {
    final path = _path(url);
    return ['.mp4', '.webm', '.mov', '.avi', '.m4v', '.ogg'].any(path.endsWith);
  }

  static bool isPdf(String url) => _path(url).endsWith('.pdf');

  static String _path(String url) {
    try {
      return Uri.parse(url).path.toLowerCase();
    } catch (_) {
      return url.toLowerCase();
    }
  }
}

import 'package:lim_crm/models/ad_model/ad_model.dart';

const _videoExtensions = ['mp4', 'mov', 'avi', 'webm', 'mkv'];

extension AdItemMedia on AdItem {
  bool get isVideo {
    if (mediaType?.toLowerCase() == 'video') return true;
    if (mediaType?.toLowerCase() == 'image') return false;

    final url = mediaUrl?.toLowerCase() ?? '';
    if (url.isEmpty) return false;

    final path = url.split('?').first;
    return _videoExtensions.any((ext) => path.endsWith('.$ext'));
  }

  bool get isImage => !isVideo;

  int get clampedViewTimeSeconds =>
      (viewTimeSeconds ?? 6).clamp(1, 120);

  bool get hasRedirectUrl =>
      redirectUrl != null && redirectUrl!.trim().isNotEmpty;
}

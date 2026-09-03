import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/ad_model/ad_model.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/utils/ad_media_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_colors.dart';

class AdCarousel extends StatefulWidget {
  final List<AdItem> ads;

  const AdCarousel({super.key, required this.ads});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  static const _aspectRatio = 16 / 10;

  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _scheduleAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant AdCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads) {
      _currentPage = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _scheduleAutoAdvance();
    }
  }

  @override
  void dispose() {
    _clearAutoTimer();
    _controller.dispose();
    super.dispose();
  }

  void _clearAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _scheduleAutoAdvance() {
    _clearAutoTimer();
    if (widget.ads.length <= 1 || !mounted) return;

    final ad = widget.ads[_currentPage];
    if (ad.isVideo) return;

    final seconds = ad.clampedViewTimeSeconds;
    _autoTimer = Timer(Duration(seconds: seconds), _advanceToNext);
  }

  void _scheduleVideoFallback() {
    _clearAutoTimer();
    if (widget.ads.length <= 1 || !mounted) return;

    final seconds = widget.ads[_currentPage].clampedViewTimeSeconds;
    _autoTimer = Timer(Duration(seconds: seconds), _advanceToNext);
  }

  void _advanceToNext() {
    if (!mounted || widget.ads.length <= 1) return;
    final next = (_currentPage + 1) % widget.ads.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openRedirect(AdItem ad) async {
    final url = ad.redirectUrl?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    final loopVideo = widget.ads.length <= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: _aspectRatio,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.ads.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _scheduleAutoAdvance();
            },
            itemBuilder: (context, index) {
              final ad = widget.ads[index];
              return _AdSlide(
                ad: ad,
                isActive: index == _currentPage,
                loopVideo: loopVideo && ad.isVideo,
                onTap: () => _openRedirect(ad),
                onVideoPlayStarted: _clearAutoTimer,
                onVideoCompleted: loopVideo ? null : _advanceToNext,
                onVideoPlaybackFailed: _scheduleVideoFallback,
              );
            },
          ),
        ),
        if (widget.ads.length > 1) ...[
          const SizedBox(height: 12),
          Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: widget.ads.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.border,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdSlide extends StatefulWidget {
  final AdItem ad;
  final bool isActive;
  final bool loopVideo;
  final VoidCallback onTap;
  final VoidCallback onVideoPlayStarted;
  final VoidCallback? onVideoCompleted;
  final VoidCallback onVideoPlaybackFailed;

  const _AdSlide({
    required this.ad,
    required this.isActive,
    required this.loopVideo,
    required this.onTap,
    required this.onVideoPlayStarted,
    this.onVideoCompleted,
    required this.onVideoPlaybackFailed,
  });

  @override
  State<_AdSlide> createState() => _AdSlideState();
}

class _AdSlideState extends State<_AdSlide> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _playbackFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.ad.isVideo) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant _AdSlide oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.ad.isVideo) return;

    if (oldWidget.ad.mediaUrl != widget.ad.mediaUrl ||
        oldWidget.loopVideo != widget.loopVideo) {
      _disposeVideo();
      _initVideo();
      return;
    }

    if (!oldWidget.isActive && widget.isActive) {
      _resetAndPlayVideo();
    } else if (oldWidget.isActive && !widget.isActive) {
      _pauseVideo(resetPosition: true);
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  Future<void> _initVideo() async {
    final url = widget.ad.mediaUrl;
    if (url == null || url.isEmpty) {
      widget.onVideoPlaybackFailed();
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;
    controller.addListener(_handleVideoProgress);

    try {
      await controller.initialize();
      if (!mounted || _videoController != controller) {
        controller.removeListener(_handleVideoProgress);
        await controller.dispose();
        return;
      }

      controller
        ..setLooping(widget.loopVideo)
        ..setVolume(0);

      setState(() {
        _videoReady = true;
        _playbackFailed = false;
      });

      if (widget.isActive) {
        await _resetAndPlayVideo();
      }
    } catch (_) {
      controller.removeListener(_handleVideoProgress);
      if (_videoController == controller) {
        _videoController = null;
      }
      await controller.dispose();
      if (mounted) {
        setState(() {
          _videoReady = false;
          _playbackFailed = true;
        });
      }
      widget.onVideoPlaybackFailed();
    }
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        !widget.isActive ||
        widget.loopVideo ||
        widget.onVideoCompleted == null) {
      return;
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 200)) {
      controller.removeListener(_handleVideoProgress);
      widget.onVideoCompleted!.call();
    }
  }

  Future<void> _resetAndPlayVideo() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    await controller.pause();
    await controller.seekTo(Duration.zero);

    try {
      await controller.play();
      widget.onVideoPlayStarted();
    } catch (_) {
      if (mounted) {
        setState(() => _playbackFailed = true);
      }
      widget.onVideoPlaybackFailed();
    }
  }

  Future<void> _pauseVideo({bool resetPosition = false}) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    await controller.pause();
    if (resetPosition) {
      await controller.seekTo(Duration.zero);
    }
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    _videoReady = false;
    _playbackFailed = false;
    if (controller != null) {
      controller.removeListener(_handleVideoProgress);
      await controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        decoration: PortalUi.cardDecoration(radius: 16),
        clipBehavior: Clip.antiAlias,
        child: widget.ad.isVideo ? _buildVideo() : _buildImage(),
      ),
    );
  }

  Widget _buildVideo() {
    final controller = _videoController;
    if (_playbackFailed || !_videoReady || controller == null || !controller.value.isInitialized) {
      return _mediaPlaceholder(
        icon: Icons.videocam_off_outlined,
        message: _playbackFailed ? 'Video unavailable' : null,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        ..._overlayContent(showDescription: false),
      ],
    );
  }

  Widget _buildImage() {
    final ad = widget.ad;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (ad.mediaUrl != null && ad.mediaUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: ad.mediaUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => _mediaPlaceholder(icon: Icons.image_outlined),
            errorWidget: (_, __, ___) => _mediaPlaceholder(icon: Icons.broken_image_outlined),
          )
        else
          _mediaPlaceholder(icon: Icons.image_outlined),
        if ((ad.title ?? '').isNotEmpty || (ad.description ?? '').isNotEmpty)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ..._overlayContent(showDescription: true),
      ],
    );
  }

  List<Widget> _overlayContent({required bool showDescription}) {
    final ad = widget.ad;
    final widgets = <Widget>[];

    if (ad.hasRedirectUrl) {
      widgets.add(
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.open_in_new,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }

    if ((ad.title ?? '').isNotEmpty) {
      widgets.add(
        Positioned(
          left: showDescription ? 16 : 12,
          right: showDescription ? 16 : 12,
          bottom: showDescription ? 16 : 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: showDescription
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: showDescription
                    ? null
                    : BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                child: Text(
                  ad.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: showDescription ? FontWeight.w700 : FontWeight.w600,
                    fontSize: showDescription ? 16 : 12,
                  ),
                ),
              ),
              if (showDescription && (ad.description ?? '').isNotEmpty)
                Text(
                  ad.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _mediaPlaceholder({required IconData icon, String? message}) {
    return Container(
      color: AppColors.scaffoldBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary.withValues(alpha: 0.45),
              size: 48,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

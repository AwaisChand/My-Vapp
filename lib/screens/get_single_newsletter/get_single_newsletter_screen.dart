import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/media_url.dart';
import 'package:pdfx/pdfx.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GetSingleNewsletterScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? imageUrl;
  final String? mediaType;

  const GetSingleNewsletterScreen({
    super.key,
    required this.title,
    required this.url,
    this.imageUrl,
    this.mediaType,
  });

  @override
  State<GetSingleNewsletterScreen> createState() => _GetSingleNewsletterScreenState();
}

class _GetSingleNewsletterScreenState extends State<GetSingleNewsletterScreen> {
  WebViewController? _webController;
  VideoPlayerController? _videoController;
  PdfControllerPinch? _pdfController;
  Uint8List? _imageBytes;
  bool _loading = true;
  String? _error;

  late final String _attachment;
  late final String _cover;

  @override
  void initState() {
    super.initState();
    _attachment = MediaUrl.resolve(widget.url);
    _cover = MediaUrl.resolve(widget.imageUrl);
    _loadAttachment();
  }

  Future<void> _loadAttachment() async {
    if (_attachment.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Attachment not available.';
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(_attachment));
      if (!mounted) return;

      if (response.statusCode == 404 || response.statusCode == 410) {
        setState(() {
          _loading = false;
          _error = 'Attachment not available.';
        });
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 400) {
        _openInWebView(_attachment);
        return;
      }

      final contentType = (response.headers['content-type'] ?? '').toLowerCase();
      final bytes = response.bodyBytes;

      if (contentType.contains('pdf') || MediaUrl.isPdf(_attachment)) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(bytes),
        );
        setState(() => _loading = false);
        return;
      }

      if (contentType.startsWith('image/') || MediaUrl.isImage(_attachment)) {
        setState(() {
          _imageBytes = bytes;
          _loading = false;
        });
        return;
      }

      if (contentType.startsWith('video/') || MediaUrl.isVideo(_attachment)) {
        await _initVideo(_attachment);
        return;
      }

      _openInWebView(_attachment);
    } catch (_) {
      if (!mounted) return;
      _openInWebView(_attachment);
    }
  }

  Future<void> _initVideo(String url) async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);
      await controller.play();
      if (!mounted) return;
      setState(() {
        _videoController = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _openInWebView(url);
    }
  }

  void _openInWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    setState(() {
      _webController = controller;
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _loading) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          widget.title.isEmpty ? 'Newsletter' : widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _body()),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_error != null &&
        _pdfController == null &&
        _imageBytes == null &&
        _videoController == null &&
        _webController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textMuted),
          ),
        ),
      );
    }

    if (_pdfController != null) {
      return PdfViewPinch(controller: _pdfController!);
    }

    if (_imageBytes != null) {
      return InteractiveViewer(
        minScale: 0.8,
        maxScale: 4,
        child: Center(
          child: Image.memory(_imageBytes!, fit: BoxFit.contain),
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    if (_webController != null) {
      return WebViewWidget(controller: _webController!);
    }

    if (_cover.isNotEmpty && _error != null) {
      return InteractiveViewer(
        child: Center(
          child: CachedNetworkImage(imageUrl: _cover, fit: BoxFit.contain),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../res/app_localization.dart';
import '../../../res/portal_ui.dart';
import '../../../utils/app_colors.dart';

class VapeWebLinkTab extends StatefulWidget {
  const VapeWebLinkTab({
    super.key,
    required this.titleKey,
    required this.titleFallback,
    required this.pageUrl,
    required this.icon,
  });

  final String titleKey;
  final String titleFallback;
  final String pageUrl;
  final IconData icon;

  @override
  State<VapeWebLinkTab> createState() => _VapeWebLinkTabState();
}

class _VapeWebLinkTabState extends State<VapeWebLinkTab> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _error = error.description;
            });
          },
        ),
      );
    _loadPage();
  }

  Future<void> _loadPage() async {
    await _controller.loadRequest(Uri.parse(widget.pageUrl));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.translate(widget.titleKey) ?? widget.titleFallback;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            PortalUi.pageHeader(
              context: context,
              title: title,
              icon: widget.icon,
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_error == null)
                    WebViewWidget(controller: _controller)
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PortalUi.gradientButton(
                              label: l10n.translate('retry') ?? 'Retry',
                              onPressed: _loadPage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_loading)
                    const ColoredBox(
                      color: Colors.white54,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

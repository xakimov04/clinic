import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthScreenMobile extends StatefulWidget {
  final Uri authUri;
  final void Function(String code, String deviceID) authCallback;

  final Widget? closeButton;
  final EdgeInsets closeButtonPadding;
  final Alignment closeButtonAlignment;

  const OAuthScreenMobile(
      {super.key,
      required this.authUri,
      required this.authCallback,
      this.closeButton,
      this.closeButtonPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
      this.closeButtonAlignment = Alignment.bottomCenter});

  @override
  State createState() => _OAuthScreenMobileState();
}

class _OAuthScreenMobileState extends State<OAuthScreenMobile> {
  var _redirectUri = "";
  final _webViewController = WebViewController();
  var _authorized = false;

  // Loading states
  bool _isPageLoading = true;
  bool _isAuthProcessing = false;
  String _loadingMessage = "Загрузка страницы авторизации...";

  @override
  void initState() {
    super.initState();
    _redirectUri = widget.authUri.queryParameters["redirect_uri"] ?? "";
    _setupWebViewController();
    _webViewController.loadRequest(widget.authUri);
  }

  void _setupWebViewController() {
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setBackgroundColor(Colors.transparent);

    // Page loading progress tracking
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onPageStarted: (String url) {
          if (mounted) {
            setState(() {
              _isPageLoading = true;
              _loadingMessage = "Загрузка страницы...";
            });
          }
        },
        onPageFinished: (String url) {
          if (mounted) {
            setState(() {
              _isPageLoading = false;
            });
          }
        },
        onWebResourceError: (WebResourceError error) {
          if (mounted) {
            setState(() {
              _isPageLoading = false;
              _loadingMessage = "Ошибка загрузки страницы";
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _webViewController.clearCache();
    _webViewController.clearLocalStorage();
  }

  NavigationDecision _onNavigationRequest(NavigationRequest req) {
    if (!mounted) {
      return NavigationDecision.prevent;
    }

    if (_redirectUri.isNotEmpty && req.url.startsWith(_redirectUri)) {
      if (_authorized) {
        return NavigationDecision.prevent;
      }

      // Start auth processing
      setState(() {
        _isAuthProcessing = true;
        _loadingMessage = "Обработка авторизации...";
      });

      final authorizeUri = Uri.tryParse(req.url);
      if (authorizeUri == null) {
        if (kDebugMode) {
          print("Unable to parse authorization data - Invalid request URL '" +
              req.url +
              '\'');
        }
        setState(() {
          _isAuthProcessing = false;
          _loadingMessage = "Ошибка авторизации";
        });
        return NavigationDecision.prevent;
      }

      _authorized = true;
      final code = authorizeUri.queryParameters["code"] ?? "";
      final deviceId = authorizeUri.queryParameters["device_id"] ?? "";

      // Simulate processing delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.authCallback(code, deviceId);
          final stateContext = context;
          if (stateContext.mounted) {
            Navigator.of(stateContext).pop();
          }
        }
      });

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 3.0,
        ),
        const SizedBox(height: 24),
        Text(
          _loadingMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthProcessingOverlay() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 3.0,
            ),
            const SizedBox(height: 16),
            Text(
              _loadingMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Пожалуйста, подождите...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SizedBox(
              height: mediaQuery.size.height,
              width: mediaQuery.size.width,
              child: WebViewWidget(controller: _webViewController),
            ),

            // Page loading indicator
            if (_isPageLoading && !_isAuthProcessing)
              Align(child: _buildLoadingIndicator()),

            // Auth processing overlay
            if (_isAuthProcessing) Align(child: _buildAuthProcessingOverlay()),

            // Close button (only show when not processing auth)
            if (!_isAuthProcessing)
              Align(
                alignment: widget.closeButtonAlignment,
                child: Padding(
                  padding: widget.closeButtonPadding,
                  child: widget.closeButton,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

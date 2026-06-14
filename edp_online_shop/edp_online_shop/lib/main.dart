import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'notification_page.dart';
import 'support_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF102AEA),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bobController;
  late Animation<double> _animation;
  late Animation<double> _bobAnimation;
  String _version = "";
  
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _hasCheckedConnectivity = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _bobController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _bobAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _bobController, curve: Curves.easeInOut));
    _bobController.repeat(reverse: true);

    _getAppVersion();
    _showWelcomeNotification();
    _checkInitialConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool isNowOnline = results.any((result) => result != ConnectivityResult.none);
      if (isNowOnline != _isOnline) {
        setState(() => _isOnline = isNowOnline);
        if (_isOnline && _hasCheckedConnectivity) _navigateToMain();
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    _hasCheckedConnectivity = true;
    
    if (_isOnline) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isOnline) _navigateToMain();
      });
    } else {
      setState(() {});
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyWebView()),
      );
    }
  }

  Future<void> _showWelcomeNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'welcome_channel', 'Welcome Notifications',
      importance: Importance.max, priority: Priority.high, icon: '@mipmap/launcher_icon');
    await flutterLocalNotificationsPlugin.show(0, 'Welcome to EDP Online Shop!', 'Thank you for opening our app.', const NotificationDetails(android: androidPlatformChannelSpecifics));
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = packageInfo.version);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bobController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF102AEA);
    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: ClipOval(child: Image.asset("assets/images/logo.png", fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 20),
                    const Text("EDP Online Shop", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          if (!_isOnline)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 60, color: themeColor),
                        const SizedBox(height: 20),
                        const Text("No Internet Connection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Please check your internet settings. The app will resume automatically once connected.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _bobAnimation,
              builder: (context, child) => Transform.translate(offset: Offset(0, -_bobAnimation.value), child: child),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
                  child: Text("Version $_version", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});
  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => _loadingProgress = progress / 100);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            // EDP Online Shop-er mukhya domain-er baire gele default browser-e open korbe
            if (!url.contains('edponlineshop.com')) {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            // Onno social/custom links handle kora
            if (url.startsWith('fb://') || url.startsWith('mailto:') || url.startsWith('tel:') || url.startsWith('whatsapp:') || url.contains('m.me') || url.contains('t.me')) {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.edponlineshop.com'));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = _controller.platform as AndroidWebViewController;
      // androidController.setDomStorageEnabled(true); // Conflicted line removed to avoid build error
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setOnShowFileSelector(_androidFilePicker);
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool isNowOnline = results.any((result) => result != ConnectivityResult.none);
      if (isNowOnline != _isOnline) {
        setState(() => _isOnline = isNowOnline);
        if (_isOnline) _controller.reload();
      }
    });
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    final ImagePicker picker = ImagePicker();
    final List<String> filePaths = [];
    if (params.mode == FileSelectorMode.openMultiple) {
      final List<XFile> images = await picker.pickMultiImage();
      for (var image in images) filePaths.add(Uri.file(image.path).toString());
    } else {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) filePaths.add(Uri.file(image.path).toString());
    }
    return filePaths;
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone, Permission.notification, Permission.photos, Permission.storage].request();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF102AEA);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          final shouldExit = await _showCustomExitDialog(context);
          if (shouldExit ?? false) SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: themeColor, statusBarIconBrightness: Brightness.light),
          backgroundColor: themeColor, elevation: 0, centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(backgroundColor: Colors.white, child: ClipOval(child: Image.asset("assets/images/logo.png", fit: BoxFit.cover))),
          ),
          title: const Text("EDP Online Shop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          actions: [
            IconButton(icon: const Icon(Icons.headset_mic, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage()))),
            IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()))),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_loadingProgress < 1.0)
                  LinearProgressIndicator(value: _loadingProgress, backgroundColor: Colors.white, color: themeColor, minHeight: 2),
                Expanded(
                  child: RefreshIndicator(
                    color: themeColor,
                    onRefresh: () async => await _controller.reload(),
                    child: WebViewWidget(controller: _controller),
                  ),
                ),
              ],
            ),
            if (!_isOnline)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 60, color: themeColor),
                        const SizedBox(height: 20),
                        const Text("No Internet Connection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Please check your internet. The page will reload automatically once connected.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCustomExitDialog(BuildContext context) {
    const themeColor = Color(0xFF102AEA);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: ClipOval(child: Image.asset("assets/images/logo.png", fit: BoxFit.cover)),
              ),
              const SizedBox(height: 20),
              const Text("Exit App?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Are you sure you want to close EDP Online Shop?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: themeColor)), onPressed: () => Navigator.pop(context, false), child: const Text("No", style: TextStyle(color: themeColor)))),
                  const SizedBox(width: 15),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(context, true), child: const Text("Yes", style: TextStyle(color: Colors.white)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

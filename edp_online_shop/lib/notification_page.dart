import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;
  
  String appName = "";
  String version = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();

    // Fade and Slide entry animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    // Smooth pulsing/bobbing animation for the icon
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  void _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        appName = packageInfo.appName;
        version = packageInfo.version;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF102AEA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section with matching theme
            Container(
              width: double.infinity,
              height: 10,
              decoration: const BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Notification Icon
                      AnimatedBuilder(
                        animation: _bobAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_bobAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 80,
                                color: themeColor.withOpacity(0.2),
                              ),
                              Image.asset(
                                "assets/images/logo.png",
                                height: 90,
                                width: 90,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 80,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      const Text(
                        "No New Notifications",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "We'll notify you when something important arrives. Stay tuned for exclusive offers and updates!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      // Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Syncing with Server...",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: themeColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer Info
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "v$version | EDP Online Shop",
                style: const TextStyle(color: Colors.black26, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

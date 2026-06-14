import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String appName = "";
  String version = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  // সিস্টেম থেকে অ্যাপের নাম এবং ভার্সন লোড করা
  void _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      version = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  // কল করার ফাংশন
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // সোশ্যাল লিঙ্ক এবং ওয়েবসাইট ওপেন করার ফাংশন
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF102AEA);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Support Center",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ১. লোগো এবং হেডার সেকশন
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 40, top: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: const AssetImage("assets/images/logo.png"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(appName, // ডাইনামিক নাম
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1)),
                  Text("Version: $version", // ডাইনামিক ভার্সন
                      style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ২. অফিসিয়াল কন্টাক্ট সেকশন
            _buildSectionTitle("Official Hotline"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                onTap: () => _makeCall("+8809696585377"),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.redAccent, Colors.red.shade800]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.headset_mic, color: Colors.white, size: 35),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("24/7 Customer Care", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Text("+88 09696-585377", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.call, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ৩. ম্যানেজমেন্ট সেকশন
            _buildSectionTitle("Management Team"),
            _buildMemberCard("Anjan Mukherjee", "Founder & Director", "+88 01614-465919", themeColor),
            _buildMemberCard("Likhi Saha", "Chairman", "+88 01920-235377", themeColor),

            const SizedBox(height: 30),

            // ৪. সোশ্যাল এবং ওয়েবসাইট লিঙ্ক (Original Colors)
            _buildSectionTitle("Connect With Us"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _socialButton(Icons.facebook, "Facebook", const Color(0xFF1877F2), "https://facebook.com/edponlineshop.bd"),
                  _socialButton(Icons.play_circle_fill, "YouTube", const Color(0xFFFF0000), "https://youtube.com/@TeamEdpofBangladesh"),
                  _socialButton(Icons.chat, "WhatsApp", const Color(0xFF25D366), "https://wa.me/8801614465919"),
                  _socialButton(Icons.language, "Website", themeColor, "https://www.edponlineshop.com"),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // ৫. ফুটার সেকশন
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Text(
                    "© ${DateTime.now().year} $appName. All Rights Reserved.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Developed By ", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text("SK Shovon Sheikh", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeColor.withOpacity(0.8))),
                    ],
                  ),
                  const Text("Powered By X Star IT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // সেকশন টাইটেল উইজেট
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ),
    );
  }

  // মেম্বার কার্ড উইজেট (মডার্ন ডিজাইন)
  Widget _buildMemberCard(String name, String position, String phone, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.person, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(position, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.phone_in_talk, color: Colors.green),
          onPressed: () => _makeCall(phone),
        ),
      ),
    );
  }

  // সোশ্যাল বাটন উইজেট
  Widget _socialButton(IconData icon, String label, Color color, String url) {
    return Column(
      children: [
        InkWell(
          onTap: () => _launchURL(url),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }
}
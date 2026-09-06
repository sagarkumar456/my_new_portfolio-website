import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'skill_detail_screen.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  int _downloadCount = 34;
  User? _currentUser;
  
  late AnimationController _orbitController;

  // Contact Form Controllers
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactEmailCtrl = TextEditingController();
  final TextEditingController _contactMsgCtrl = TextEditingController();
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
    _listenToDownloadCount();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactMsgCtrl.dispose();
    super.dispose();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _listenToDownloadCount() {
    _dbRef.child('resume_downloads').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        setState(() {
          _downloadCount = int.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'skdas1641999@gmail.com');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _triggerResumeDownload() async {
    try {
      final ByteData byteData = await rootBundle.load('assets/Resume.pdf');
      final blob = html.Blob([byteData.buffer.asUint8List()], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.AnchorElement(href: url)
        ..setAttribute('download', 'Resume.pdf')
        ..click();
        
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print("Download error: $e");
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_jbrw3hcz.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 15),
            const Text('Download Started!', style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.green, blurRadius: 10)])),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pop(context);
      _triggerResumeDownload();
    });
  }

  void _showMessageSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.pinkAccent, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_s2lryxtd.json', 
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 20),
              const Text('Message Sent!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text(
                'Thank you for reaching out. I will connect with you within 24 hours.', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.cyanAccent, fontSize: 16, height: 1.5)
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('OKAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog() {
    final TextEditingController emailController = TextEditingController();
    bool isChecking = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyanAccent, width: 1), borderRadius: BorderRadius.circular(12)),
            title: const Text('Enter Your Email to Download', style: TextStyle(color: Colors.cyanAccent)),
            content: TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'email@example.com',
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withOpacity(0.1), side: const BorderSide(color: Colors.cyanAccent)),
                onPressed: isChecking ? null : () async {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty && email.contains('@')) {
                    setState(() => isChecking = true);
                    
                    try {
                      final snapshot = await _dbRef.child('resume_emails').orderByChild('email').equalTo(email).once();
                      
                      if (snapshot.snapshot.value != null) {
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You have already downloaded the resume with this email address.'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 4),
                          )
                        );
                        return;
                      }

                      await _dbRef.child('resume_emails').push().set({
                        'email': email,
                        'downloadedAt': DateTime.now().toIso8601String(), 
                      });
                      
                      await _dbRef.child('resume_downloads').set(ServerValue.increment(1));
                      
                      if (mounted) Navigator.pop(context);
                      _showSuccessAnimation();
                      
                    } catch (e) {
                      setState(() => isChecking = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database Error: $e'), backgroundColor: Colors.red));
                    }
                  }
                },
                child: isChecking 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2))
                  : const Text('SUBMIT & DOWNLOAD', style: TextStyle(color: Colors.cyanAccent)),
              )
            ],
          );
        }
      ),
    );
  }

  void _showAuthDialog(bool isLogin) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyanAccent, width: 1), borderRadius: BorderRadius.circular(12)),
        title: Text(isLogin ? 'Login to Portfolio' : 'Register New Account', style: const TextStyle(color: Colors.cyanAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 15),
            TextField(controller: passwordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withOpacity(0.1)),
            onPressed: () async {
              try {
                if (isLogin) {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
                } else {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
                }
                if (mounted) Navigator.pop(context);
              } catch (e) {
                print("Auth Error: $e");
              }
            },
            child: Text(isLogin ? 'LOGIN' : 'REGISTER', style: const TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: const Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.public, color: Colors.cyanAccent))),
        actions: [
          _currentUser != null
              ? _buildTopButton('LOGOUT', () async => await FirebaseAuth.instance.signOut())
              : Row(
                  children: [
                    _buildTopButton('LOGIN', () => _showAuthDialog(true)),
                    const SizedBox(width: 10),
                    _buildTopButton('REGISTER', () => _showAuthDialog(false)),
                  ],
                ),
          SizedBox(width: isMobile ? 10 : 40),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.transparent, 
            builder: (context) => const ChatWindow(),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF111111),
                border: Border.all(color: Colors.cyanAccent, width: 2.5),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)
                ],
                image: const DecorationImage(
                  image: NetworkImage('https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People%20with%20professions/Woman%20Technologist%20Medium-Light%20Skin%20Tone.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 5)],
                ),
                child: const Text(
                  "AI Assistant 👋",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          if (!isMobile)
            Positioned(left: 0, top: 0, bottom: 0, width: screenSize.width * 0.45, child: Container(decoration: BoxDecoration(borderRadius: const BorderRadius.only(topRight: Radius.circular(200), bottomRight: Radius.circular(200)), color: Colors.white.withOpacity(0.02)))),
          
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 60.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(isMobile),
                const SizedBox(height: 80),
                _buildSectionHeader('01.', 'Profile Summary', isMobile),
                _buildProfileSummaryCard(isMobile),
                const SizedBox(height: 60),
                _buildSectionHeader('02.', 'Professional Experience', isMobile),
                _buildExperienceCard(isMobile),
                const SizedBox(height: 60),
                _buildSectionHeader('03.', 'Technical Arsenal', isMobile),
                const SizedBox(height: 24),
                _buildTechnicalArsenal(context),
                const SizedBox(height: 60),
                _buildSectionHeader('04.', 'Project Highlights', isMobile),
                const SizedBox(height: 24),
                _buildProjectHighlights(),
                const SizedBox(height: 60),
                Center(child: Text('Tracked Bugs', style: TextStyle(color: Colors.cyanAccent, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.cyan, blurRadius: 10)]))),
                const SizedBox(height: 30),
                _buildTrackedBugs(),
                const SizedBox(height: 80),
                _buildContactCTA(isMobile),
                const SizedBox(height: 40), 
                _buildFooter(isMobile),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    Widget animationWidget = Container(
      height: isMobile ? 320 : 400,
      width: isMobile ? double.infinity : 400,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_1LhsaB.json', 
            fit: BoxFit.contain,
            width: isMobile ? 200 : 300,
          ),
          
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, child) {
              int totalElements = 5;
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildOrbitingElement(0, totalElements, 'Python', Icons.code, Colors.blue, isMobile),
                  _buildOrbitingElement(1, totalElements, 'Java', Icons.coffee, Colors.orange, isMobile),
                  _buildOrbitingElement(2, totalElements, 'Automation', Icons.smart_toy, Colors.greenAccent, isMobile),
                  _buildOrbitingElement(3, totalElements, 'Manual', Icons.fact_check, Colors.pinkAccent, isMobile),
                  _buildOrbitingElement(4, totalElements, 'Me', Icons.person, Colors.cyan, isMobile, isPhoto: true),
                ],
              );
            },
          ),
        ],
      ),
    );

    Widget textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        const Text('SOFTWARE ENGINEER', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text('[Sagar Kumar]',
            textAlign: isMobile ? TextAlign.center : TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 36 : 64, fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.purpleAccent, blurRadius: 15)])),
        const SizedBox(height: 20),
        SizedBox(
          height: isMobile ? 60 : 30,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20.0, color: Colors.greenAccent, fontFamily: 'Courier'),
            textAlign: isMobile ? TextAlign.center : TextAlign.right,
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TypewriterAnimatedText('Hunting bugs before they reach users.', speed: const Duration(milliseconds: 80)),
                TypewriterAnimatedText('Building scalable POM frameworks.', speed: const Duration(milliseconds: 80)),
                TypewriterAnimatedText('Executing robust API tests via Postman.', speed: const Duration(milliseconds: 80)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text('QA Automation Architect | Engineering Flawless Systems', textAlign: isMobile ? TextAlign.center : TextAlign.right, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 40),
        
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildNeonButton('EMAIL ME', _launchEmail),
            _buildNeonButton('PHONE NO.', () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent, 
                builder: (context) => const ChatWindow(initialMessage: "please share Sagar(sk) num"),
              );
            }),
            _buildNeonButton('RESUME ($_downloadCount)', _showDownloadDialog),
          ],
        )
      ],
    );

    if (isMobile) {
      return Column(children: [animationWidget, const SizedBox(height: 30), textWidget]);
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 1, child: animationWidget), Expanded(flex: 1, child: textWidget)]);
    }
  }

  Widget _buildOrbitingElement(int index, int totalElements, String label, IconData icon, Color color, bool isMobile, {bool isPhoto = false}) {
    double angle = (_orbitController.value * 2 * math.pi) + (index * (2 * math.pi / totalElements));
    double radius = isMobile ? 120 : 180;
    
    double x = math.cos(angle) * radius;
    double y = math.sin(angle) * radius + (math.sin(_orbitController.value * 4 * math.pi) * 10);

    return Transform.translate(
      offset: Offset(x, y),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isPhoto ? 2 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111111),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)],
              border: Border.all(color: color, width: 2),
            ),
            child: isPhoto 
                ? const CircleAvatar(
                    radius: 20, 
                    backgroundColor: Colors.transparent, 
                    backgroundImage: AssetImage('assets/sagar.jpg'), 
                  )
                : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(left: isMobile ? 0 : 40.0),
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(bool isMobile) {
    return Container(
      margin: EdgeInsets.only(top: 24, left: isMobile ? 0 : 40),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF0F1423).withOpacity(0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Text(
        'I am a detail-oriented Testing Engineer with over 3+ years of experience in both Manual and Automation testing, bridging the gap between rapid development and rock-solid reliability. From executing complex manual exploratory testing to building scalable automation POM frameworks in Playwright and Python, my focus is always on delivering flawless software.',
        style: TextStyle(color: Colors.grey, height: 1.8, fontSize: isMobile ? 14 : 16),
        textAlign: isMobile ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _buildExperienceCard(bool isMobile) {
    return Container(
      margin: EdgeInsets.only(top: 24, left: isMobile ? 0 : 40),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF0F1423).withOpacity(0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile 
            ? Column(children: const [
                Text('Software Testing Engineer', style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Onelap Telematics | March 2023 - Present', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ])
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Software Testing Engineer', style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Onelap Telematics Pvt. Ltd. | March 2023 - Present', style: TextStyle(color: Colors.greenAccent, fontSize: 14)),
                ],
              ),
          const Divider(color: Colors.white24, height: 30),
          _buildExperienceBullet('Engineered test plans for Web, CRM, and Mobile platforms.'),
          _buildExperienceBullet('Executed robust UI, regression, and API tests via Postman.'),
          _buildExperienceBullet('Initiated automation test scripts using Playwright.'),
          _buildExperienceBullet('Played a critical role in stabilizing GPS tracking logic.'),
        ],
      ),
    );
  }

  Widget _buildExperienceBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('> ', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[400], height: 1.5, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTechnicalArsenal(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: Row(
        children: [
          _buildCard(
            context,
            'Core Testing', 
            'Expertise in Manual Testing including Functional, Regression, UI, Integration, System, UAT.', 
            Icons.search,
            'https://assets9.lottiefiles.com/packages/lf20_1LhsaB.json', 
            [
              'End-to-End Manual Testing: Executing comprehensive exploratory and structural test workflows across web and mobile platforms.',
              'Functional & Regression Testing: Ensuring new features seamlessly integrate without breaking existing functionalities.',
              'User Acceptance Testing (UAT): Validating system readiness against strict business requirements.',
            ]
          ), 
          _buildCard(
            context,
            'Automation & Python', 
            'Automation expertise using Playwright, Python for API/UI Testing, Pytest-BDD, and POM.', 
            Icons.settings_applications,
            'https://assets8.lottiefiles.com/packages/lf20_cwqf5i.json', 
            [
              'Python Automation Frameworks: Architecting highly scalable web automation frameworks utilizing Python and Playwright.',
              'BDD Implementation: Structuring feature files and step definitions utilizing Pytest-BDD for clear, business-readable tests.',
              'Advanced Page Object Model (POM): Designing tailored POM structures, specifically handling complex canvas-rendered environments like Flutter Web.'
            ]
          ), 
          _buildCard(
            context,
            'API & Backend Testing', 
            'Advanced REST API validation, payload verification, and automated API scripts.', 
            Icons.api,
            'https://assets3.lottiefiles.com/packages/lf20_gzoqyyqf.json', 
            [
              'REST API Validation: Extensive manual and automated testing of endpoints, parameters, and headers.',
              'Payload & Status Verification: Ensuring accurate JSON/XML responses and handling of edge-case status codes.',
              'Postman Mastery: Creating complex Postman collections with pre-request scripts and test assertions.',
              'Python API Scripts: Developing custom Python scripts to automatically fetch API analytics data and distribute daily sales metrics reports.'
            ]
          ),
          _buildCard(
            context,
            'Flutter Development', 
            'Building responsive, high-performance apps for Web, iOS, and Android using Dart.', 
            Icons.app_shortcut,
            'https://assets2.lottiefiles.com/packages/lf20_tv6tgxcc.json',
            [
              'Cross-Platform Development: Engineering responsive, high-performance applications for Web, Android, and iOS from a single Dart codebase.',
              'UI/UX & Animations: Designing pixel-perfect user interfaces with dynamic Lottie animations, custom widgets, and fluid transitions.',
              'State Management & Backend: Efficiently managing app state and seamlessly integrating Firebase (Authentication, Realtime Database) and REST APIs.',
              'Web Optimization: Adapting complex mobile layouts into fully responsive, interactive web experiences (just like this portfolio!).'
            ]
          ),
          _buildCard(
            context,
            'Framework & CI/CD', 
            'Experience with BDD Frameworks, Jenkins CI/CD Pipelines, and automated Python reporting.', 
            Icons.build,
            'https://assets5.lottiefiles.com/packages/lf20_bXrtVJ.json', 
            [
              'Continuous Integration Setup: Managing automated execution tasks, triggers, and scheduled test runs within Jenkins dashboards.',
              'Scheduled Cron Jobs: Establishing automated execution tasks scheduled to repeat regularly on a weekly timeline.',
              'Agile/Scrum Methodology: Active participation in sprint planning, bug triaging, and retrospective meetings.'
            ]
          ), 
          _buildCard(
            context,
            'Tools & Platforms', 
            'Experienced with SQL, JIRA, Trello, Grafana, Xcode, Google Play Console, Postman.', 
            Icons.handyman,
            'https://assets1.lottiefiles.com/packages/lf20_jbrw3hcz.json', 
            [
              'Test Management & Tracking: JIRA and Trello for agile issue tracking and test case management.',
              'Database Validation: SQL for backend data verification and integrity checks.',
              'Platform Management: Navigating Grafana for metrics, Xcode for iOS builds, and Google Play Console for Android releases.'
            ]
          )
        ]
      )
    );
  }

  Widget _buildCard(BuildContext context, String title, String desc, IconData icon, String lottieUrl, List<String> details) {
    return Container(
      width: 260, height: 280, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0F1423).withOpacity(0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(icon, size: 36, color: Colors.cyanAccent)),
          const SizedBox(height: 15),
          Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Expanded(child: Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], height: 1.4, fontSize: 12))),
          
          Center(
            child: _buildOutlinedButton('VIEW DETAILS', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkillDetailScreen(
                    title: title,
                    icon: icon,
                    lottieUrl: lottieUrl, 
                    details: details,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHighlights() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center, 
        spacing: 20, 
        runSpacing: 20, 
        children: [
          _buildProjectCard(
            'E-Commerce Platform', 
            'Performed manual and Playwright automation to validate UI elements and workflows.', 
            Icons.shopping_cart,
            'https://www.onelap.in/'
          ), 
          _buildProjectCard(
            'GPS Tracking App', 
            'Verified live location, route accuracy, and dashcam playback on Android & iOS.', 
            Icons.map,
            'https://play.google.com/store/apps/details?id=in.onelap.gpstracker&hl=en_IN'
          ), 
          _buildProjectCard(
            'Web Tracking Dash', 
            'Tested main web tracking CRM dashboard, verifying vehicle monitoring features.', 
            Icons.dashboard,
            'https://web.onelap.in/'
          ),
          _buildProjectCard(
            'Support CRM System', 
            'Internal CRM portal tailored for sales and support teams to efficiently manage customer interactions.', 
            Icons.support_agent,
            'https://www.onelap.in/' 
          )
        ]
      ),
    );
  }

  Widget _buildProjectCard(String title, String desc, IconData icon, String url) {
    return Container(
      width: 260, 
      height: 280, 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1423).withOpacity(0.8), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.white12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(icon, size: 36, color: Colors.white70)),
          const SizedBox(height: 15),
          Center(
            child: Text(
              title, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)
            )
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              desc, 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.grey[400], height: 1.4, fontSize: 12)
            )
          ),
          Center(
            child: _buildOutlinedButton('VIEW PROJECT', () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                debugPrint('Could not launch $url');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackedBugs() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_buildBugCard('BUG-001', 'Cursor missing on Auth Modal', 'Custom mouse cursor goes behind modal blur overlay.', 'High', true), _buildBugCard('BUG-002', 'Mobile Menu Glitch', 'Navigation menu overlaps with hero section on smaller screens.', 'Medium', false), _buildBugCard('BUG-003', 'Duplicate Email Download', 'System allows multiple resume downloads with same email.', 'Low', true)]));
  }

 Widget _buildContactCTA(bool isMobile) {
    Widget contactInfo = Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1423).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need a Platform\nBuilt or Tested?', style: TextStyle(color: Colors.cyanAccent, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 20),
          Text('Whether you need comprehensive Web/App Testing or want a custom Website/App developed from scratch, I am here to help you achieve flawless results.', style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.6)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.withOpacity(0.1),
              side: const BorderSide(color: Colors.cyanAccent),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: _launchEmail,
            icon: const Icon(Icons.email, color: Colors.cyanAccent),
            label: const Text("EMAIL ME DIRECTLY", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );

    Widget contactForm = Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.pinkAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Drop a Message 🚀', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          
          _buildStylishTextField('Your Name', Icons.person, _contactNameCtrl),
          const SizedBox(height: 15),
          _buildStylishTextField('Your Email', Icons.email, _contactEmailCtrl),
          const SizedBox(height: 15),
          _buildStylishTextField('How can I help you?', Icons.message, _contactMsgCtrl, maxLines: 4),
          
          const SizedBox(height: 25),
          
          SizedBox(
            width: double.infinity,
            height: 55, 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 10,
                shadowColor: Colors.pinkAccent.withOpacity(0.5),
              ),
              onPressed: _isSendingMessage ? null : () async {
                if (_contactNameCtrl.text.isEmpty || _contactEmailCtrl.text.isEmpty || _contactMsgCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all the fields.'), backgroundColor: Colors.redAccent)
                  );
                  return;
                }

                setState(() => _isSendingMessage = true);

                try {
                  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'service_id': 'service_y64js2r', 
                      'template_id': 'template_fjzrtba', 
                      'user_id': '5pLP9u1jZ7zWZG3zC', 
                      'template_params': {
                        'from_name': _contactNameCtrl.text,
                        'from_email': _contactEmailCtrl.text,
                        'message': _contactMsgCtrl.text,
                      }
                    }),
                  );

                  if (response.statusCode == 200) {
                    _contactNameCtrl.clear();
                    _contactEmailCtrl.clear();
                    _contactMsgCtrl.clear();
                    _showMessageSuccessDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${response.body}'), backgroundColor: Colors.redAccent)
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Network error. Please check your connection.'), backgroundColor: Colors.redAccent)
                  );
                } finally {
                  setState(() => _isSendingMessage = false);
                }
              },
              child: _isSendingMessage 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text("SEND MESSAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 60),
      child: isMobile 
        ? Column(children: [contactInfo, const SizedBox(height: 30), contactForm])
        : IntrinsicHeight( 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: contactInfo),
                const SizedBox(width: 40),
                Expanded(flex: 1, child: contactForm),
              ],
            ),
          ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1423).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Designed & Engineered by Sagar Kumar',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flutter_dash, color: Colors.cyanAccent, size: 18),
              const SizedBox(width: 8),
              Text('Built with Flutter & Firebase', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // REAL LINKEDIN AND GITHUB ICONS
              _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', 'https://www.linkedin.com/in/sagarautomation/'), 
              const SizedBox(width: 20),
              _buildSocialIcon(FontAwesomeIcons.github, 'GitHub', 'https://github.com/sagarkumar456'), 
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String tooltip, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF111111),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
            ]
          ),
          child: Icon(icon, color: Colors.cyanAccent, size: 24),
        ),
      ),
    );
  }

  Widget _buildStylishTextField(String hint, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.cyanAccent.withOpacity(0.7)) : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF070B19),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }

  Widget _buildBugCard(String bugId, String title, String desc, String severity, bool isFixed) {
    return Container(
      width: 280, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0F1423).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: isFixed ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bugId, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: isFixed ? Colors.greenAccent : Colors.redAccent), borderRadius: BorderRadius.circular(20)), child: Text(isFixed ? 'FIXED' : 'OPEN', style: TextStyle(color: isFixed ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc, style: TextStyle(color: Colors.grey[400], height: 1.4, fontSize: 12)),
          const SizedBox(height: 20),
          Text('Severity: $severity', style: TextStyle(color: severity == 'High' ? Colors.redAccent : Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNeonButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyanAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), backgroundColor: Colors.cyanAccent.withOpacity(0.05)),
      onPressed: onPressed, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyanAccent, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      onPressed: onPressed, child: Text(text, style: const TextStyle(color: Colors.cyanAccent, letterSpacing: 1.2, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTopButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      onPressed: onPressed, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class ChatWindow extends StatefulWidget {
  final String initialMessage;
  const ChatWindow({Key? key, this.initialMessage = ''}) : super(key: key);

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  late TextEditingController _controller;
  final List<Map<String, String>> _messages = [
    {"role": "ai", "text": "Hello! I am Elara, the AI assistant. How can I help you today?"}
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true; 
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://sagar-portfolio-website-kappa.vercel.app/api/chat'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "ai", "text": data['reply']});
        });
      } else {
        setState(() {
          _messages.add({"role": "ai", "text": "Server Error: ${response.statusCode}"});
        });
      }
    } catch (e) {
      print("CHAT API ERROR: $e");
      setState(() {
        _messages.add({"role": "ai", "text": "Network Error. Please try again."});
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        // Yahan AnimatedPadding add kiya hai jo keyboard aane par bottom se space dega
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 80, left: 20), // Mobile ke liye left margin bhi zaroori hai
            // Fixed height aur width ki jagah BoxConstraints use kiya hai taaki responsive rahe
            constraints: BoxConstraints(
              maxWidth: 350,
              maxHeight: MediaQuery.of(context).size.height * 0.65, // Screen height ka 65% se zyada bada nahi hoga
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1423),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyanAccent, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Elara AI Assistant', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      
                      if (index == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Elara is typing...", 
                              style: TextStyle(
                                color: Colors.cyanAccent, 
                                fontStyle: FontStyle.italic, 
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.cyanAccent.withOpacity(0.15) : Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isUser ? Colors.cyanAccent.withOpacity(0.5) : Colors.transparent),
                          ),
                          child: Text(msg['text']!, style: TextStyle(color: isUser ? Colors.cyanAccent : Colors.white, fontSize: 14)),
                        ),
                      );
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.black,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white24)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.cyanAccent)),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _sendMessage(_controller.text),
                        child: const CircleAvatar(backgroundColor: Colors.cyanAccent, child: Icon(Icons.send, color: Colors.black, size: 18)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
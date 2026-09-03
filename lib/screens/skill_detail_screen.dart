import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SkillDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String lottieUrl; // 3D Animation ke liye naya variable
  final List<String> details;

  const SkillDetailScreen({
    Key? key,
    required this.title,
    required this.icon,
    required this.lottieUrl,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with 3D Animation and Title
              isMobile 
                ? Column(
                    children: [
                      _build3DAnimation(),
                      const SizedBox(height: 20),
                      _buildTitle(),
                    ],
                  )
                : Row(
                    children: [
                      _build3DAnimation(),
                      const SizedBox(width: 40),
                      Expanded(child: _buildTitle()),
                    ],
                  ),
              
              const SizedBox(height: 50),
              const Text('Detailed Expertise', style: TextStyle(color: Colors.pinkAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 20),
              
              // Bullet Points List
              Expanded(
                child: ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('▹ ', style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              details[index],
                              style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3D Animation Widget Helper
  Widget _build3DAnimation() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
        ],
      ),
      child: ClipOval(
        child: Lottie.network(
          lottieUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(icon, size: 80, color: Colors.cyanAccent), // Agar link break ho toh icon dikhega
        ),
      ),
    );
  }

  // Title Widget Helper
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2),
    );
  }
}
import 'package:flutter/material.dart';
import 'main.dart';

// Displays the user manual, troubleshooting steps, and system status
// legend to assist users in operating the SeeForMe application.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Builds a formatted row for the system status legend.
  Widget statusBullet(Color color, String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: color),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appThemeNotifier,
      builder: (context, themeName, child) {
        Color boxColor = const Color(0xFF1E1E1E);
        Color accentColor = Theme.of(context).primaryColor;
        Color textColor = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

        if (themeName == 'OLED Comfort') {
          boxColor = const Color(0xFF121212);
        } else if (themeName == 'Low Glare') {
          boxColor = const Color(0xFF112240);
        }

        // Builds an individual instruction with an icon and description.
        Widget instructionCard({required IconData icon, required String title, required String description}) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 44, color: accentColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(fontSize: 17, color: textColor, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Help & Tutorial'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Welcome to SeeForMe!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'This app uses AI to describe the world in real-time. Here is how to get started:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8)),
                ),
              ),

              instructionCard(
                icon: Icons.lan,
                title: '0. Server Connection',
                description: 'Enter your Python server IP in Settings.',
              ),

              instructionCard(
                icon: Icons.camera_alt,
                title: '1. Start Scanning',
                description: 'Tap "START LIVE DESCRIPTION" on the Home Screen. Hold the phone steady at chest height.',
              ),

              instructionCard(
                icon: Icons.speed,
                title: '2. Adjust Speech Rate',
                description: 'Change how fast the AI speaks in Settings. Choose Slow, Normal, or Fast, or use a Custom value.',
              ),

              instructionCard(
                icon: Icons.psychology,
                title: '3. Detail Levels',
                description: 'Choose "Minimal" for brief labels or "Detailed" for complete scene descriptions.',
              ),

              instructionCard(
                icon: Icons.translate,
                title: '4. Change Languages',
                description: 'Select your preferred language in Settings to hear descriptions in English, Türkçe, German and more.',
              ),

              instructionCard(
                icon: Icons.vibration,
                title: '5. Haptic Feedback',
                description: 'Enable "Haptic Feedback" to feel a gentle vibration pulse during every AI announcement.',
              ),

              instructionCard(
                icon: Icons.auto_awesome,
                title: '6. Auto-Flashlight',
                description: 'The AI will automatically turn on your flash in dark rooms. This can be toggled in Settings.',
              ),

              const SizedBox(height: 20),

              Text(
                'System Status Guide',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor),
              ),
              const SizedBox(height: 10),
              statusBullet(textColor, 'Connected', 'The server is connected and processing frames.'),
              statusBullet(textColor, 'Offline', 'Disconnected. Verify your Wi-Fi and Server IP settings.'),
              statusBullet(textColor, 'AI Struggling', 'Processing is slow. Stay still to help the AI focus.'),

              const SizedBox(height: 20),

              Divider(color: accentColor, thickness: 2),
              const SizedBox(height: 20),
              Text(
                'Troubleshooting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accentColor),
              ),
              const SizedBox(height: 10),
              Text(
                '• No camera? Grant camera permissions in phone settings.\n'
                    '• No sound? Check media volume and ensure Silent Mode is off.\n',
                style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
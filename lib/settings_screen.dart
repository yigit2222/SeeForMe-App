import 'package:flutter/material.dart';
import 'network_manager.dart';
import 'main.dart'; // Gives access to the global 'prefs' variable

// Provides a user interface for configuring application preferences,
// including visual themes, accessibility options, and network settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Supported languages for text-to-speech and AI processing.
  final Map<String, String> _languages = {
    'en': 'English', 'tr': 'Türkçe', 'de': 'German', 'es': 'Spanish',
    'fr': 'French', 'ar': 'Arabic', 'ru': 'Russian', 'ja': 'Japanese'
  };



  // UI COMPONENT BUILDERS

  // Builds a standardized row containing a title, subtitle, and toggle switch.
  Widget accessibleSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                ]
              ],
            ),
          ),
          Transform.scale(
            scale: 1.3,
            child: Switch(
              value: value,
              activeColor: Colors.black,
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade800,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // Builds a row of selectable options used for discrete configuration choices.
  Widget choiceRow({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required Color textColor,
    required Color accentColor
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((option) {
            bool isSelected = currentValue == option;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => onChanged(option),
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? accentColor : Colors.transparent),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Encapsulates a group of settings within a themed container.
  Widget sectionBox({
    required String title,
    required List<Widget> children,
    required Color boxColor,
    required Color accentColor
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: accentColor)),
          Divider(color: accentColor, thickness: 2, height: 24),
          ...children,
        ],
      ),
    );
  }


  // DIALOG MANAGERS

  // Displays the application's data privacy commitments.
  void _showPrivacyDialog(BuildContext context, Color boxColor, Color accentColor, Color textColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: boxColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accentColor, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.privacy_tip, color: accentColor, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Text('Privacy Policy', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(
            'SeeForMe is committed to your privacy.\n\nThis application processes camera feeds and audio strictly in real time. We DO NOT COLLECT, store, sell, or share any personal data, video recordings, audio logs, or location information.',
            style: TextStyle(color: textColor, fontSize: 18, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('UNDERSTOOD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  // Displays a dialog allowing the user to update the backend server IP address.
  void _showIpEditDialog(BuildContext context, Color boxColor, Color accentColor, Color textColor) {
    TextEditingController ipController = TextEditingController(text: serverIpAddressNotifier.value);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: boxColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accentColor, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi, color: accentColor, size: 32),
              const SizedBox(width: 12),
              Expanded(child: Text('Set Server IP', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold))),
            ],
          ),
          content: TextField(
            controller: ipController,
            style: TextStyle(color: textColor, fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '192.168.1.X',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor.withOpacity(0.5))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                String newIp = ipController.text.trim();
                if (newIp.isNotEmpty) {
                  serverIpAddressNotifier.value = newIp;
                  globalNetworkManager.updateServerIp(newIp);
                  prefs.setString('serverIpAddress', newIp);
                }
                Navigator.of(context).pop();
              },
              child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


  // MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appThemeNotifier,
      builder: (context, themeName, child) {

        Color bgColor = Theme.of(context).scaffoldBackgroundColor;
        Color accentColor = Theme.of(context).primaryColor;
        Color boxColor = const Color(0xFF1E1E1E);
        Color textColor = Colors.white;

        if (themeName == 'OLED Comfort') {
          boxColor = const Color(0xFF121212);
          textColor = const Color(0xFFF5F5F5);
        } else if (themeName == 'Low Glare') {
          boxColor = const Color(0xFF112240);
          textColor = const Color(0xFFFFFDE7);
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            title: Text('Settings', style: TextStyle(color: textColor)),
            iconTheme: IconThemeData(color: accentColor),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              sectionBox(
                title: 'Visual Theme',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  choiceRow(
                    title: 'Color Palette:',
                    options: ['High Contrast', 'OLED Comfort', 'Low Glare'],
                    currentValue: themeName,
                    textColor: textColor,
                    accentColor: accentColor,
                    onChanged: (v) {
                      appThemeNotifier.value = v;
                      prefs.setString('appTheme', v);
                    },
                  ),
                ],
              ),

              sectionBox(
                title: 'Audio & Language',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: currentLanguageNotifier,
                    builder: (context, langCode, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: langCode,
                            isExpanded: true,
                            icon: Icon(Icons.language, color: accentColor, size: 30),
                            dropdownColor: boxColor,
                            style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
                            items: _languages.entries.map((entry) {
                              return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                            }).toList(),
                            onChanged: (String? newCode) {
                              if (newCode != null) {
                                currentLanguageNotifier.value = newCode;
                                globalNetworkManager.sendCommand("LANG:$newCode");
                                prefs.setString('currentLanguage', newCode);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  ValueListenableBuilder<double>(
                    valueListenable: audioVolumeNotifier,
                    builder: (context, vol, child) {
                      return Row(
                        children: [
                          Icon(Icons.volume_up, color: textColor, size: 32),
                          Expanded(
                            child: Slider(
                              value: vol,
                              min: 0.0,
                              max: 1.0,
                              activeColor: accentColor,
                              inactiveColor: Colors.grey.shade700,
                              onChanged: (v) {
                                audioVolumeNotifier.value = v;
                                globalNetworkManager.setVolume(v);
                                prefs.setDouble('audioVolume', v);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  ValueListenableBuilder<String>(
                    valueListenable: speechRateModeNotifier,
                    builder: (context, mode, child) {
                      Widget buildButton(String title) {
                        bool isSelected = mode == title;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () {
                                speechRateModeNotifier.value = title;
                                prefs.setString('speechRateMode', title);

                                if (title == 'Slow') {
                                  globalNetworkManager.sendCommand("RATE:0.75");
                                  globalNetworkManager.setAudioSpeed(0.75);
                                } else if (title == 'Normal') {
                                  globalNetworkManager.sendCommand("RATE:1.0");
                                  globalNetworkManager.setAudioSpeed(1.0);
                                } else if (title == 'Fast') {
                                  globalNetworkManager.sendCommand("RATE:1.5");
                                  globalNetworkManager.setAudioSpeed(1.5);
                                } else if (title == 'Custom') {
                                  globalNetworkManager.sendCommand("RATE:${customSpeechRateNotifier.value}");
                                  globalNetworkManager.setAudioSpeed(customSpeechRateNotifier.value);
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected ? accentColor : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSelected ? accentColor : Colors.transparent),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Speech Rate:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButton('Slow'),
                              buildButton('Normal'),
                              buildButton('Fast'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              buildButton('Custom'),
                            ],
                          ),
                          if (mode == 'Custom') ...[
                            const SizedBox(height: 16),
                            ValueListenableBuilder<double>(
                              valueListenable: customSpeechRateNotifier,
                              builder: (context, customRate, child) {
                                return Row(
                                  children: [
                                    Text('${customRate.toStringAsFixed(1)}x',
                                        style: TextStyle(fontSize: 18, color: accentColor, fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Slider(
                                        value: customRate,
                                        min: 0.5,
                                        max: 2.5,
                                        divisions: 20,
                                        activeColor: accentColor,
                                        inactiveColor: Colors.grey.shade700,
                                        onChanged: (v) {
                                          customSpeechRateNotifier.value = v;
                                          globalNetworkManager.sendCommand("RATE:$v");
                                          globalNetworkManager.setAudioSpeed(v);
                                          prefs.setDouble('customSpeechRate', v);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),

              sectionBox(
                title: 'Description Detail',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: descriptionDetailNotifier,
                    builder: (context, detail, child) {
                      return choiceRow(
                        title: 'AI Detail Level:',
                        options: ['Minimal', 'Standard', 'Detailed'],
                        currentValue: detail,
                        textColor: textColor,
                        accentColor: accentColor,
                        onChanged: (v) {
                          descriptionDetailNotifier.value = v;
                          globalNetworkManager.sendCommand("DETAIL:$v");
                          prefs.setString('descriptionDetail', v);
                        },
                      );
                    },
                  ),
                ],
              ),

              sectionBox(
                title: 'Connection',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: serverIpAddressNotifier,
                    builder: (context, ipAddress, child) {
                      return InkWell(
                        onTap: () => _showIpEditDialog(context, boxColor, accentColor, textColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.router, color: accentColor, size: 36),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Server IP Address', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 4),
                                    Text(ipAddress, style: TextStyle(fontSize: 18, color: Colors.grey.shade400)),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit, color: accentColor, size: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              sectionBox(
                title: 'Accessibility',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: globalNetworkManager.isTtsEnabled,
                    builder: (context, isTts, child) {
                      return accessibleSwitch(
                        title: 'Voice Guidance (TTS)',
                        subtitle: 'Announce system status out loud.',
                        value: isTts,
                        textColor: textColor,
                        onChanged: (bool newValue) {
                          globalNetworkManager.isTtsEnabled.value = newValue;
                          prefs.setBool('isTtsEnabled', newValue);

                          if (newValue) {
                            globalNetworkManager.tts.speak("Voice guidance enabled");
                          } else {
                            globalNetworkManager.tts.stop();
                            globalNetworkManager.tts.speak("Voice guidance disabled");
                          }
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isVibrationEnabledNotifier,
                    builder: (context, isVib, child) {
                      return accessibleSwitch(
                        title: 'Haptic Feedback',
                        subtitle: 'Vibrate on new description.',
                        value: isVib,
                        textColor: textColor,
                        onChanged: (v) {
                          isVibrationEnabledNotifier.value = v;
                          prefs.setBool('isVibrationEnabled', v);

                          globalNetworkManager.announce(v ? "Haptic feedback enabled" : "Haptic feedback disabled");
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isBoundingBoxEnabledNotifier,
                    builder: (context, isBox, child) {
                      return accessibleSwitch(
                        title: 'Visual Boxes',
                        subtitle: 'Draw boxes around objects.',
                        value: isBox,
                        textColor: textColor,
                        onChanged: (v) {
                          isBoundingBoxEnabledNotifier.value = v;
                          prefs.setBool('isBoundingBoxEnabled', v);

                          globalNetworkManager.announce(v ? "Visual boxes enabled" : "Visual boxes disabled");
                        },
                      );
                    },
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: isAutoTorchEnabledNotifier,
                    builder: (context, isAuto, child) {
                      return accessibleSwitch(
                        title: 'Auto-Flashlight',
                        subtitle: 'Turn on light automatically in dark rooms.',
                        value: isAuto,
                        textColor: textColor,
                        onChanged: (v) {
                          isAutoTorchEnabledNotifier.value = v;
                          prefs.setBool('isAutoTorchEnabled', v);

                          globalNetworkManager.announce(v ? "Auto flashlight enabled" : "Auto flashlight disabled");
                        },
                      );
                    },
                  ),
                ],
              ),

              sectionBox(
                title: 'About & Privacy',
                boxColor: boxColor,
                accentColor: accentColor,
                children: [
                  InkWell(
                    onTap: () {
                      _showPrivacyDialog(context, boxColor, accentColor, textColor);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.security, color: accentColor, size: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data Privacy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                                const SizedBox(height: 4),
                                Text('Tap to view our privacy commitment.', style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: accentColor, size: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitirme_projesi_2/network_manager.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

// Global variable to hold the list of available cameras on the device.
late List<CameraDescription> cameras;

// Global State Management (Notifiers)
final NetworkManager globalNetworkManager = NetworkManager();
late SharedPreferences prefs;

// 🔴 Transient Live Data (Does not need saving)
final ValueNotifier<List<String>> detectionBoxesNotifier = ValueNotifier<List<String>>([]);

// 🟢 Persistent User Settings
late final ValueNotifier<bool> isVibrationEnabledNotifier = ValueNotifier<bool>(prefs.getBool('isVibrationEnabled') ?? true);
late final ValueNotifier<bool> isBoundingBoxEnabledNotifier = ValueNotifier<bool>(prefs.getBool('isBoundingBoxEnabled') ?? true);
late final ValueNotifier<double> audioVolumeNotifier = ValueNotifier<double>(prefs.getDouble('audioVolume') ?? 1.0);
late final ValueNotifier<String> speechRateNotifier = ValueNotifier<String>(prefs.getString('speechRate') ?? 'Normal');
late final ValueNotifier<String> descriptionDetailNotifier = ValueNotifier<String>(prefs.getString('descriptionDetail') ?? 'Standard');
late final ValueNotifier<String> currentLanguageNotifier = ValueNotifier<String>(prefs.getString('currentLanguage') ?? 'en');
late final ValueNotifier<String> speechRateModeNotifier = ValueNotifier<String>(prefs.getString('speechRateMode') ?? 'Normal');
late final ValueNotifier<double> customSpeechRateNotifier = ValueNotifier<double>(prefs.getDouble('customSpeechRate') ?? 1.0);
late final ValueNotifier<String> appThemeNotifier = ValueNotifier<String>(prefs.getString('appTheme') ?? 'High Contrast');
late final ValueNotifier<bool> isAutoTorchEnabledNotifier = ValueNotifier<bool>(prefs.getBool('isAutoTorchEnabled') ?? true);
late final ValueNotifier<String> serverIpAddressNotifier = ValueNotifier<String>(prefs.getString('serverIpAddress') ?? '192.168.1.100');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  prefs = await SharedPreferences.getInstance();

  await globalNetworkManager.init('192.168.1.100', 5005);

  runApp(const SeeForMe());
}

// Root Application Widget handling dynamic theme initialization.
class SeeForMe extends StatelessWidget {
  const SeeForMe({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appThemeNotifier,
      builder: (context, themeName, child) {
        ThemeData activeTheme;

        if (themeName == 'OLED Comfort') {
          activeTheme = ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            primaryColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Color(0xFFF5F5F5),
              centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF5F5F5)),
              iconTheme: IconThemeData(color: Colors.white, size: 36),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 80),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        } else if (themeName == 'Low Glare') {
          activeTheme = ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A192F),
            primaryColor: const Color(0xFFFFD700),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A192F),
              foregroundColor: Color(0xFFFFFDE7),
              centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFFDE7)),
              iconTheme: IconThemeData(color: Color(0xFFFFD700), size: 36),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0A192F),
                minimumSize: const Size(double.infinity, 80),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        } else {
          activeTheme = ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            primaryColor: Colors.yellowAccent,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.yellowAccent,
              centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
              iconTheme: IconThemeData(color: Colors.yellowAccent, size: 36),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 80),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SeeForMe',
          theme: activeTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}

// Primary Navigation Menu
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).primaryColor;
    Color secondaryButtonBg = const Color(0xFF1E1E1E);

    if (appThemeNotifier.value == 'Low Glare') {
      secondaryButtonBg = const Color(0xFF112240);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SeeForMe')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility, size: 140, color: accentColor),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveScreen()),
                );
              },
              child: const Text('START LIVE DESCRIPTION', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryButtonBg,
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: const Text('SETTINGS'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryButtonBg,
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
              child: const Text('HELP & TUTORIAL'),
            ),
          ],
        ),
      ),
    );
  }
}

// Core interface for real-time camera streaming and AI processing feedback.
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  CameraController? _cameraController;
  bool isRunning = false;
  bool isCameraInitialized = false;
  String detectedText = 'System Ready.';

  final ValueNotifier<bool> isTorchNotifier = ValueNotifier<bool>(false);
  bool isManualTorchOverride = false;

  DateTime _lastProcessTime = DateTime.now();
  bool _isProcessingFrame = false;


  // --- LIFECYCLE METHODS ---
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }


  // --- SESSION MANAGEMENT ---
  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _cameraController = CameraController(
        cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back, orElse: () => cameras.first),
        ResolutionPreset.medium,
        enableAudio: false,
      );

      try {
        await _cameraController!.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      } catch (e) {
        setState(() {
          detectedText = 'Camera Error: $e';
        });
      }
    } else {
      setState(() {
        detectedText = 'Camera Permission Denied.';
      });
    }
  }

  void startSession() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    globalNetworkManager.startHeartbeat();

    setState(() {
      isRunning = true;
      detectedText = 'Session active. Sending 1 FPS...';
    });

    _cameraController!.startImageStream((CameraImage image) {
      if (!isRunning) return;

      final Uint8List lumaBytes = image.planes[0].bytes;
      double totalLuma = 0;
      for (int i = 0; i < lumaBytes.length; i += 100) {
        totalLuma += lumaBytes[i];
      }
      double avgLuma = totalLuma / (lumaBytes.length / 100);

      // Evaluate automated environment lighting requirements
      if (!isManualTorchOverride && isAutoTorchEnabledNotifier.value) {
        if (avgLuma < 40 && !isTorchNotifier.value) {
          _cameraController!.setFlashMode(FlashMode.torch);
          isTorchNotifier.value = true;
        } else if (avgLuma > 180 && isTorchNotifier.value) {
          _cameraController!.setFlashMode(FlashMode.off);
          isTorchNotifier.value = false;
        }
      }

      // Enforce 1 FPS transmission limit
      if (_isProcessingFrame) return;
      final currentTime = DateTime.now();
      if (currentTime.difference(_lastProcessTime).inMilliseconds < 1000) return;

      _isProcessingFrame = true;
      _lastProcessTime = currentTime;

      try {
        Uint8List? compressedFrame = _compressCameraImage(image);
        if (compressedFrame != null) {
          globalNetworkManager.sendFrame(compressedFrame);
        }
      } catch (e) {
        debugPrint("Error during compression: $e");
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  void stopSession() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    globalNetworkManager.stopHeartbeat();
    setState(() {
      isRunning = false;
      isTorchNotifier.value = false;
      detectedText = 'Session stopped.';
    });
  }


  // --- HARDWARE UTILITIES ---
  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      if (isTorchNotifier.value) {
        await _cameraController!.setFlashMode(FlashMode.off);
        isTorchNotifier.value = false;
        isManualTorchOverride = false;
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        isTorchNotifier.value = true;
        isManualTorchOverride = true;
      }
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }


  // --- IMAGE PROCESSING LOGIC ---
  Uint8List? _compressCameraImage(CameraImage image) {
    try {
      img.Image? imgObj;
      if (image.format.group == ImageFormatGroup.bgra8888) {
        imgObj = img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
          order: img.ChannelOrder.bgra,
        );
      } else if (image.format.group == ImageFormatGroup.yuv420) {
        imgObj = _convertYUV420ToColor(image);
      } else {
        return null;
      }

      if (imgObj != null) {
        return Uint8List.fromList(img.encodeJpg(imgObj, quality: 60));
      }
    } catch (e) {
      debugPrint("Compression Error: $e");
    }
    return null;
  }

  img.Image _convertYUV420ToColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    var imgObj = img.Image(width: width, height: height);
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      int uvRow = y >> 1;
      for (int x = 0; x < width; x++) {
        int uvCol = x >> 1;
        int index = uvRow * uvRowStride + uvCol * uvPixelStride;
        final yp = image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
        final up = image.planes[1].bytes[index];
        final vp = image.planes[2].bytes[index];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        imgObj.setPixelRgb(x, y, r, g, b);
      }
    }
    return imgObj;
  }


  // --- USER INTERFACE ---
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: appThemeNotifier,
        builder: (context, themeName, child) {
          Color boxColor = const Color(0xFF1E1E1E);
          Color accentColor = Theme.of(context).primaryColor;
          if (themeName == 'OLED Comfort') boxColor = const Color(0xFF121212);
          if (themeName == 'Low Glare') boxColor = const Color(0xFF112240);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Live Session'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, size: 32),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor, width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (isCameraInitialized) CameraPreview(_cameraController!),

                            ValueListenableBuilder<bool>(
                              valueListenable: isBoundingBoxEnabledNotifier,
                              builder: (context, showBoxes, child) {
                                if (!showBoxes) return const SizedBox.shrink();
                                return ValueListenableBuilder<List<String>>(
                                  valueListenable: detectionBoxesNotifier,
                                  builder: (context, boxes, child) {
                                    return CustomPaint(painter: BoundingBoxPainter(boxes, accentColor));
                                  },
                                );
                              },
                            ),

                            Positioned(
                              top: 10,
                              right: 10,
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: globalNetworkManager.isServerConnected,
                                  builder: (context, isConnected, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isConnected ? Colors.greenAccent : Colors.redAccent, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(isConnected ? Icons.wifi : Icons.wifi_off, color: isConnected ? Colors.greenAccent : Colors.redAccent, size: 20),
                                          const SizedBox(width: 8),
                                          Text(isConnected ? 'Connected' : 'Offline', style: TextStyle(color: isConnected ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    );
                                  }
                              ),
                            ),

                            Positioned(
                              top: 10,
                              left: 10,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: isTorchNotifier,
                                builder: (context, isFlashOn, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: accentColor, width: 2),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                                        color: isFlashOn ? accentColor : Colors.grey,
                                        size: 30,
                                      ),
                                      onPressed: _toggleTorch,
                                      tooltip: 'Toggle Flashlight',
                                    ),
                                  );
                                },
                              ),
                            ),

                            ValueListenableBuilder<String>(
                                valueListenable: globalNetworkManager.systemStatus,
                                builder: (context, status, child) {
                                  if (status != "AI Struggling") return const SizedBox.shrink();
                                  return Positioned(
                                    bottom: 140,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                                          SizedBox(width: 10),
                                          Expanded(child: Text("AI is taking longer than usual. Please stay still.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),

                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: Colors.black.withOpacity(0.7),
                                child: Text(detectedText, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.redAccent : Colors.greenAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 120),
                      textStyle: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                    ),
                    onPressed: isCameraInitialized ? (isRunning ? stopSession : startSession) : null,
                    child: Text(isRunning ? 'STOP' : 'START'),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}

// Custom painter for rendering bounding boxes over the camera stream based on AI data.
class BoundingBoxPainter extends CustomPainter {
  final List<String> detections;
  final Color themeColor;

  BoundingBoxPainter(this.detections, this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = themeColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    final textStyle = TextStyle(color: Colors.black, backgroundColor: themeColor, fontSize: 18);

    for (var det in detections) {
      var parts = det.split(',');
      if (parts.length < 5) continue;
      String label = parts[0];
      double x1 = double.parse(parts[1]) * size.width;
      double y1 = double.parse(parts[2]) * size.height;
      double x2 = double.parse(parts[3]) * size.width;
      double y2 = double.parse(parts[4]) * size.height;
      canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), paint);
      TextPainter(text: TextSpan(style: textStyle, text: " $label "), textDirection: TextDirection.ltr)..layout()..paint(canvas, Offset(x1, y1 - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
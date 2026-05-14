import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'main.dart';

// Manages all UDP network communications, AI health tracking,
// and audio/haptic feedback for the client.
class NetworkManager {

  // STATE & CONFIGURATION VARIABLES

  RawDatagramSocket? _socket;

  InternetAddress _serverAddress = InternetAddress('192.168.1.100');
  int _serverPort = 5005;

  final FlutterTts tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final ValueNotifier<bool> isServerConnected = ValueNotifier<bool>(false);
  final ValueNotifier<String> systemStatus = ValueNotifier<String>("Offline");
  final ValueNotifier<bool> isTtsEnabled = ValueNotifier<bool>(true);

  Timer? _pingTimer;
  Timer? _timeoutTimer;
  Timer? _aiHealthTimer;
  DateTime? _lastAIDataReceived;

  final List<String> _descriptionBuffer = [];


  // PUBLIC GETTERS (For Testing)

  // Returns the current server IP address.
  InternetAddress get serverAddress => _serverAddress;

  // Returns the current server port.
  int get serverPort => _serverPort;

  // Returns the rolling buffer of the last received AI descriptions.
  List<String> get descriptionBuffer => _descriptionBuffer;


  // INITIALIZATION & LIFECYCLE

  // Initializes the UDP socket and begins listening for incoming server packets.
  Future<void> init(String serverIp, int port) async {
    _serverPort = port;
    try {
      _serverAddress = InternetAddress(serverIp);
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      debugPrint('✅ UDP Socket bound to local port: ${_socket!.port}');

      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket!.receive();
          if (datagram != null) {
            Uint8List packet = datagram.data;

            try {
              String message = utf8.decode(packet);
              if (message == "PONG") {
                if (isServerConnected.value == false) {
                  isServerConnected.value = true;
                  systemStatus.value = "Active";
                  announce("Connected to Server");
                }

                _timeoutTimer?.cancel();
                _timeoutTimer = Timer(const Duration(seconds: 4), () {
                  if (isServerConnected.value == true) {
                    isServerConnected.value = false;
                    systemStatus.value = "Offline";
                    announce("Server connection lost");
                  }
                });
                return;
              }
            } catch (e) {
              // Silently handle audio decoding failure
            }

            int magicByte = packet[0];
            Uint8List payload = packet.sublist(1);

            if (magicByte == 1) {
              _handleIncomingAudio(payload);
            } else if (magicByte == 3) {
              String rawData = utf8.decode(payload);
              detectionBoxesNotifier.value = rawData.split('|');
            }
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to initialize UDP socket: $e');
    }
  }

  // Closes the socket and disposes of hardware controllers.
  void dispose() {
    _socket?.close();
    _socket = null;
    _audioPlayer.dispose();
    debugPrint('🛑 UDP Socket closed.');
  }


  // HEARTBEAT & HEALTH MONITORING

  // Starts the network ping cycle and AI processing health checks.
  void startHeartbeat() {
    announce("Session Started");
    _startAIHealthCheck();
    _pingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      sendCommand("PING");
    });
  }

  // Stops all network timers and marks the server as disconnected.
  void stopHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    isServerConnected.value = false;
    announce("Session Stopped");
  }

  // Monitors the time since the last  data packet to detect processing delays.
  void _startAIHealthCheck() {
    _aiHealthTimer?.cancel();
    _aiHealthTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isServerConnected.value) {
        final now = DateTime.now();
        if (_lastAIDataReceived != null &&
            now.difference(_lastAIDataReceived!).inSeconds > 10) {
          systemStatus.value = "AI Struggling";
          announce("AI is taking longer than usual. Please stay still.");
        } else {
          systemStatus.value = "Active";
        }
      }
    });
  }


  // DATA TRANSMISSION (SEND)

  // Sends a compressed image frame to the Python server over UDP.
  void sendFrame(Uint8List frameData) {
    if (_socket == null) return;
    try {
      final builder = BytesBuilder();
      builder.addByte(1);
      builder.add(frameData);

      final packet = builder.toBytes();
      _socket!.send(packet, _serverAddress, _serverPort);
    } catch (e) {
      debugPrint('❌ Error sending frame: $e');
    }
  }

  // Sends a plaintext text command to the Python server.
  void sendCommand(String command) {
    if (_socket == null) return;

    final builder = BytesBuilder();
    builder.addByte(2);
    builder.add(utf8.encode(command));

    _socket!.send(builder.toBytes(), _serverAddress, _serverPort);
    debugPrint('⚙️ Sent Command to Server: $command');
  }

  // Helper method to send a language change command to the server.
  void changeLanguage(String langCode) {
    sendCommand("LANG:$langCode");
    debugPrint('🌍 Sent Language Command: $langCode');
  }

  // Parses and updates the server IP and port configuration.
  void updateServerIp(String input) {
    try {
      if (input.contains(':')) {
        final List<String> parts = input.split(':');
        _serverAddress = InternetAddress(parts[0]);

        int? newPort = int.tryParse(parts[1]);
        if (newPort != null) {
          _serverPort = newPort;
          debugPrint('🌐 Server Address updated to: ${parts[0]} Port: $newPort');
        }
      } else {
        _serverAddress = InternetAddress(input);
        debugPrint('🌐 Server IP updated to: $input (Using default port)');
      }
    } catch (e) {
      debugPrint('❌ Invalid Connection Format: $e');
    }
  }


  // DATA RECEPTION & PROCESSING

  // Buffers incoming description data to handle potential packet loss.
  void handleIncomingData(String data) {
    _lastAIDataReceived = DateTime.now();
    _descriptionBuffer.add(data);
    if (_descriptionBuffer.length > 3) _descriptionBuffer.removeAt(0);
  }

  // Processes incoming audio bytes, triggers haptics, and plays the audio stream.
  Future<void> _handleIncomingAudio(Uint8List audioBytes) async {
    if (isVibrationEnabledNotifier.value) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
    }

    debugPrint("🔊 Received ${audioBytes.length} bytes of audio data!");
    try {
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      debugPrint("❌ Error playing audio: $e");
    }
  }


  // HARDWARE & AUDIO UTILITIES

  // Announces a message aloud using the device's native TTS engine.
  Future<void> announce(String message) async {
    if (isTtsEnabled.value) {
      await tts.speak(message);
    }
  }

  // Adjusts the playback volume of the received AI audio stream.
  void setVolume(double vol) {
    _audioPlayer.setVolume(vol);
  }

  // Adjusts the playback speed of the received AI audio stream.
  Future<void> setAudioSpeed(double rate) async {
    try {
      await _audioPlayer.setPlaybackRate(rate);
    } catch (e) {
      debugPrint("Error setting playback rate: $e");
    }
  }
}
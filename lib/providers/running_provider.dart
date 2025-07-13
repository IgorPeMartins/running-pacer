import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import '../services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';

class RunningProvider extends ChangeNotifier {
  bool _isRunning = false;
  bool _isTracking = false;
  double _targetPace = 5.0; // minutes per kilometer
  double _currentPace = 0.0;
  double _distance = 0.0;
  Duration _elapsedTime = Duration.zero;
  final List<Position> _positions = [];
  Timer? _timer;
  Timer? _voiceFeedbackTimer;
  Timer? _metronomeTimer;
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _metronomePlayer = AudioPlayer();
  DateTime? _startTime;
  Position? _lastPosition;
  
  // Voice feedback control
  DateTime? _lastVoiceFeedback;
  bool _voiceFeedbackEnabled = true;
  bool _metronomeEnabled = true;
  int _currentBPM = 160; // Default BPM
  
  // Audio session management
  bool _audioSessionActive = false;
  bool _isSpeaking = false;

  // Getters
  bool get isRunning => _isRunning;
  bool get isTracking => _isTracking;
  double get targetPace => _targetPace;
  double get currentPace => _currentPace;
  double get distance => _distance;
  Duration get elapsedTime => _elapsedTime;
  bool get voiceFeedbackEnabled => _voiceFeedbackEnabled;
  bool get metronomeEnabled => _metronomeEnabled;
  int get currentBPM => _currentBPM;

  RunningProvider() {
    _initializeTts();
    _initializeAudioSession();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set up TTS completion callback
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> _initializeAudioSession() async {
    // Configure audio session for background operation
    await _metronomePlayer.setReleaseMode(ReleaseMode.stop);
    await _metronomePlayer.setVolume(0.5);
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.location] == PermissionStatus.granted ||
        statuses[Permission.locationWhenInUse] == PermissionStatus.granted) {
      _isTracking = true;
      notifyListeners();
    }
  }

  void setTargetPace(double pace) {
    _targetPace = pace;
    _updateBPMFromPace();
    notifyListeners();
  }

  void toggleVoiceFeedback() {
    _voiceFeedbackEnabled = !_voiceFeedbackEnabled;
    if (!_voiceFeedbackEnabled) {
      _voiceFeedbackTimer?.cancel();
    }
    notifyListeners();
  }

  void toggleMetronome() {
    _metronomeEnabled = !_metronomeEnabled;
    if (!_metronomeEnabled) {
      _stopMetronome();
    } else if (_isRunning) {
      _startMetronome();
    }
    notifyListeners();
  }

  void setBPM(int bpm) {
    _currentBPM = bpm;
    if (_isRunning && _metronomeEnabled) {
      _startMetronome();
    }
    notifyListeners();
  }

  void _updateBPMFromPace() {
    // Convert pace (min/km) to BPM
    // A 5:00 min/km pace roughly corresponds to 160 BPM
    // This is a simplified conversion - you might want to adjust based on your running style
    double basePace = 5.0; // 5:00 min/km
    double baseBPM = 160.0;
    double paceRatio = basePace / _targetPace;
    _currentBPM = (baseBPM * paceRatio).round();
    _currentBPM = _currentBPM.clamp(120, 200); // Keep BPM in reasonable range
  }

  Future<void> startRunning() async {
    if (!_isTracking) {
      await requestPermissions();
    }

    if (_isTracking) {
      _isRunning = true;
      _startTime = DateTime.now();
      _lastVoiceFeedback = null;
      _positions.clear();
      _distance = 0.0;
      _elapsedTime = Duration.zero;
      
      // Start foreground service for background operation
      await BackgroundService.startForegroundService();
      
      // Enable wake lock to keep screen on and app running
      WakelockPlus.enable();
      
      // Start main timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateElapsedTime();
        _checkPaceAndProvideFeedback();
      });

      // Start voice feedback timer (every 10 seconds)
      _startVoiceFeedbackTimer();

      // Start metronome if enabled
      if (_metronomeEnabled) {
        _startMetronome();
      }

      // Provide immediate feedback to ensure service is active
      _speakFeedback("Starting");

      _startLocationTracking();
      notifyListeners();
    }
  }

  void stopRunning() async {
    _isRunning = false;
    _timer?.cancel();
    _voiceFeedbackTimer?.cancel();
    _stopMetronome();
    WakelockPlus.disable();
    _stopLocationTracking();
    
    // Stop foreground service
    await BackgroundService.stopForegroundService();
    
    notifyListeners();
  }

  void _startVoiceFeedbackTimer() {
    _voiceFeedbackTimer?.cancel();
    _voiceFeedbackTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isRunning && _voiceFeedbackEnabled && _currentPace > 0) {
        _providePeriodicFeedback();
      }
    });
  }

  void _providePeriodicFeedback() {
    if (_currentPace <= 0 || _distance < 0.1) return;

    double paceDifference = _currentPace - _targetPace;
    String feedback;

    if (paceDifference.abs() < 0.1) {
      // On target pace
      feedback = "Good pace";
    } else if (paceDifference > 0.2) {
      // Too slow
      feedback = "Speed up";
    } else if (paceDifference < -0.2) {
      // Too fast
      feedback = "Slow down";
    } else {
      // Slightly off
      feedback = paceDifference > 0 ? "Speed up slightly" : "Slow down slightly";
    }

    _speakFeedback(feedback);
  }

  void _startMetronome() {
    _metronomeTimer?.cancel();
    if (_currentBPM <= 0) return;

    int intervalMs = (60000 / _currentBPM).round(); // Convert BPM to milliseconds
    _metronomeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_isRunning && _metronomeEnabled) {
        _playMetronomeTick();
      }
    });
  }

  void _stopMetronome() {
    _metronomeTimer?.cancel();
    _metronomePlayer.stop();
  }

  Future<void> _playMetronomeTick() async {
    try {
      // Use vibration for metronome to avoid conflicts with voice feedback
      HapticFeedback.lightImpact();
      if (kDebugMode) {
        print('Metronome tick at BPM: $_currentBPM');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Metronome error: $e');
      }
    }
  }

  void _updateElapsedTime() {
    if (_startTime != null) {
      _elapsedTime = DateTime.now().difference(_startTime!);
      notifyListeners();
    }
  }

  Future<void> _startLocationTracking() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters for more frequent updates
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _onLocationUpdate(position);
    });
  }

  void _stopLocationTracking() {
    // Position stream automatically stops when no listeners
  }

  void _onLocationUpdate(Position position) {
    if (!_isRunning) return;

    _positions.add(position);
    
    if (_positions.length >= 2) {
      _calculateDistance();
      _calculateCurrentPace();
    }
    
    _lastPosition = position;
    notifyListeners();
  }

  void _calculateDistance() {
    double totalDistance = 0.0;
    for (int i = 1; i < _positions.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        _positions[i - 1].latitude,
        _positions[i - 1].longitude,
        _positions[i].latitude,
        _positions[i].longitude,
      );
    }
    _distance = totalDistance / 1000; // Convert to kilometers
  }

  void _calculateCurrentPace() {
    if (_elapsedTime.inSeconds > 0 && _distance > 0) {
      double timeInMinutes = _elapsedTime.inSeconds / 60.0;
      _currentPace = timeInMinutes / _distance; // minutes per kilometer
    }
  }

  void _checkPaceAndProvideFeedback() {
    // This method now only handles immediate feedback for significant pace changes
    // Periodic feedback is handled by the dedicated timer
    if (_currentPace > 0 && _distance > 0.1) {
      double paceDifference = _currentPace - _targetPace;
      
      // Only provide immediate feedback for significant deviations
      if (paceDifference.abs() > 0.5) { // 30 seconds difference
        if (paceDifference > 0) {
          _speakFeedback("Speed up");
        } else {
          _speakFeedback("Slow down");
        }
      }
    }
  }

  Future<void> _speakFeedback(String message) async {
    if (_isRunning && _voiceFeedbackEnabled && !_isSpeaking) {
      _isSpeaking = true;
      // Use a different voice setting for feedback to distinguish from metronome
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.speak(message);
      // Reset to normal rate after feedback
      await _flutterTts.setSpeechRate(0.5);
    }
  }

  String getFormattedTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(_elapsedTime.inHours);
    String minutes = twoDigits(_elapsedTime.inMinutes.remainder(60));
    String seconds = twoDigits(_elapsedTime.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String getFormattedDistance() {
    return "${_distance.toStringAsFixed(2)} km";
  }

  String getFormattedCurrentPace() {
    if (_currentPace <= 0) return "--:--";
    int minutes = _currentPace.floor();
    int seconds = ((_currentPace - minutes) * 60).round();
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  String getFormattedTargetPace() {
    int minutes = _targetPace.floor();
    int seconds = ((_targetPace - minutes) * 60).round();
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voiceFeedbackTimer?.cancel();
    _metronomeTimer?.cancel();
    _metronomePlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
} 
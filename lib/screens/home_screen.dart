import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/running_provider.dart';
import '../widgets/pace_selector.dart';
import '../widgets/running_metrics.dart';
import '../widgets/control_buttons.dart';
import '../widgets/bpm_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request permissions when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunningProvider>().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Running Coach',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<RunningProvider>(
        builder: (context, runningProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pace Selector
                  if (!runningProvider.isRunning)
                    PaceSelector(
                      targetPace: runningProvider.targetPace,
                      onPaceChanged: runningProvider.setTargetPace,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // BPM Controls
                  BPMControls(),
                  
                  const SizedBox(height: 16),
                  
                  // Running Metrics
                  if (runningProvider.isRunning)
                    RunningMetrics(
                      elapsedTime: runningProvider.getFormattedTime(),
                      distance: runningProvider.getFormattedDistance(),
                      currentPace: runningProvider.getFormattedCurrentPace(),
                      targetPace: runningProvider.getFormattedTargetPace(),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Control Buttons
                  ControlButtons(
                    isRunning: runningProvider.isRunning,
                    onStart: runningProvider.startRunning,
                    onStop: runningProvider.stopRunning,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
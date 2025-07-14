import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/running_provider.dart';

class BPMControls extends StatelessWidget {
  const BPMControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RunningProvider>(
      builder: (context, runningProvider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Voice Feedback Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Voice Feedback'),
                    Switch(
                      value: runningProvider.voiceFeedbackEnabled,
                      onChanged: (value) => runningProvider.toggleVoiceFeedback(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Cadence Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cadence'),
                    Switch(
                      value: runningProvider.metronomeEnabled,
                      onChanged: (value) => runningProvider.toggleMetronome(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Cadence Slider
                if (runningProvider.metronomeEnabled) ...[
                  Text(
                    'Cadence: ${runningProvider.currentBPM}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: runningProvider.currentBPM.toDouble(),
                    min: 120,
                    max: 200,
                    divisions: 80,
                    label: '${runningProvider.currentBPM} Cadence',
                    onChanged: (value) {
                      runningProvider.setBPM(value.round());
                    },
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '120 Cadence',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '200 Cadence',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 
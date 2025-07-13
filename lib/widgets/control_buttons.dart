import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isRunning ? 'Running Session Active' : 'Ready to Start',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isRunning ? Colors.green[700] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isRunning ? onStop : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red[600] : Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRunning ? Icons.stop : Icons.play_arrow,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRunning ? 'Stop Running' : 'Start Running',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRunning ? Colors.green[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRunning ? Colors.green[200]! : Colors.blue[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isRunning ? Icons.location_on : Icons.location_searching,
                  color: isRunning ? Colors.green[600] : Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isRunning
                        ? 'GPS tracking active - Voice feedback enabled'
                        : 'Location permission required for pace tracking',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRunning ? Colors.green[700] : Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/running_provider.dart';

void main() {
  runApp(const RunningCoachApp());
}

class RunningCoachApp extends StatelessWidget {
  const RunningCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RunningProvider(),
      child: MaterialApp(
        title: 'Running Coach',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
} 
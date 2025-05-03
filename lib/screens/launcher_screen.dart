import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prime/providers/user_data.dart';
import 'package:prime/screens/home_screen.dart';
import 'package:prime/screens/setup_screen.dart';

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        if (userData.isInitialized) {
          return const HomeScreen();
        } else {
          return const SetupScreen();
        }
      },
    );
  }
}
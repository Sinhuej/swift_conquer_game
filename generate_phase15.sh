#!/bin/bash
echo "=== SwiftConquer • Phase 15A Auto-Build Structure ==="

BASE="swift_clean"
mkdir -p $BASE/lib/screens
mkdir -p $BASE/lib/game
mkdir -p $BASE/assets/images
mkdir -p $BASE/assets/sfx

# -----------------------
# pubspec.yaml
# -----------------------
cat << 'YAML' > $BASE/pubspec.yaml
name: swiftconquer
description: SwiftConquer RTS Core Shell
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/sfx/
YAML

# -----------------------
# analysis_options.yaml
# -----------------------
cat << 'ANA' > $BASE/analysis_options.yaml
include: package:flutter_lints/flutter.yaml
ANA

# -----------------------
# main.dart
# -----------------------
cat << 'DART' > $BASE/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftConquer',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const HomeScreen(),
        '/test': (_) => const TestScreen(),
      },
    );
  }
}
DART

# -----------------------
# Home Screen
# -----------------------
cat << 'DART' > $BASE/lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/test'),
          child: const Text("Launch Engine Test"),
        ),
      ),
    );
  }
}
DART

# -----------------------
# Test Screen
# -----------------------
cat << 'DART' > $BASE/lib/screens/test_screen.dart
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Engine Test")),
      body: const Center(
        child: Text(
          "SwiftConquer rebuild successful!",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
DART

# -----------------------
# Minimal Engine Shell
# -----------------------
cat << 'DART' > $BASE/lib/game/engine_base.dart
class EngineBase {
  String version = "0.0.1";

  EngineBase() {
    print("EngineBase initialized.");
  }

  void update(double dt) {
    // Game update loop placeholder
  }
}
DART

# -----------------------
# Simple Test Map
# -----------------------
cat << 'DART' > $BASE/lib/game/test_map.dart
class TestMap {
  final int width = 20;
  final int height = 20;

  TestMap() {
    print("Loading TestMap 20x20");
  }
}
DART

echo "=== Phase 15A Complete! Next: git add swift_clean && git commit && git push ==="

#!/bin/bash
set -e

echo "=== SwiftConquer FINAL Echo Rebuild ==="

# Backup old project
TS=$(date +%s)
mkdir -p _backup_$TS
for f in lib assets pubspec.yaml analysis_options.yaml android ios linux macos windows web; do
  [ -e "$f" ] && mv "$f" "_backup_$TS/"
done

# Create directories
mkdir -p lib/screens
mkdir -p assets/images assets/fonts assets/sfx

# pubspec.yaml
cat > pubspec.yaml <<'YAML'
name: swift_conquer_game
description: SwiftConquer RTS
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.34.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/fonts/
    - assets/sfx/
YAML

# analysis_options.yaml
cat > analysis_options.yaml <<'YAML'
include: package:flutter_lints/flutter.yaml

lints:
  rules:
    prefer_const_constructors: true
    avoid_print: false
YAML

# lib/main.dart
cat > lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'screens/test_screen.dart';

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
      home: const TestScreen(),
    );
  }
}
DART

# lib/screens/test_screen.dart
cat > lib/screens/test_screen.dart <<'DART'
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwiftConquer')),
      body: const Center(
        child: Text(
          'SwiftConquer rebuild successful!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
DART

echo "=== Echo rebuild complete ==="
echo "Next steps:"
echo "  git add ."
echo "  git commit -m 'Clean echo rebuild - Flutter CI baseline'"
echo "  git push"


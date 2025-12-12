#!/usr/bin/env bash
set -e

echo "=== Phase 15 • SwiftConquer Echo Rebuild (LOCAL) ==="

# Backup old Dart only (ignore platforms)
STAMP="_backup_phase15_$(date +%s)"
mkdir -p "$STAMP"

for f in lib pubspec.yaml analysis_options.yaml test assets; do
  [ -e "$f" ] && mv "$f" "$STAMP/"
done

echo "✔ Backed up existing Dart files to $STAMP"

# Directory structure
mkdir -p lib/screens test assets/fonts assets/images assets/sfx

# pubspec.yaml
cat > pubspec.yaml <<'YAML'
name: swift_conquer_game
description: SwiftConquer Phase 15 – stable Flutter shell
version: 0.1.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
YAML

# analysis_options.yaml (NO flutter_lints include)
cat > analysis_options.yaml <<'YAML'
linter:
  rules:
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
    return const Scaffold(
      body: Center(
        child: Text(
          'SwiftConquer Phase 15\nBuild Successful',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
DART

# test/widget_test.dart (minimal, safe)
cat > test/widget_test.dart <<'DART'
void main() {
  // Intentionally empty for Phase 15
}
DART

echo "=== Phase 15 Echo Rebuild COMPLETE ==="
echo "Next:"
echo "  git add lib pubspec.yaml analysis_options.yaml test assets"
echo "  git commit -m 'Phase 15 echo rebuild – Flutter shell only'"
echo "  git push"


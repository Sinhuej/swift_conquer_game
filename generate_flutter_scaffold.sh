#!/bin/bash
set -e

echo "=== Swift Conquer • Universal Flutter Scaffold Generator ==="

# Create required dirs
mkdir -p android/app/src/main/java/com/swiftconquer/app
mkdir -p ios/Runner
mkdir -p web
mkdir -p linux
mkdir -p macos
mkdir -p windows
mkdir -p test
mkdir -p assets/images
mkdir -p assets/fonts
mkdir -p assets/sfx

# ==================================================================
# Root files
# ==================================================================

cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml
EOF

cat > pubspec.yaml << 'EOF'
name: swift_conquer_game
description: Swift Conquer minimal rebuild
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: any

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
    - assets/sfx/
EOF

# ==================================================================
# lib files
# ==================================================================

mkdir -p lib/screens
mkdir -p lib/game

cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SwiftConquerApp());

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Swift Conquer",
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
EOF

cat > lib/screens/home_screen.dart << 'EOF'
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swift Conquer")),
      body: const Center(
        child: Text("Swift Conquer Base Build Ready"),
      ),
    );
  }
}
EOF

# Empty test
cat > test/widget_test.dart << 'EOF'
void main() {}
EOF

echo "=== Scaffold generation complete ==="
echo "Next:"
echo "  git add ."
echo "  git commit -m 'Add full Flutter scaffold'"
echo "  git push"


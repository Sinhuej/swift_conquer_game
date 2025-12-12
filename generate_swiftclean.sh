#!/bin/bash
echo "=== SwiftConquer • Generate Clean Flutter Shell ==="

# 1. Remove old scaffold if exists
rm -rf swift_clean
mkdir -p swift_clean/lib/screens
mkdir -p swift_clean/assets/images
mkdir -p swift_clean/assets/sfx
mkdir -p swift_clean/assets/fonts

#################################
# 2. pubspec.yaml
#################################
cat > swift_clean/pubspec.yaml << 'EOF'
name: swift_conquer
description: SwiftConquer Base Shell
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flame: ^1.11.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/sfx/
    - assets/fonts/
EOF

#################################
# 3. analysis_options.yaml
#################################
cat > swift_clean/analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml
EOF

#################################
# 4. lib/main.dart
#################################
cat > swift_clean/lib/main.dart << 'EOF'
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
      routes: {
        '/': (_) => const HomeScreen(),
        '/test': (_) => const TestScreen(),
      },
    );
  }
}
EOF

#################################
# 5. Home Screen
#################################
cat > swift_clean/lib/screens/home_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer Home")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Launch Test Screen"),
          onPressed: () => Navigator.pushNamed(context, '/test'),
        ),
      ),
    );
  }
}
EOF

#################################
# 6. Test Screen
#################################
cat > swift_clean/lib/screens/test_screen.dart << 'EOF'
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Screen")),
      body: const Center(child: Text("SwiftConquer rebuild successful!")),
    );
  }
}
EOF

echo "=== Echo rebuild complete! ==="
echo "Next:"
echo "  git add swift_clean"
echo "  git commit -m 'Add working SwiftConquer Flutter shell'"
echo "  git push"
EOF


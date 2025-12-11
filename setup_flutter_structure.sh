#!/bin/bash
set -e

echo "=== Rebuilding Flutter platform folders without flutter create ==="

mkdir -p android ios web linux macos windows

curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/android.tmpl.tgz | tar -xz -C android --strip-components=1
curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/ios.tmpl.tgz     | tar -xz -C ios --strip-components=1
curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/web.tmpl.tgz     | tar -xz -C web --strip-components=1
curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/linux.tmpl.tgz   | tar -xz -C linux --strip-components=1
curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/macos.tmpl.tgz   | tar -xz -C macos --strip-components=1
curl -L https://github.com/flutter/flutter/raw/master/packages/flutter_tools/templates/app/windows.tmpl.tgz | tar -xz -C windows --strip-components=1

echo "=== Platform folders recreated ==="


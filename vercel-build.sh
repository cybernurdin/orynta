#!/bin/bash
set -e

echo "Installing Flutter..."

git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
export PATH="$PATH:$(pwd)/flutter/bin"

flutter --version
flutter config --enable-web

echo "Getting packages..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release

echo "Build completed."

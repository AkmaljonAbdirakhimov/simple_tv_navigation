#!/bin/bash

# Ensure we're in the example directory
cd "$(dirname "$0")"

# Run the example launcher on Android TV
flutter run -d android-tv lib/main.dart 
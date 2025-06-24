#!/bin/bash

echo "🧹 Cleaning iOS build files..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

flutter clean
flutter pub get
flutter run
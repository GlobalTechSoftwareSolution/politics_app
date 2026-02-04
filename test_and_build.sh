#!/bin/bash

# Politics App Testing & Distribution Script
# This script automates your entire testing and distribution workflow

echo "🚀 Politics App - Testing & Distribution Workflow"
echo "==============================================="

# Step 1: Run integration tests
echo "📋 Step 1: Running integration tests..."
flutter test integration_test

if [ $? -eq 0 ]; then
    echo "✅ Integration tests passed!"
else
    echo "❌ Integration tests failed. Please fix issues before proceeding."
    exit 1
fi

# Step 2: Build release APK
echo "📦 Step 2: Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Release APK built successfully!"
else
    echo "❌ APK build failed!"
    exit 1
fi

# Step 3: Show APK location
echo "📍 APK Location:"
echo "build/app/outputs/flutter-apk/app-release.apk"
echo "Size: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"

# Step 4: Distribute to Firebase App Distribution
echo "🚀 Step 4: Distributing to Firebase App Distribution..."
FIREBASE_APP_ID="1:795000728222:android:3c7de1e582e165d457a98f"  # From firebase_options.dart
FIREBASE_TESTER_GROUP="testers"  # Replace with your tester group name

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not installed. Please install it first."
    exit 1
fi

# Check if we're logged in to Firebase
if ! firebase login:list &> /dev/null; then
    echo "🔐 Logging in to Firebase..."
    firebase login
fi

# Distribute the APK
echo "📤 Distributing APK to Firebase App Distribution..."
# Distribute to specific tester emails (replace with actual emails of your testers)
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_APP_ID" \
  --testers "hrglobaltechsoftwaresolutions@gmail.com" \
  --release-notes "New version available for testing"

if [ $? -eq 0 ]; then
    echo "✅ APK distributed successfully to Firebase App Distribution!"
else
    echo "❌ Distribution failed!"
    exit 1
fi

echo ""
echo "✅ Workflow completed successfully!"
echo ""
echo "Next steps:"
echo "1. Check Firebase Console for distribution status: https://console.firebase.google.com/project/politics-app-1234/appdistribution"
echo "2. Invite testers to the 'testers' group"
echo "3. For automated workflow: Add this script to your CI/CD pipeline"
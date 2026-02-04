#!/bin/bash

# Politics App - Firebase App Distribution Script
# This script automates the entire build and distribution process

echo "🚀 Politics App - Build & Firebase Distribution Workflow"
echo "======================================================"

# Configuration
FIREBASE_APP_ID="1:795000728222:android:3c7de1e582e165d457a98f"
FIREBASE_TESTER_GROUP="testers"
RELEASE_NOTES="New integration test build with latest features"

# Step 1: Run integration tests
echo "📋 Step 1: Running integration tests..."
flutter test integration_test

if [ $? -eq 0 ]; then
    echo "✅ Integration tests passed!"
else
    echo "❌ Integration tests failed. Please fix issues before proceeding."
    echo "⚠️  You can bypass tests by commenting out the test step"
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

# Step 3: Show APK information
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
echo "📍 Step 3: APK Location: $APK_PATH"
echo "📏 Size: $(du -h $APK_PATH | cut -f1)"
echo "🔐 APK Signature Info (SHA-1):"
keytool -printcert -jarfile $APK_PATH 2>/dev/null || echo "⚠️  Could not get signature info (APK is not signed with custom keystore)"

# Step 4: Distribute to Firebase App Distribution
echo "🚀 Step 4: Distributing to Firebase App Distribution..."

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not installed. Installing..."
    npm install -g firebase-tools
fi

# Check if we're logged in to Firebase
if ! firebase login:list &> /dev/null; then
    echo "🔐 Logging in to Firebase..."
    firebase login
fi

# Distribute the APK
echo "📤 Uploading APK to Firebase App Distribution..."
firebase appdistribution:distribute $APK_PATH \
  --app "$FIREBASE_APP_ID" \
  --testers "hrglobaltechsoftwaresolutions@gmail.com" \
  --release-notes "$RELEASE_NOTES"

if [ $? -eq 0 ]; then
    echo "✅ APK distributed successfully to Firebase App Distribution!"
    echo "📧 Testers will receive email notifications with download links"
    echo "🔗 Firebase Console: https://console.firebase.google.com/project/politics-app-1234/appdistribution"
else
    echo "❌ Distribution failed!"
    exit 1
fi

echo ""
echo "✅ Workflow completed successfully!"
echo ""
echo "Next steps:"
echo "1. Check Firebase Console for distribution status"
echo "2. Verify testers received email notifications"
echo "3. Monitor for feedback from testers"
echo "4. For automated workflow: Add this script to your CI/CD pipeline"
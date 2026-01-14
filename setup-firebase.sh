#!/bin/bash

echo "🔥 Firebase Setup for ArtXchange 🔥"
echo "=================================="

# Check if Firebase service account exists
if [ -f "src/main/resources/firebase-service-account.json" ]; then
    echo "✅ Firebase service account key found"
else
    echo "❌ Firebase service account key NOT found"
    echo ""
    echo "📋 To set up Firebase:"
    echo "1. Go to https://console.firebase.google.com/"
    echo "2. Create or select your project"
    echo "3. Go to Project Settings → Service accounts"
    echo "4. Click 'Generate new private key'"
    echo "5. Download the JSON file"
    echo "6. Save it as: src/main/resources/firebase-service-account.json"
    echo ""
    echo "🔒 IMPORTANT: Never commit this file to git!"
    echo ""
fi

# Check project ID
echo ""
echo "📝 Update your Firebase Project ID:"
echo "Edit src/main/java/com/artexchange/config/FirebaseConfig.java"
echo "Change 'artexchange-malaysia' to your actual project ID"
echo ""

# Set environment variable option
echo "💡 Alternative: Set environment variable"
echo "export FIREBASE_PROJECT_ID='your-actual-project-id'"
echo ""

echo "🚀 Once configured, run: mvn tomcat7:run"

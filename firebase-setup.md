# Firebase Setup Instructions

## 1. Place your Firebase service account key
- Download the JSON key file from Firebase Console
- Save it as: `src/main/resources/firebase-service-account.json`
- This file contains your private keys - NEVER commit it to git!

## 2. Add to .gitignore
Make sure your .gitignore includes:
```
src/main/resources/firebase-service-account.json
```

## 3. Update FirebaseConfig.java
The application will automatically look for the service account file in the resources folder.

## 4. Environment Variables (Alternative)
Instead of placing the file, you can set environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/firebase-service-account.json"
```

## 5. Firebase Project Configuration
Update these values in FirebaseConfig.java with your actual Firebase project details:
- PROJECT_ID: your-firebase-project-id
- DATABASE_URL: https://your-project-id-default-rtdb.firebaseio.com/

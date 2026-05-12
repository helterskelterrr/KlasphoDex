# CreatureLens

CreatureLens is a Flutter mobile app that turns captured object photos into fantasy creatures with OpenRouter vision models for the class demo, stores the collection locally, and syncs player data with Firebase.

## Requirements

- Flutter SDK matching `pubspec.yaml`
- Firebase project `klasphodex-6b9e4`
- Node.js 20 for Cloud Functions
- Android signing config for release builds

## Flutter Setup

```sh
flutter pub get
flutter run
```

For the free class-demo path, run the app with an OpenRouter key supplied at launch:

```sh
flutter run --dart-define=OPENROUTER_API_KEY=your_openrouter_key
```

For convenience during the class demo, the app also reads `OPENROUTER_API_KEY` from the local `.env` asset when no dart define is provided. This calls free OpenRouter vision models directly from Flutter, starting with Gemma and falling back to Nemotron when the Gemma providers are rate-limited. Do not ship this direct-key setup for production apps, because client app secrets can be extracted from builds.

## Demo Scope

This repository's runtime app is the Flutter Android app. The `UI/` folder is a design prototype/reference from the UI exploration phase, not part of the demo build path.

For the class demo, the happy path is:

1. Open the Android app.
2. Capture an object photo with the scanner, or use the gallery button.
3. Reveal the generated creature.
4. Add it to the collection.
5. Build a Field Trials deck once enough creatures are collected.
6. Start a battle and finish the result screen.

If OpenRouter is unreachable or the key is missing, the app shows a safe fallback creature marked as offline synthesis mode, so the demo can continue without a workaround.

## Firebase Functions

Install and test the backend:

```sh
cd functions
npm install
npm test
```

Set the AI provider secret before deploying:

```sh
firebase functions:secrets:set OPENROUTER_API_KEY
firebase deploy --only functions
```

Firebase Functions deployment requires the Blaze plan. The direct OpenRouter demo path above avoids deploying Functions.

## Auth And Sync

The MVP signs users in anonymously with Firebase Auth on startup. User progression is stored in `users/{uid}`, while creatures, decks, and trial results sync under user-owned subcollections protected by Firestore rules.

## Android Release Signing

Copy `android/key.properties.example` to `android/key.properties` and fill local signing values. Release builds fail clearly when the signing file is missing.

```sh
flutter build apk --release
```

## Verification

```sh
flutter analyze
flutter test
cd functions && npm test
```

## Privacy Notes

The selected scan photo, a generic scan label, and progression context are sent to OpenRouter for creature generation in the demo build. The captured photo is stored locally as the creature card image. The app uses anonymous Firebase accounts for sync without requiring email or social login.

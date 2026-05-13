# KlasphoDex by Nadief Aqila Rabbani 

KlasphoDex is a Flutter mobile app that turns captured detected object photos using Google ML kit into fantasy creatures with OpenRouter vision models for the class demo, stores the collection locally, and syncs player data with Firebase.

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

## Core Technology: AI & Computer Vision

CreatureLens uses a hybrid approach to bridge the gap between real-time feedback and high-fidelity creativity:

### 1. On-Device Real-Time Scanning (ML Kit)
*   **Purpose:** Provides immediate, low-latency object recognition during the live camera preview.
*   **Implementation:** Uses `google_mlkit_image_labeling` to detect objects locally on the device without internet calls.
*   **Stabilization:** Includes a custom `ScanLabelStabilizer` that requires consistent detection across multiple frames before "locking" on a target to prevent UI flickering.

### 2. Generative Vision Analysis (OpenRouter)
*   **Purpose:** Deeply analyzes the captured photo to "hallucinate" a fantasy creature based on visual features (color, texture, shape).
*   **Implementation:** Sends the high-res image and ML Kit labels to OpenRouter (e.g., Gemini 1.5 Flash) via Cloud Functions or direct API calls.
*   **Result:** Transforms a mundane object (like a "Coffee Cup") into a unique collectible creature (like a "Java Golem").

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

## Screenshots
<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/37e05b39-c298-4383-a7e0-621b8a33a84a" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/9261c2a0-58df-4e6b-b4d9-30c1439678f2" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/b9ea21b1-6089-4a61-81c8-83694dfc836f" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/2a543afe-05b3-4d6a-80ce-594e93b1c24e" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/d33d9150-3bed-4820-a0bf-72fa865e2cc4" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/2ee0a74f-c367-4779-a2cb-52cde73a56d9" />

<img width="596" height="1280" alt="image" src="https://github.com/user-attachments/assets/adcf93a2-5df3-46d5-9fbb-33f040a97a4a" />


## Privacy Notes

The selected scan photo, a generic scan label, and progression context are sent to OpenRouter for creature generation in the demo build. The captured photo is stored locally as the creature card image. The app uses anonymous Firebase accounts for sync without requiring email or social login.


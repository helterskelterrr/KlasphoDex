# CreatureLens — Implementation Plan

## Overview

A 10-day development plan broken into 4 phases. Each day includes specific deliverables and estimated hours.

> **Assumptions:** Developer has Flutter experience, Firebase project set up, Gemini API key obtained.

---

## Phase 1: Foundation (Days 1–2)

### Day 1 — Project Setup & Architecture
- Initialize Flutter project with proper package structure
- Set up Riverpod, GoRouter, and theme system
- Configure Firebase (Auth, Firestore, Storage)
- Create data models (User, Creature, Achievement, DailyMission)
- Set up folder structure: `models/`, `providers/`, `services/`, `screens/`, `widgets/`, `utils/`
- **Deliverable:** Compilable project with navigation shell

### Day 2 — Auth & User System
- Implement Firebase Auth with Google Sign-In
- Create auth state provider with Riverpod
- Build Splash Screen with animated logo
- Build Auth Screen with sign-in button
- Create user document on first sign-in
- Implement auto-login on app restart
- **Deliverable:** Working auth flow

---

## Phase 2: Core AI Loop (Days 3–5)

### Day 3 — Camera & ML Kit Integration
- Integrate `camera` package for live preview
- Add `google_mlkit_image_labeling` for object recognition
- Build Camera Screen with real-time label overlay
- Implement capture → process → extract labels flow
- **Deliverable:** Working camera that identifies objects

### Day 4 — Gemini Creature Generation
- Set up `google_generative_ai` package
- Design prompt engineering for creature generation
- Parse Gemini JSON response into Creature model
- Handle API errors and rate limiting
- Save generated creature to Firestore
- **Deliverable:** Scan object → get creature data

### Day 5 — Creature Reveal Experience
- Build animated Creature Reveal Screen
- Card flip / particle effect reveal animation
- Display creature name, type, rarity, stats, lore
- Add "Add to Pokédex" flow
- Implement duplicate detection → Evolution Shards
- **Deliverable:** Full scan-to-reveal loop

---

## Phase 3: Collection & Gamification (Days 6–8)

### Day 6 — Pokédex & Collection
- Build Pokédex Screen with grid/list toggle
- Implement filter chips (by type, rarity)
- Implement sort options (name, date, rarity)
- Build Creature Detail Screen
- Real-time Firestore sync for collection
- **Deliverable:** Browsable creature collection

### Day 7 — XP, Leveling & Streaks
- Implement XP gain per scan (base + rarity bonus)
- Level-up system with thresholds
- Daily streak tracking (reset at midnight)
- Streak multiplier for rarity rolls
- Level-up celebration animation
- **Deliverable:** Working progression system

### Day 8 — Achievements & Daily Missions
- Define achievement catalogue (15+ achievements)
- Achievement unlock checker service
- Build achievements UI in Profile Screen
- Implement daily mission rotation (3 per day)
- Mission progress tracking
- **Deliverable:** Full gamification system

---

## Phase 4: Polish & Release (Days 9–10)

### Day 9 — UI Polish & Animations
- Implement dark/light theme toggle
- Add Lottie animations (loading, scan, level-up)
- Hero transitions between screens
- Haptic feedback on key interactions
- Empty states and error states
- Responsive layout adjustments

### Day 10 — Testing & Release
- Manual testing of all flows
- Edge case handling (no camera, no internet, API limits)
- Performance optimization (image caching, lazy loading)
- Build release APK
- **Deliverable:** Release-ready APK

---

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│                  UI Layer               │
│  Screens → Widgets → Theme/Design      │
├─────────────────────────────────────────┤
│              State Layer                │
│        Riverpod Providers               │
│  (Auth, Creatures, Gamification, etc.)  │
├─────────────────────────────────────────┤
│             Service Layer               │
│  AuthService  │ CreatureService         │
│  GeminiService│ GamificationService     │
│  MLKitService │ MissionService          │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  Firebase Firestore  │  Firebase Auth   │
│  Firebase Storage    │  Local Cache     │
└─────────────────────────────────────────┘
```

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Gemini API rate limits | Implement cooldown timer, cache responses |
| ML Kit accuracy issues | Use confidence threshold (>70%), allow manual label override |
| Large Firestore reads | Paginate collection queries, use local cache |
| No internet | Queue scans locally, sync when online |
| Creature image generation | Use placeholder/generated avatar system as fallback |

## Pre-Development Checklist

- [ ] Flutter SDK installed and updated
- [ ] Firebase project created (Android configured)
- [ ] Gemini API key obtained
- [ ] Google Sign-In configured in Firebase Console
- [ ] Android device/emulator ready for testing

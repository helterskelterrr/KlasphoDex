# CreatureLens — Requirements Document

## 1. App Overview

**CreatureLens** is a gamified AI-powered mobile app where users scan real-world objects using their camera, and the AI generates unique fantasy creatures inspired by those objects. Users collect creatures in a Pokédex-style collection, earn XP, maintain streaks, and complete daily missions.

## 2. Core Features

### 2.1 Camera Scanning
- Open device camera to scan real-world objects/animals/plants
- Use Google ML Kit for on-device object/label recognition
- Display recognized labels with confidence scores
- Support both rear and front cameras

### 2.2 AI Creature Generation
- Send recognized object data to Google Gemini API
- Gemini generates a unique creature with:
  - **Name** (creative, themed name)
  - **Type** (elemental type: Fire, Water, Earth, Air, Electric, Nature, Shadow, Light)
  - **Rarity** (Common, Uncommon, Rare, Epic, Legendary)
  - **Stats** (HP, Attack, Defense, Speed — 1-100 scale)
  - **Abilities** (2-3 unique abilities with descriptions)
  - **Lore** (short backstory paragraph)
- Generate creature image via Gemini's image generation or a placeholder system
- Creature uniqueness based on: scanned object + time of day + user level

### 2.3 Pokédex Collection
- Grid/list view of all collected creatures
- Filter by: type, rarity, date collected
- Sort by: name, rarity, date, stats
- Creature detail page with full stats, lore, and scan info
- Track total unique creatures discovered
- Duplicate scanning yields "Evolution Shards" for upgrades

### 2.4 Gamification System
- **XP & Leveling:** Earn XP per scan, level up to unlock new features
- **Daily Streaks:** Scan at least 1 creature per day to maintain streak
- **Achievements:** Unlockable badges (e.g., "First Catch", "Type Master", "100 Creatures")
- **Daily Missions:** 3 rotating daily missions (e.g., "Scan a plant", "Find a Rare creature")
- **Streak Multiplier:** Longer streaks = higher rarity chance

### 2.5 User Profile
- Display username, avatar, level, XP bar
- Stats: total creatures, rarest catch, longest streak, achievements
- Settings: theme toggle, notification preferences

## 3. Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Camera | camera package |
| Object Recognition | google_mlkit_image_labeling |
| AI Generation | Google Gemini API (via google_generative_ai) |
| Database | Firebase Firestore |
| Auth | Firebase Auth (Google Sign-In) |
| Storage | Firebase Storage (creature images) |
| Local Cache | Hive / SharedPreferences |
| Animations | Lottie + custom Flutter animations |

## 4. Data Models

### User
```
- uid: String
- displayName: String
- email: String
- photoUrl: String
- level: int
- xp: int
- totalCreatures: int
- currentStreak: int
- longestStreak: int
- lastScanDate: DateTime
- achievements: List<String>
- createdAt: DateTime
```

### Creature
```
- id: String
- userId: String
- name: String
- type: String (element)
- rarity: String
- hp: int
- attack: int
- defense: int
- speed: int
- abilities: List<Map<String, String>>
- lore: String
- imageUrl: String
- scannedObject: String
- scannedLabels: List<String>
- discoveredAt: DateTime
- evolutionShards: int
```

### Achievement
```
- id: String
- title: String
- description: String
- iconName: String
- requirement: Map<String, dynamic>
- unlockedAt: DateTime?
```

### DailyMission
```
- id: String
- title: String
- description: String
- type: String
- target: dynamic
- progress: int
- completed: bool
- date: DateTime
```

## 5. Screen Map

1. **Splash Screen** → animated logo + loading
2. **Auth Screen** → Google Sign-In
3. **Home Screen** → dashboard with stats, streak, daily missions, scan button
4. **Camera/Scan Screen** → live camera with ML Kit overlay
5. **Creature Reveal Screen** → animated reveal of generated creature
6. **Pokédex Screen** → collection grid with filters
7. **Creature Detail Screen** → full creature stats and lore
8. **Profile Screen** → user stats and achievements
9. **Settings Screen** → app preferences

## 6. Navigation Flow

```
Splash → Auth → Home
                  ├── Scan → Reveal → (back to Home or Pokédex)
                  ├── Pokédex → Creature Detail
                  ├── Profile → Settings
                  └── Daily Missions
```

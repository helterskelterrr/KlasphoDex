# CreatureLens Simple Deckbuilder Gameplay Requirements and Plan

Last updated: 2026-05-09
Status: Draft for MVP planning

## 1. Purpose

Add a lightweight deckbuilder gameplay mode to CreatureLens without weakening the main scan loop. The mode should make collected creatures useful beyond the Field Journal: users scan real-world objects, awaken creatures, build a small deck from those creatures, then play short solo "Field Trial" battles for XP and Evolution Shards.

The deckbuilder is a companion mode, not the new center of the app. The scan action remains the primary product action.

## 2. Product Positioning

Working feature name: Field Trials

Fantasy:

- The scanner has found unstable anomalies.
- The user's collected creatures can be arranged into a research deck.
- Each trial is a short tactical encounter where creature cards stabilize the anomaly.
- Winning gives XP, shard rewards, and reasons to keep scanning for stronger or more varied creatures.

Tone:

- Magical field research, not a casino card game.
- Fast and readable on mobile.
- Strategic enough to feel meaningful, simple enough to ship early.

## 3. MVP Goals

The MVP should:

- Let users create one active deck from collected creatures.
- Convert each collected creature into a playable card using existing stats, type, rarity, abilities, and power.
- Let users play a short solo battle against one AI anomaly.
- Resolve turns with deterministic rules, small numbers, and clear feedback.
- Reward the existing progression systems: XP, streak engagement, and Evolution Shards.
- Work locally with Hive first, matching the current storage direction.
- Fit the current Flutter, Riverpod, GoRouter, and shared widget architecture.

## 4. Non-Goals For MVP

Do not build these in the first version:

- PvP.
- Real-time multiplayer.
- Trading cards.
- Card pack monetization.
- Procedural roguelike maps.
- Dozens of custom card effects from Gemini text.
- Server-authoritative combat.
- Permanent creature death.
- Complex status stacks or combo chains.

These can be considered after the simple loop feels fun.

## 5. Unlocking And Entry Points

### Unlock Rule

The Field Trials entry and Deck Builder unlock after the user has collected at least 5 creatures. Starting an actual trial still requires a valid 8-card deck.

Reason:

- It protects the scan-first identity.
- It gives the user enough variety to make deckbuilding meaningful.
- It avoids needing a large starter-card system.

### Locked State

If the user has fewer than 5 creatures:

- Show a locked Field Trials card on Home.
- Copy: "Awaken 5 creatures to begin Field Trials."
- CTA: "Scan Creature"
- Show progress: `2/5 creatures awakened`

### Entry Points

MVP entry points:

- Home: secondary panel below Daily Missions or near Recent Discovery.
- Field Journal: action in top bar or creature detail prompt, "Use in Trial".
- Profile: optional stats row after first trial is completed.

Do not add Field Trials to the bottom navigation in MVP. Home, Scan, Field Journal, and Profile should stay clean.

## 6. Core User Flow

Primary flow:

1. User opens Home.
2. User taps Field Trials.
3. App opens Deck Builder.
4. User selects 8 creature cards from their collection.
5. User starts a Field Trial.
6. App shows the anomaly, difficulty, and recommended deck power.
7. User plays a turn-based battle.
8. App shows Victory or Defeat.
9. User receives rewards or feedback.
10. User can return to Home, edit deck, or scan for better creatures.

Fast replay flow:

1. User completes a trial.
2. User taps "Run Another Trial".
3. App starts a new anomaly using the current active deck.

## 7. Deckbuilding Requirements

### Deck Size

MVP deck size: 8 cards.

Rules:

- A deck can only include creatures the user has collected.
- Each creature can appear once because duplicates are currently represented as Evolution Shards, not duplicate creature records.
- The active deck is valid only when it has exactly 8 cards.
- If a collected creature is deleted later, remove it from the active deck automatically.

### Card Sorting And Filters

Deck Builder must support:

- Filter by type.
- Filter by rarity.
- Sort by power.
- Sort by name.
- Sort by newest.

### Recommended Deck Hints

Show simple hints:

- "Add more Water or Light cards for this trial."
- "Average deck power is below recommended."
- "You have no shield-heavy cards."

These hints can be rule-based. No Gemini call is needed.

## 8. Card Derivation Rules

The app should derive combat values from the existing `Creature` model. Do not store duplicate card stats unless a later version introduces card upgrades.

### Derived Card Fields

For each creature card:

- `creatureId`: existing creature id.
- `displayName`: creature name.
- `type`: creature type.
- `rarity`: creature rarity.
- `power`: existing `totalPower`.
- `cost`: calculated from rarity and power.
- `damage`: calculated from attack and rarity.
- `shield`: calculated from defense.
- `speedTier`: calculated from speed.
- `effect`: calculated from type.

### Cost Formula

Use a small, predictable cost range:

- Common or Uncommon: 1 focus.
- Rare: 2 focus.
- Epic or Legendary: 3 focus.
- If `totalPower < 45`, reduce cost by 1 but never below 1.
- If `totalPower >= 85`, increase cost by 1 but never above 3.

### Damage Formula

Use small battle numbers:

```text
baseDamage = max(1, round(attack / 12))
rarityBonus:
  Common = 0
  Uncommon = 1
  Rare = 2
  Epic = 3
  Legendary = 4
damage = baseDamage + rarityBonus
```

### Shield Formula

```text
shield = max(0, round(defense / 18))
```

### Speed Tier

```text
speed < 45 = Slow
45 to 74 = Normal
75 or higher = Quick
```

Quick cards draw 1 extra card the first time they are played each battle.

## 9. Type Effects

Each played card applies one simple type effect:

| Type | Effect Name | MVP Effect |
|------|-------------|------------|
| Fire | Burn | Deal 1 extra damage at the end of the turn. |
| Water | Mend | Restore 1 player resolve. |
| Earth | Guard | Gain 2 extra shield. |
| Air | Draft | Draw 1 card, once per turn. |
| Electric | Spark | Deal 1 damage to the anomaly even if shielded. |
| Nature | Grow | The next played card deals +1 damage. |
| Shadow | Weaken | Reduce the next anomaly attack by 1. |
| Light | Focus | Gain 1 focus next turn. |

Rules:

- Effects should be shown as clear text on cards.
- Effects should be deterministic.
- Effects should not use freeform Gemini ability descriptions for combat logic.
- Existing creature abilities can remain flavor text in the card detail sheet.

## 10. Field Trial Battle Rules

### Player Resource

Player resource name: Focus

- Start each turn with 3 focus.
- Light effects can increase next-turn focus to 4.
- Unused focus does not carry over.

### Player Health

Player health name: Resolve

- Starting resolve: 20.
- Resolve cannot exceed 20 in MVP.
- If resolve reaches 0, the player loses.

### Anomaly Health

Difficulty levels:

| Difficulty | Anomaly HP | Anomaly Attack | Recommended Deck Power | Rewards |
|------------|------------|----------------|-------------------------|---------|
| Calm | 24 | 3 | 45 | 20 XP, 1 shard |
| Wild | 36 | 5 | 60 | 40 XP, 2 shards |
| Mythic | 52 | 7 | 75 | 70 XP, 3 shards |

MVP can ship with Calm and Wild first. Mythic can be present as a locked UI state until balancing is ready.

### Turn Structure

1. Draw cards until hand has 3 cards.
2. Start with 3 focus.
3. Player plays any number of cards they can afford.
4. Played cards deal damage and apply effects immediately.
5. Cards played this turn move to discard.
6. Anomaly performs its telegraphed action if still alive.
7. Shield expires at the end of the turn.
8. If deck is empty, shuffle discard into deck.
9. Battle ends on victory, defeat, or turn limit.

### Turn Limit

Turn limit: 7 turns.

If the anomaly is still alive after turn 7, the result is "Signal Lost" and counts as a defeat.

### Anomaly Intent

MVP intents:

- Attack: deal listed damage.
- Guard: gain 4 shield.
- Distort: reduce player focus by 1 next turn.

Intent pattern:

```text
Turn 1: Attack
Turn 2: Guard
Turn 3: Attack
Turn 4: Distort
Repeat
```

The next intent must be visible before the player commits their turn.

## 11. Rewards

### Victory Rewards

On victory:

- Grant XP based on difficulty.
- Grant Evolution Shards to one random creature in the active deck.
- Add trial count to user stats.
- Update daily mission progress if a mission targets Field Trials.

Shard target rule:

- Pick a random card from the deck.
- If a creature of the same id exists, add the reward shards to that creature's `evolutionShards`.

### Defeat Rewards

On defeat:

- Grant no shards.
- Grant 5 consolation XP once per day.
- Show one practical hint, such as "Try more Earth cards for shield."

### Daily Mission Extensions

Future daily missions can include:

- Complete 1 Field Trial.
- Win with 3 Nature cards.
- Win without dropping below 10 resolve.
- Win a Wild trial.

## 12. Screens

### 12.1 Home Field Trials Panel

States:

- Locked, fewer than 5 creatures.
- Ready, valid active deck exists.
- Needs Deck, enough creatures but no valid active deck.
- Reward Available, daily trial reward not claimed.

Primary actions:

- "Build Deck"
- "Start Trial"
- "Scan Creature" when locked

### 12.2 Deck Builder Screen

Content:

- Header: "Field Trials"
- Active deck slots: 8.
- Average deck power.
- Type mix strip.
- Validity warning if fewer than 8 cards.
- Collection pool with filters and sort.
- Card detail bottom sheet on tap.

Actions:

- Add card to deck.
- Remove card from deck.
- Auto Build.
- Save Deck.
- Start Trial when valid.

Auto Build rule:

- Pick the 8 highest power creatures.
- Prefer at least 3 different types when possible.
- Prefer at least 1 Earth or Water card when possible for survivability.

### 12.3 Trial Setup Screen

Content:

- Selected difficulty.
- Anomaly type and weakness.
- Recommended deck power.
- Active deck summary.
- Reward preview.

Actions:

- Start Trial.
- Edit Deck.
- Change Difficulty.

### 12.4 Battle Screen

Layout:

- Top: anomaly name, HP bar, shield, next intent.
- Middle: played-card lane and battle log.
- Bottom: player resolve, focus, hand of 3 cards.
- Primary action: End Turn.
- Secondary action: Forfeit.

Requirements:

- One-handed mobile play.
- Card text must fit at 390 x 844.
- No tiny body copy below 12 px.
- Clear disabled state when focus is insufficient.

### 12.5 Result Screen

Victory:

- Show "Anomaly Stabilized".
- Show XP gained.
- Show shard recipient.
- CTAs: "Run Another Trial", "Edit Deck", "Return Home".

Defeat:

- Show "Signal Lost".
- Show reason: resolve depleted or turn limit reached.
- Show one improvement hint.
- CTAs: "Edit Deck", "Scan for New Creatures", "Retry".

## 13. Data Requirements

### BattleDeck

```dart
class BattleDeck {
  final String id;
  final String name;
  final List<String> creatureIds;
  final DateTime updatedAt;
  final bool isActive;
}
```

Storage:

- Hive box: `battle_decks`
- MVP supports one active deck.
- Store ids only. Resolve creature data from `allCreaturesProvider`.

### TrialResult

```dart
class TrialResult {
  final String id;
  final String deckId;
  final String difficulty;
  final bool victory;
  final int turnsTaken;
  final int xpGained;
  final String? shardCreatureId;
  final int shardsGained;
  final DateTime completedAt;
}
```

Storage:

- Hive box: `trial_results`
- Keep recent results for profile stats and future achievements.

### BattleState

Battle state should be ephemeral Riverpod state, not persisted in MVP.

Minimum fields:

```dart
class BattleState {
  final List<String> drawPile;
  final List<String> hand;
  final List<String> discardPile;
  final int turn;
  final int focus;
  final int nextTurnFocusBonus;
  final int playerResolve;
  final int playerShield;
  final int anomalyHp;
  final int anomalyShield;
  final String anomalyIntent;
  final List<String> battleLog;
  final bool isFinished;
  final bool victory;
}
```

## 14. Services And Providers

Create:

- `DeckStorage`: load, save, and repair active deck ids.
- `DeckNotifier`: manage deck selection, auto build, validation, and active deck.
- `BattleRules`: pure deterministic combat logic.
- `BattleNotifier`: owns current battle state and delegates calculations to `BattleRules`.
- `TrialResultStorage`: stores completed trials.

Keep `BattleRules` pure so it can be unit tested without Flutter.

## 15. Suggested File Plan

Create:

- `lib/models/battle_deck.dart`
- `lib/models/trial_result.dart`
- `lib/models/battle_state.dart`
- `lib/services/deck_storage.dart`
- `lib/services/trial_result_storage.dart`
- `lib/services/battle_rules.dart`
- `lib/providers/deck_provider.dart`
- `lib/providers/battle_provider.dart`
- `lib/screens/deckbuilder/deck_builder_screen.dart`
- `lib/screens/deckbuilder/trial_setup_screen.dart`
- `lib/screens/deckbuilder/battle_screen.dart`
- `lib/screens/deckbuilder/trial_result_screen.dart`
- `lib/widgets/deckbuilder_widgets.dart`
- `test/services/battle_rules_test.dart`
- `test/providers/deck_provider_test.dart`

Modify:

- `lib/core/router/app_router.dart`: add routes for deckbuilder screens.
- `lib/screens/home/home_screen.dart`: add Field Trials panel.
- `lib/providers/creature_provider.dart`: add `addShardsToCreature(String creatureId, int count)` so battle rewards do not depend on duplicate-scan logic.
- `lib/models/creature.dart`: no required MVP changes unless adding a helper getter for combat display.
- `lib/widgets/creature_lens_widgets.dart`: reuse existing badges, panels, stat visuals, and buttons where possible.
- `lib/main.dart`: open new Hive boxes for decks and trial results.

## 16. Implementation Phases

### Phase 1: Rules Prototype

Deliverable:

- Pure Dart battle rule engine with unit tests.

Tasks:

- Add derived card calculation helpers.
- Add deterministic turn resolution.
- Add tests for cost, damage, shield, type effects, victory, defeat, and reshuffle behavior.

Exit criteria:

- `flutter test test/services/battle_rules_test.dart` passes.
- No UI is required in this phase.

### Phase 2: Deck Data And Storage

Deliverable:

- User can save and load one active deck locally.

Tasks:

- Add `BattleDeck` model.
- Add Hive storage.
- Add Riverpod deck notifier.
- Add auto-build logic.
- Add tests for deck validity, deleted creature repair, and auto-build rules.

Exit criteria:

- Deck state survives app restart.
- Invalid creature ids are removed from deck.

### Phase 3: Deck Builder UI

Deliverable:

- User can build and save an 8-card deck from their collection.

Tasks:

- Build deck slots.
- Build collection pool.
- Add filters and sorting.
- Add card detail sheet.
- Add locked state for users with fewer than 5 creatures.

Exit criteria:

- A user with at least 8 creatures can create a valid deck.
- A user with 5 to 7 creatures sees why the deck is not yet valid.
- A user with fewer than 5 creatures is guided back to scanning.

### Phase 4: Battle UI

Deliverable:

- User can complete a Calm Field Trial end to end.

Tasks:

- Add Trial Setup screen.
- Add Battle screen.
- Add Result screen.
- Connect battle actions to `BattleNotifier`.
- Add battle log and disabled card states.

Exit criteria:

- User can win or lose.
- Result screen displays correct XP and shard preview.
- Battle can be replayed with the same active deck.

### Phase 5: Rewards And Progression

Deliverable:

- Trial results affect existing progression.

Tasks:

- Add XP reward on victory.
- Add shard reward to one active deck creature.
- Store `TrialResult`.
- Add profile stat for completed trials.
- Add Home panel state for "Ready", "Needs Deck", and "Locked".

Exit criteria:

- Victory modifies user XP.
- Victory modifies one creature's shards.
- Trial history persists locally.

### Phase 6: Polish And Balance

Deliverable:

- MVP feels shippable and readable.

Tasks:

- Tune difficulty HP and attack values.
- Add haptic feedback for play card, victory, and defeat.
- Add accessible contrast checks on battle cards.
- Add reduced-motion behavior for card play animations.
- Add empty, loading, and error states.

Exit criteria:

- Calm trials are easy for fresh decks.
- Wild trials require a sensible deck.
- Text and controls remain readable on 360 x 800.

## 17. Testing Requirements

Unit tests:

- Card cost derivation.
- Damage derivation.
- Shield derivation.
- Each type effect.
- Turn flow.
- Reshuffle flow.
- Victory condition.
- Defeat by resolve.
- Defeat by turn limit.
- Auto-build deck selection.
- Deck repair after creature deletion.

Widget tests:

- Deck Builder locked state.
- Deck Builder valid deck state.
- Battle screen disables unaffordable cards.
- Result screen shows victory rewards.
- Result screen shows defeat hint.

Manual QA:

- New user with 0 creatures.
- User with 4 creatures.
- User with 5 creatures.
- User with 8+ creatures.
- App restart after saving deck.
- App restart after completing trial.
- Small Android viewport 360 x 800.
- Large phone viewport 430 x 932.

## 18. Balance Guidelines

Early tuning target:

- Calm trial win rate: 80 percent for valid early decks.
- Wild trial win rate: 45 to 60 percent for mixed decks.
- Average Calm duration: 2 to 3 minutes.
- Average Wild duration: 3 to 5 minutes.

Balance should favor clarity over depth:

- Small numbers.
- Obvious enemy intent.
- Clear reason why a card cannot be played.
- Clear hint after losing.

## 19. UX Copy

Locked:

- "Awaken 5 creatures to begin Field Trials."
- "Your deck needs field data before it can stabilize anomalies."

Deck Builder:

- "Build an 8-creature research deck."
- "Average Power"
- "Type Mix"
- "Auto Build"
- "Start Trial"

Battle:

- "Focus"
- "Resolve"
- "Next Intent"
- "End Turn"
- "Signal Distortion"

Victory:

- "Anomaly Stabilized"
- "Field data secured."

Defeat:

- "Signal Lost"
- "The anomaly slipped beyond scanner range."

## 20. Acceptance Criteria

MVP is complete when:

- Users with fewer than 5 creatures see a locked Field Trials entry and scan CTA.
- Users with enough creatures can create and save one active 8-card deck.
- Each card is derived from an existing collected creature.
- A user can start and finish a Calm Field Trial.
- Battle rules are deterministic and covered by unit tests.
- Victory grants XP and Evolution Shards.
- Defeat gives a clear reason and a useful hint.
- Trial results persist locally.
- The feature does not rename or disrupt the existing scan, reveal, Field Journal, profile, and settings flows.

## 21. Future Expansion Ideas

Only consider these after MVP:

- Multiple saved decks.
- Elemental anomaly weaknesses generated from scan labels.
- Weekly boss anomalies.
- Creature card upgrades using Evolution Shards.
- Achievement set for Field Trials.
- More anomaly intent patterns.
- Optional Gemini-generated anomaly names and lore.
- Starter tutorial trial.
- Cosmetic card frames by rarity.

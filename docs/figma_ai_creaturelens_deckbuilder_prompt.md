# CreatureLens Field Trials Deckbuilder UI/UX Figma AI Prompt

Project: CreatureLens
Feature: Field Trials deckbuilder game mode
Platform target: Flutter mobile app, portrait-first Android/iOS

## Project Context

CreatureLens is a gamified AI creature discovery app. Users scan real-world objects, the app detects labels, Gemini generates fantasy creatures, and users collect those creatures in a Field Journal.

Field Trials is a lightweight deckbuilder companion mode. It should make collected creatures useful after discovery without replacing the scan-first identity of the app. Users build an 8-creature research deck, enter a short solo battle against a scanner anomaly, play creature cards using Focus, protect their Resolve, and earn XP plus Evolution Shards.

The deckbuilder should feel like a tactical extension of the scanner fantasy:

- The scanner has found unstable anomaly signals.
- Collected creatures become research cards.
- A deck is a field kit used to stabilize anomalies.
- Battles are short, readable, and mobile-first.
- Rewards send users back into scanning and collecting.

## Current Implementation Understanding

The Flutter app already includes:

- Dark-first CreatureLens theme.
- Home dashboard.
- Full-screen scan.
- Creature reveal.
- Field Journal / collection screen, though some current code may still use legacy collection naming.
- Creature detail.
- Profile.
- Settings.
- Field Trials MVP implementation with:
  - Home Field Trials panel.
  - Deck Builder screen.
  - Trial Setup screen.
  - Battle screen.
  - Trial Result screen.
  - Local Hive storage.
  - Riverpod state.
  - GoRouter routes.

Existing visual components:

- Glass panels.
- Lens mark.
- Creature portrait art slot.
- Type badges.
- Rarity badges.
- XP strip.
- Stat bars.
- Filter pills.
- Pressable scale buttons.
- Bottom navigation with centered scan action.

The Figma redesign should mature these surfaces, not discard them.

## Complete Prompt For Figma AI

Copy the full prompt below into Figma AI.

```text
Design a production-ready mobile UI/UX screen set for "CreatureLens: Field Trials", a simple deckbuilder game mode inside the CreatureLens Flutter app.

PRODUCT CONTEXT
CreatureLens is a gamified AI creature discovery app. Users scan real-world objects with their camera, object labels are detected, Gemini generates fantasy creatures from those labels, and users collect creatures in a Field Journal.

Field Trials is a lightweight deckbuilder companion mode:
- Users build one active 8-creature research deck from creatures they have collected.
- Each collected creature becomes a card using existing creature data: type, rarity, power, damage, shield, Focus cost, speed tier, and type effect.
- Users enter short solo battles against scanner anomalies.
- The battle resource is Focus.
- Player health is Resolve.
- Winning gives XP and Evolution Shards.
- Losing gives a practical improvement hint and sends users back to editing the deck or scanning for stronger creatures.

The deckbuilder must support the main CreatureLens loop:
Scan -> Awaken Creature -> Add to Field Journal -> Build Deck -> Field Trial -> Rewards -> Scan Again.

The scan action should remain the app's primary identity. Field Trials is a companion game mode, not a full replacement for scanning or collection.

FEATURE NAME
Use "Field Trials" as the deckbuilder mode name.

Do not use Pokemon branding, card-pack language, casino language, or trading-card monetization language.

STYLE DIRECTION
Use the existing CreatureLens identity: Arcane Field Research Kit.

The Field Trials UI should feel like:
- A tactical scanner interface.
- A magical research deck laid out on a field instrument.
- A compact mobile JRPG-inspired command screen.
- A living field journal crossed with a battle terminal.

Mood:
- Strategic but approachable.
- Dark-first, high contrast, readable outdoors.
- Magical science, not generic fantasy card game.
- Premium mobile game utility, not a landing page.
- Kinetic and dramatic, but not visually chaotic.

Use ATLUS games such as Persona, Shin Megami Tensei, and Metaphor only as broad mood references: confident graphic composition, sharp hierarchy, mythic atmosphere, bold labels, kinetic panels. Do not copy exact ATLUS menus, layouts, fonts, logos, characters, icon sets, colors, demons, personas, or battle screens.

CreatureLens ownership must be clear:
- Camera-first discovery.
- AI creature synthesis.
- Field research.
- Scanner anomaly stabilization.
- Creature cards born from real collected creatures.

ATLUS-INSPIRED UI/UX PRINCIPLES FOR FIELD TRIALS
Field Trials should have a stronger ATLUS-inspired UI/UX energy than the calmer Field Journal screens, while staying original to CreatureLens.

Use these broad principles:
- Persona-like energy: bold graphic confidence, asymmetrical panel rhythm, oversized labels, expressive transitions, everyday objects becoming supernatural tactical tools.
- Shin Megami Tensei-like energy: occult-tech scanner atmosphere, anomaly threat language, elemental taxonomy, ritual-like battle status, dark mythic tension.
- Metaphor-like energy: heroic expedition tone, ornate field-note details, ceremonial reward stamps, fantasy research hierarchy.

Translate those references into original CreatureLens UI:
- Deck Builder: angular deck slots, bold "FIELD TRIALS" title treatment, sharp selected-card states, energetic type-mix strip, quick tactical readability.
- Trial Setup: scanner briefing composition with dramatic difficulty cards, anomaly signal diagram, bold recommended-power comparison, ceremonial reward preview.
- Battle Screen: high-contrast command UI, large Focus and Resolve numbers, visible Next Intent label, hand cards that feel fast and punchy, diagonal motion cues when cards are played.
- Result Screens: explosive but controlled "ANOMALY STABILIZED" or "SIGNAL LOST" typography, reward chips entering like stamped research approvals.

Important boundary:
- Do not recreate any actual ATLUS screen, battle menu, calendar/menu composition, typography, demon/persona silhouette, logo, icon set, or exact color palette.
- Do not use red-black-white Persona imitation as the main identity. Keep Scanner Cyan, Scanner Teal, Reward Gold, Violet, and elemental colors as CreatureLens ownership.
- The result should feel like CreatureLens learned from kinetic JRPG UI principles, not like an ATLUS fan mockup.

VISUAL LANGUAGE
Use:
- Dark atmospheric base with subtle scanner grid, field marks, lens rings, and soft depth.
- Angular panels for tactical mode surfaces.
- Calm card surfaces for readable deck contents.
- Rarity glow for important cards and rewards.
- Elemental color accents for creature type.
- Small, crisp icons for Focus, Resolve, Damage, Shield, Draw, Burn, Mend, Guard, Spark, Grow, Weaken.
- Thick readable labels, not tiny decorative text.
- High-contrast status pills for Next Intent, Focus, Resolve, Turn, Deck Count, Recommended Power.
- Card stacks, deck slots, and hand cards that feel tactile and game-ready.
- ATLUS-inspired kinetic composition: diagonal separators, offset labels, layered cutout panels, bold command strips, dramatic but readable screen titles.
- Strategic asymmetry: make the main action and current state visually dominant instead of arranging everything as equal generic cards.
- Battle typography as interface: Focus, Resolve, HP, Turn, and Next Intent should read instantly as active game state.

Avoid:
- Generic neon dashboard look.
- Casino/tabletop poker visual language.
- Card-pack monetization cues.
- Overly complex 3D card effects.
- Tiny illegible card text.
- Excessive decorative clutter in the battle screen.
- UI cards nested inside too many other cards.

COLOR SYSTEM
Use CreatureLens colors as the base:
- Void Black: #05070D
- Midnight: #071119
- Charcoal: #101923
- Obsidian: #12131C
- Surface: #14202A
- Surface High: #1A2A35
- Pearl: #F3F7EF
- Pearl Muted: #B8C7C3
- Text Dim: #7F918E
- Scanner Cyan: #36F5E5
- Scanner Teal: #00CBBF
- Scanner Deep: #0D817F
- Reward Gold: #FFC857
- Amber: #FFA947
- Ember: #FF6B4A
- Violet: #7B61FF

Field Trials accents:
- Focus: Scanner Cyan
- Resolve: Nature Green
- Damage: Ember / Fire
- Shield: Water Blue / Scanner Cyan
- Anomaly: Violet + Ember
- Victory: Reward Gold
- Defeat / Signal Lost: Ember

Element colors:
- Fire: #FF5F4A
- Water: #3BA7FF
- Earth: #B8895B
- Air: #9DD8FF
- Electric: #FFE15A
- Nature: #43D17A
- Shadow: #8B6CFF
- Light: #FFF5D6

Rarity colors:
- Common: #8FA09B
- Uncommon: #43D17A
- Rare: #3BA7FF
- Epic: #B567FF
- Legendary: #FFC857

Also create light theme direction:
- Background: #F5F7F1
- Card: #FFFFFF
- Text: #142027
- Secondary text: #5F6F6B
- Light Field Trials should feel like daylight expedition gear: parchment, ink, instrument labels, blue shadows, red annotation marks, and gold reward stamps.

TYPOGRAPHY
Use Inter or a close modern sans-serif.

Create text styles:
- Display: Field Trials title, Victory/Defeat result.
- H1: screen title.
- H2: panel titles.
- Body: readable rules, hints, logs.
- Label: status pills, card tags, filters.
- Numeric: Focus, Resolve, power, damage, shield, turn count.

Typography rules:
- Minimum body text 13-14 px.
- Card microcopy minimum 11-12 px.
- Keep letter spacing at 0.
- Use large numbers for Focus, Resolve, anomaly HP, recommended power.
- Card names can be bold and compact, but effects must remain readable.
- Do not angle body copy.

FRAME TARGETS
Design for:
- Primary frame: 390 x 844
- Compact Android: 360 x 800
- Large phone: 430 x 932
- Portrait only

Make every screen usable with one hand. Tap targets must be at least 44 x 44.

CORE GAME RULES TO REFLECT IN UI
Deck:
- Active deck has 8 creature cards.
- Field Trials unlock after 5 collected creatures.
- Starting a trial requires exactly 8 cards.
- Each collected creature can appear once.
- Duplicates are represented as Evolution Shards, not duplicate cards.

Card fields:
- Creature art slot.
- Name.
- Type badge.
- Rarity badge.
- Power.
- Focus cost.
- Damage.
- Shield.
- Speed tier: Slow, Normal, Quick.
- Type effect.

Type effects:
- Fire / Burn: Deal 1 extra end-turn damage.
- Water / Mend: Restore 1 Resolve.
- Earth / Guard: Gain extra Shield.
- Air / Draft: Draw 1 card.
- Electric / Spark: Pierce 1 damage.
- Nature / Grow: Next card +1 damage.
- Shadow / Weaken: Next anomaly attack -1.
- Light / Focus: Gain +1 Focus next turn.

Battle:
- Start each turn with 3 Focus.
- Player starts with 20 Resolve.
- Hand has 3 cards.
- Player plays any number of affordable cards.
- Anomaly shows its next intent before the player ends turn.
- Turn limit is 7 turns.
- Victory: anomaly HP reaches 0.
- Defeat: Resolve reaches 0 or signal is lost after turn 7.

Difficulties:
- Calm: 24 HP, 3 Attack, recommended 45 deck power, 20 XP, 1 shard.
- Wild: 36 HP, 5 Attack, recommended 60 deck power, 40 XP, 2 shards.
- Mythic: 52 HP, 7 Attack, recommended 75 deck power, 70 XP, 3 shards. Can be shown as premium/locked or high difficulty.

SCREENS TO DESIGN

1. Home Field Trials Panel
Create a home dashboard module that introduces Field Trials without competing with the main Scan CTA.

States:
- Locked: fewer than 5 creatures.
- Needs Deck: enough creatures but no valid 8-card deck.
- Ready: valid deck exists.
- Reward Available: optional daily trial reward state.

Content:
- Title: "Field Trials"
- Locked copy: "Awaken 5 creatures to begin Field Trials."
- Needs Deck copy: "Build an 8-creature research deck."
- Ready copy: "An anomaly signal is stable."
- Progress: "3/5 awakened" or "6/8 deck"
- Average deck power if available.
- CTA: "Scan Creature", "Build Deck", or "Start Trial"

Design notes:
- Secondary panel, not bottom nav.
- Use Violet + Scanner Cyan accent.
- It should feel intriguing but scan remains primary.

2. Deck Builder Screen
Design the main deck construction screen.

Content:
- Header: "Field Trials"
- Subtitle: "Build an 8-creature research deck."
- Active deck slots: 8 visible slots.
- Slot states: empty, filled, selected/removable.
- Average deck power.
- Type mix strip.
- Validity warning if fewer than 8 cards.
- Collection pool list/grid of eligible creatures.
- Filters: Type, Rarity.
- Sort: Power, Name, Newest.
- Buttons: Auto Build, Save Deck, Start Trial.

Creature card row/grid content:
- Creature portrait.
- Name.
- Type badge.
- Rarity marker.
- Focus cost.
- Damage.
- Shield.
- Effect summary.
- Power.
- Selected state: "IN DECK" or clear selected visual.
- Disabled state if deck is full.

UX requirements:
- Adding/removing cards must be obvious.
- Avoid tiny CCG-style text walls.
- Show why Start Trial is disabled.
- Auto Build should look helpful, not magical or random.
- Long creature names truncate gracefully.
- A card detail bottom sheet should show full stats and effect text.

3. Card Detail Bottom Sheet
Design a bottom sheet shown when tapping a creature card.

Content:
- Creature portrait.
- Name.
- Type and rarity.
- Power, Focus cost, Damage, Shield, Speed tier.
- Type effect explanation.
- Original creature ability/lore preview as flavor only.
- Buttons: Add to Deck / Remove from Deck.

Design notes:
- This is tactical information, not a full creature detail page.
- Use clean stat rows and one clear primary action.

4. Trial Setup Screen
Design the pre-battle setup screen.

Content:
- Title: "Trial Setup"
- Anomaly visual: scanner lens / unstable signal / abstract anomaly core.
- Difficulty selector: Calm, Wild, Mythic.
- Anomaly HP.
- Anomaly Attack.
- Recommended Deck Power.
- Reward preview: XP and Evolution Shards.
- Active deck summary: card count, average power, type mix.
- Readiness hint:
  - "Deck power is above the recommended signal threshold."
  - "Average deck power is below recommended. Earth and Water cards can help survival."
- CTAs: Start Trial, Edit Deck.

Design notes:
- Should feel like a scanner briefing.
- Make difficulty comparison clear at a glance.
- Mythic should feel dangerous but not visually overwhelming.

5. Battle Screen
Design the core Field Trial battle UI.

Layout:
- Top: close/forfeit, screen title, turn counter.
- Anomaly panel:
  - Anomaly name: "Scanner Anomaly"
  - HP bar.
  - Shield if active.
  - Next Intent pill with icon: Attack, Guard, Distort.
- Player status:
  - Resolve bar.
  - Focus counter.
  - Shield counter if active.
- Center:
  - Battle log or played-card lane.
  - Keep this compact and readable.
- Bottom:
  - Hand of 3 cards horizontally scrollable if needed.
  - End Turn button.

Card-in-hand design:
- 3 cards visible or nearly visible on 390 x 844.
- Card width around 120-140 px.
- Each card must show:
  - Focus cost.
  - Type icon.
  - Creature name.
  - Effect summary.
  - Damage.
  - Shield.
- Disabled state when Focus is insufficient.
- Pressed/playable state with glow.

Battle UX requirements:
- The user must always know:
  - How much Focus remains.
  - Which cards can be played.
  - What the anomaly will do next.
  - Current Resolve.
  - Current anomaly HP.
- Avoid covering the screen with animation.
- Use small motion notes: card compresses, slides upward, damage number pops, log updates.
- Make "End Turn" easy to reach.
- Include Forfeit as a safe secondary action, not a scary primary action.

6. Victory Result Screen
Design the success result screen.

Content:
- Header: "Anomaly Stabilized"
- Copy: "Field data secured."
- Rewards:
  - XP gained.
  - Evolution Shards gained.
  - Shard recipient creature card.
  - Turns taken.
- CTAs:
  - Run Another Trial.
  - Edit Deck.
  - Return Home.

Design notes:
- Reward Gold and rarity glow.
- Celebrate, but keep it shorter than creature reveal.
- This is a repeatable mode, so do not make the result screen too slow.

7. Defeat Result Screen
Design the failure result screen.

Content:
- Header: "Signal Lost"
- Copy: "The anomaly slipped beyond scanner range."
- Show reason:
  - Resolve depleted.
  - Turn limit reached.
- Practical hint:
  - "Try more Earth cards for shield."
  - "Add higher-power Fire or Electric cards for faster stabilization."
  - "Water cards can restore Resolve."
- CTAs:
  - Edit Deck.
  - Scan for New Creatures.
  - Retry.

Design notes:
- Defeat should feel informative, not punishing.
- Use Ember and Violet, not a harsh red failure wall.

8. Empty / Locked / Error States
Create companion frames:
- Field Trials locked: fewer than 5 creatures.
- Deck Builder unlocked but not enough creatures for 8-card deck.
- Empty filtered collection.
- Deck invalid because a creature was removed.
- Battle missing state: no active trial signal.
- Trial result loading state.

9. Profile Field Trials Stat
Add a small Profile stat module:
- Field Trials completed.
- Trial wins.
- Best difficulty cleared.
- Favorite deck type mix.

Keep this secondary to the existing Profile progression.

DESIGN SYSTEM COMPONENTS TO CREATE
Create reusable components with variants and clear names:

Navigation / entry:
- FieldTrials/HomePanel
- FieldTrials/LockedPanel
- FieldTrials/StatusChip

Deck builder:
- Deck/Slot
- Deck/SlotEmpty
- Deck/SlotFilled
- Deck/TypeMixStrip
- Deck/PowerSummary
- Deck/ValidityHint
- Deck/AutoBuildButton

Cards:
- TrialCard/ListRow
- TrialCard/GridCard
- TrialCard/HandCard
- TrialCard/DetailSheet
- TrialCard/SelectedState
- TrialCard/DisabledState

Battle:
- Battle/AnomalyPanel
- Battle/IntentPill
- Battle/HealthBar
- Battle/ResolveBar
- Battle/FocusCounter
- Battle/BattleLog
- Battle/EndTurnButton

Results:
- Result/VictoryPanel
- Result/DefeatPanel
- Reward/XPChip
- Reward/ShardChip
- Reward/ShardRecipient

Shared:
- Badge/Type
- Badge/Rarity
- Stat/Power
- Stat/Damage
- Stat/Shield
- Stat/SpeedTier
- Filter/TypeChip
- Filter/RarityChip
- Sort/Menu

INTERACTION FLOW
Prototype these connections:
- Home Field Trials Panel locked -> Scan Screen.
- Home Field Trials Panel needs deck -> Deck Builder.
- Home Field Trials Panel ready -> Trial Setup.
- Deck Builder Auto Build updates deck slots.
- Deck Builder Start Trial -> Trial Setup.
- Trial Setup Edit Deck -> Deck Builder.
- Trial Setup Start Trial -> Battle.
- Battle playable card tap -> card played visual state.
- Battle End Turn -> next turn state.
- Battle victory -> Victory Result.
- Battle defeat -> Defeat Result.
- Result Run Another Trial -> Trial Setup.
- Result Edit Deck -> Deck Builder.
- Result Return Home -> Home.

MOTION NOTES FOR FLUTTER IMPLEMENTATION
Annotate motion intent:
- Deck slot fill: card scales from 0.92 to 1.0, 160 ms.
- Card remove: fade + slide downward, 140 ms.
- Auto Build: slots fill in a quick stagger, 60 ms per slot.
- Difficulty change: anomaly stats crossfade, 180 ms.
- Card play: card compresses, lifts upward, fades into played lane, 180-240 ms.
- Damage number: small pop near anomaly HP, 220 ms.
- Focus counter updates with quick scale pulse.
- End Turn: anomaly intent executes with short panel shake/glow.
- Victory: lens ring closes and reward chips pop in.
- Defeat: scanner signal distorts, then settles to readable result.
- Respect reduced motion: replace movement with fades and static glows.

ACCESSIBILITY AND PRODUCTION CONSTRAINTS
- Touch targets minimum 44 x 44.
- Maintain strong contrast on dark and light themes.
- Do not rely on color alone for type, rarity, or card effects.
- Pair colors with labels/icons.
- Card text must remain readable at 360 x 800.
- Avoid text over creature art unless backed by a solid/scrim panel.
- Long creature names must truncate gracefully.
- Battle screen must not require precise tiny taps.
- Keep card effects deterministic and clearly labeled.
- Avoid overly complex visuals that are hard to implement in Flutter.
- Use components compatible with Flutter Material-style implementation.
- Use icon concepts close to Material Symbols / Flutter Icons.
- The design should be responsive across 390 x 844, 360 x 800, and 430 x 932.

FIGMA OUTPUT REQUIREMENTS
Create:
- A cover frame: "CreatureLens Field Trials"
- A "Field Trials Design System" page with colors, type, components, and variants.
- A "Deck Builder Flow" page.
- A "Battle Flow" page.
- A "States" page.

Frames to include:
- Home Field Trials Locked
- Home Field Trials Needs Deck
- Home Field Trials Ready
- Deck Builder Empty/Partial Deck
- Deck Builder Valid Deck
- Card Detail Bottom Sheet
- Trial Setup Calm
- Trial Setup Wild
- Trial Setup Mythic
- Battle Turn Start
- Battle Card Selected
- Battle Insufficient Focus
- Battle Anomaly Guard Intent
- Victory Result
- Defeat Result
- Locked: Fewer Than 5 Creatures
- Not Enough Cards: 5-7 Creatures
- Empty Filtered Collection

QUALITY BAR
The final design should feel:
- App-store ready.
- Clearly part of CreatureLens.
- Tactical but simple.
- More like an arcane research tool than a generic card battler.
- Easy to implement in Flutter.
- Readable on small phones.
- Fun without obscuring the rules.
- Strong enough to guide the next visual redesign of the implemented Field Trials screens.
```

## Notes For Designer

Field Trials should create a distinct third mode next to Scanner and Field Journal:

- Scanner mode: live, precise, camera-first.
- Field Journal mode: collectible, readable, specimen-focused.
- Field Trials mode: tactical, compact, anomaly-stabilizing, repeatable.

The best design opportunity is to make the deck feel like a research instrument, not a standard trading-card collection. The cards should inherit creature identity, but the battle UI should prioritize readability: Focus, Resolve, anomaly HP, Next Intent, and playable cards must be clear at a glance.

## Self-Review

- Prompt is scoped to CreatureLens Field Trials deckbuilder UI/UX.
- Prompt includes game rules, screens, states, components, interactions, motion, accessibility, and Figma output requirements.
- Prompt avoids Pokemon branding, card-pack monetization, and direct ATLUS copying.
- Prompt aligns with the implemented Flutter MVP and existing CreatureLens design language.

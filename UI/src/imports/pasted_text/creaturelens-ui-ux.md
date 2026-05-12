# CreatureLens UI/UX Analysis and Figma AI Prompt

Project: CreatureLens
Platform target: Flutter mobile app, portrait-first Android/iOS

## Project Understanding

CreatureLens is a gamified AI-powered mobile app where users scan real-world objects with the camera, the app detects labels, Gemini generates a fantasy creature from those labels, and the user collects that creature in a field-journal style collection. The current code already has the core loop and screen map:

- Splash
- Home dashboard
- Full-screen scan experience
- AI creature reveal
- Collection screen currently named Pokedex
- Creature detail
- Profile with XP, streaks, achievements
- Settings

The product is strongest when it feels like a magical scientific instrument: users are not just taking photos, they are "awakening" hidden creatures inside ordinary objects. The UI should make the scanner feel trustworthy and the reveal feel emotional.

## Current UI Direction Observed From Code

Existing design language:

- Dark-first app with a sci-fi scanner palette.
- Primary colors: void black, midnight, cyan, teal, reward gold, amber, elemental accent colors.
- Reusable components: glass panels, lens mark, scanner frame, type badges, rarity badges, creature portrait, XP strip, stat bars, filter pills, bottom nav with centered scan action.
- Typography target: Inter.
- Interaction style: pressable scale, animated scanner, reveal animation, hero transitions.

Strengths:

- The core gameplay loop is clear and production-worthy.
- The scan and reveal moments already have a distinct emotional arc.
- Gamification layers are visible: XP, streaks, missions, shards, achievements.
- The app already has a coherent dark visual foundation.

Risks and gaps to solve in design:

- Avoid becoming a generic neon-card dashboard. Add a stronger product metaphor.
- Avoid direct Pokemon-like branding. Use "Field Journal", "Bestiary", or "Collection" instead of "Pokedex" in production UI.
- The app needs onboarding and privacy trust for camera and AI usage.
- Camera scanning UI must be readable without covering the real-world subject.
- Creature art placeholders should be replaced with a scalable illustration system or image slot pattern.
- Filters and collection browsing need stronger hierarchy for repeated daily use.
- Empty, loading, duplicate, offline, API failure, camera denied, and low-confidence states need designed surfaces.
- Light mode exists in code but needs a distinct "daylight expedition" treatment, not a washed-out dark theme.

## Recommended Product Design Direction

Use the concept "Arcane Field Research Kit" with high-contrast modern JRPG menu energy inspired by ATLUS games such as Persona, Shin Megami Tensei, and Metaphor. Treat those games as mood references only: borrow broad principles like kinetic composition, dramatic typography, layered UI, and mythic atmosphere, but do not copy their exact layouts, logos, fonts, characters, icons, menus, or color schemes.

Blend three visual ideas:

1. A precision field scanner: camera UI, detection brackets, confidence tags, live status, scanning pulse.
2. A living field journal: collected creatures, paper-like detail hierarchy, specimen metadata, discovery log.
3. A fantasy reward moment: rarity glow, elemental effects, reveal animation, collectible identity.
4. A kinetic JRPG interface: angled panels, sharp typography, oversized labels, high-contrast overlays, quick motion cues, and energetic visual hierarchy.

The design should feel premium, playful, and shippable. It should not feel like a landing page, social media app, or generic game clone. It should be a usable tool first, with a magical layer on top.

Recommended UX priorities:

- Make the scan action always obvious.
- Keep the core loop short: Home -> Scan -> Reveal -> Add to Collection -> Detail or Scan Again.
- Build trust before camera access with clear privacy microcopy.
- Make AI generation feel like a process: detecting, locking, synthesizing, revealing.
- Make collection browsing efficient with filters, sort, grid/list toggle, and clear card metadata.
- Make progression motivating without overwhelming the scan loop.

## Complete Prompt For Figma AI

Copy the full prompt below into Figma AI.

```text
Design a production-ready mobile app UI for "CreatureLens", a gamified AI creature discovery app built in Flutter.

PRODUCT CONTEXT
CreatureLens lets users scan real-world objects with their phone camera. On-device image labeling detects objects such as "ceramic mug", "plant leaf", or "glasses". Gemini then generates a unique fantasy creature inspired by the scanned object. Users reveal the creature, add it to their collection, earn XP, maintain streaks, complete daily missions, collect achievements, and use duplicate scans as Evolution Shards.

The product should feel like an "Arcane Field Research Kit" with modern high-contrast JRPG menu energy: part precision field scanner, part living creature journal, part fantasy reward system, part kinetic supernatural interface. It should feel premium, distinct, playful, and viable for production. Avoid looking like a generic neon dashboard or a Pokemon clone.

STYLE REFERENCE BOUNDARY
Use ATLUS games such as Persona, Shin Megami Tensei, and Metaphor only as broad mood and interaction references. Do not copy or recreate any specific ATLUS UI, logo, font, character, demon/persona design, menu layout, battle UI, calendar UI, icon set, or exact palette.

Translate the reference into an original CreatureLens identity:
- Persona-like energy: bold graphic confidence, asymmetry, expressive type, everyday objects becoming supernatural.
- Shin Megami Tensei-like energy: occult scanner language, mythic creature taxonomy, dark ritual-tech atmosphere.
- Metaphor-like energy: ornate fantasy field notes, heroic expedition tone, parchment-and-ink details in the journal.
- CreatureLens ownership: camera-first discovery, AI synthesis, field research, collectible creatures born from real-world objects.

IMPORTANT BRANDING NOTE
Do not use Pokemon branding or visual imitation. Avoid the word "Pokedex" in final UI copy. Use "Field Journal", "Bestiary", or "Collection" instead. The current app code uses Pokedex as a working name, but production design should use "Field Journal".

TARGET PLATFORM AND FRAME SIZE
Create a mobile-first design system and screen set for:
- Primary frame: 390 x 844
- Also account for compact Android: 360 x 800
- Also account for large phone: 430 x 932
- Portrait orientation only
- Flutter implementation with Material-style components and custom painted scanner/creature surfaces

VISUAL DIRECTION
Design style: premium mobile game utility, dark-first, magical science, field research instrument, with kinetic ATLUS-inspired JRPG interface principles adapted into an original brand.

Core mood:
- Mysterious but friendly
- Sophisticated, not childish
- Exploratory, collectible, rewarding
- High contrast and readable outdoors
- A little whimsical in creature moments, but practical in navigation and browsing

Visual ingredients:
- Dark atmospheric base with subtle field-grid, scanning marks, lens rings, and soft depth.
- Sharp diagonal panels, asymmetric layouts, bold sticker-like labels, offset frames, energetic shadows, and layered foreground/background UI.
- Glass-like panels only where useful. Prefer angular layered panels for major navigation and reveal moments; use calmer panels for readable journal content.
- Tactile journal details in collection/detail screens: specimen labels, discovery metadata, field notes.
- Elemental accent colors for creature type.
- Rarity glow for reward moments.
- Real camera preview area on scan screen, with overlays that do not block the object.
- Creature art slots should support generated images or illustrated creatures. Use charming abstract creature illustrations as placeholders, not flat generic icons.
- Use graphic speed lines, scan slashes, rune-like measurement marks, and high-contrast cutout shapes sparingly to create energy without hurting readability.
- Avoid direct imitation of ATLUS menus. The result should feel inspired by high-energy JRPG UI, but unmistakably CreatureLens.

COMPOSITION LANGUAGE
- Use diagonal section breaks, skewed cards, overlapping labels, and oversized numbers for rank, power, rarity, and confidence.
- Let typography act as interface: screen titles can become bold graphic objects, but body copy must stay readable.
- Use negative space deliberately. Energetic does not mean cluttered.
- Give each mode a different rhythm:
  - Home: confident mission hub, energetic but scan-focused.
  - Scan: ritual-tech scanner, dark, precise, intense.
  - Reveal: explosive rarity moment with dramatic type and layered effects.
  - Field Journal: ornate but calmer, readable, catalog-like.
  - Profile: stylish progress dashboard with bold stats and achievement badges.

COLOR SYSTEM
Use these existing project colors as the base, but refine into Figma color styles and variables:
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

Add an ATLUS-inspired accent layer while keeping CreatureLens original:
- Lacquer Red: use sparingly for urgency, major callouts, locked states, and dramatic reveal accents.
- Bone White: use for cutout labels, bold typography blocks, and high-contrast UI chips.
- Deep Ink Blue: use for supernatural depth and journal headers.
- Mythic Gold: use for rarity, rewards, rank, and ceremonial highlights.
- Keep Scanner Cyan and Scanner Teal as the core product identity so the app does not become a direct Persona/SMT/Metaphor imitation.

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

Also create a light theme direction:
- Background: #F5F7F1
- Card: #FFFFFF
- Text: #142027
- Secondary text: #5F6F6B
- Light theme should feel like daylight expedition gear, not just inverted dark mode.
- Light theme may use parchment, ink, red stamp accents, blue shadows, and gold specimen labels, but must remain clean and readable.

TYPOGRAPHY
Use Inter or a close modern sans-serif.
Create text styles:
- Display: app name and major reveal moments
- H1: screen titles
- H2: section titles
- Body: readable field notes
- Label: badges, tabs, status pills
- Numeric: XP, power, stats, streaks, confidence values

Use strong hierarchy. Keep letter spacing at 0. Avoid tiny unreadable sci-fi text. Minimum body text 13-14 px. Tap targets minimum 44 x 44.

Typography should have two modes:
- Kinetic Display: oversized, bold, editorial, angled/overlapped when used for screen titles, reveal labels, rarity, power, and level-up moments.
- Utility Reading: calm, clean, stable text for lore, settings, scan instructions, stats, and accessibility.

Do not use or imitate proprietary ATLUS fonts. Use available fonts and type treatment to create energy through scale, contrast, placement, and layering.

DESIGN SYSTEM COMPONENTS TO CREATE
Create reusable Figma components with variants, auto layout, constraints, and clear names.

Core navigation:
- Bottom navigation bar with four actions: Home, Scan center action, Field Journal, Profile
- Center Scan action is the primary circular lens button
- Top app bar variants: normal, detail back button, scan overlay controls
- Create an alternate kinetic bottom nav variant with angled selected states and bold active labels, while preserving 44 x 44 tap targets.

Scanner components:
- Lens Mark / scanner logo
- Scanner frame with idle, detecting, target locked, analyzing variants
- Confidence label tag: label, percent, locked/unlocked
- Status pill: DETECTING, TARGET LOCKED, ANALYZING, OFFLINE
- Camera permission card
- Low confidence warning
- Upload from gallery button
- Flash toggle
- Camera switch button
- Angled scan slash overlays, lock-on burst marks, and target brackets that feel ritual-tech rather than generic sci-fi.

Creature components:
- Creature portrait slot with generated art placeholder
- Creature card grid variant
- Creature list row variant
- Type badge variants: Fire, Water, Earth, Air, Electric, Nature, Shadow, Light
- Rarity badge variants: Common, Uncommon, Rare, Epic, Legendary
- Stat bar: HP, Attack, Defense, Speed
- Ability tile
- Lore / field note block
- Evolution Shard chip
- Rarity glow background variants
- Creature art export guidance: 1:1 artwork, transparent or clean radial background options, readable at 128 px, 256 px, and 512 px, no licensed characters, no direct ATLUS demon/persona silhouettes, consistent CreatureLens silhouette language.

Progression components:
- XP progress strip
- Level badge
- Streak badge
- Daily mission row
- Achievement badge locked/unlocked
- Reward toast
- Level up modal

Controls:
- Filter chips
- Sort menu
- Grid/list segmented toggle
- Theme segmented toggle
- Settings switch row
- Primary, reward, ghost, danger buttons
- Empty state panels
- Error and offline banners
- Kinetic modal/dialog style for level-up, duplicate found, achievement unlocked, and rare discovery moments.

SCREENS TO DESIGN
Create a coherent screen set with production detail, not just rough wireframes.

1. Splash Screen
- Centered animated lens mark concept
- App name: CreatureLens
- Tagline: "Scan. Awaken. Collect."
- Loading row examples: "Calibrating scanner", "Indexing field journal", "Charging rarity matrix"
- Premium dark background with subtle scan grid, not a marketing hero page

2. Onboarding / Camera Trust Screen
- Explain the loop in 3 compact steps: Scan an object, AI awakens a creature, build your Field Journal
- Include privacy reassurance: "Live camera is used to detect object labels. AI generation uses those labels to create your creature."
- Primary CTA: "Start Scanning"
- Secondary: "Explore Demo"
- Ask for camera permission visually but do not show OS modal
- Note: onboarding is a new screen to implement; the current Flutter app routes Splash directly to Home.

3. Home Dashboard
- Welcome user: "Welcome back, Mira"
- Primary mission: prominent Scan Creature CTA
- Field Rank / XP progress
- Current streak chip
- Daily Missions card with three missions:
  - Scan 3 objects, 1/3, +30 XP
  - Find a Rare+, 0/1, +50 XP
  - Scan Nature type, 0/1, +25 XP
- Recent Discovery card showing one creature
- Stats summary: Creatures, Rarest, Longest Streak
- Keep home focused. Avoid turning it into a cluttered RPG menu.
- Make the Home screen feel like a stylish mission command screen: large angled "SCAN" visual anchor, bold streak/rank callouts, and sharp mission panels.

4. Scan Screen
- Full-screen camera preview mock, not a card.
- Top controls: close, status pill, camera switch
- Center scanner frame with scan line and corner brackets
- Two confidence labels over subject:
  - "ceramic mug 94%"
  - "plant leaf 88%"
- Bottom status panel:
  - Detecting: "Move slowly until the scanner ring locks."
  - Locked: "Object lock is stable. Capture to awaken it."
  - Analyzing: "Creature synthesis in progress."
- Capture button in center, gallery button left, flash toggle right.
- Must be readable over a real camera image.
- Include a low-confidence state and a no-camera-permission state as smaller companion frames.
- Use occult-tech energy: target brackets, diagonal warning slashes, bold lock-on typography, and subtle rune-like measurement ticks.
- Keep the real object visible. Do not cover the center of the camera with decorative UI.

5. AI Analyzing / Synthesis State
- Transitional screen or overlay after capture.
- Show scanned labels as chips.
- Show progress stages:
  - Reading object signature
  - Mixing elemental traits
  - Writing field lore
  - Preparing reveal
- This state should feel fast and magical, not like a long loading spinner.
- Use a kinetic synthesis interface: stacked labels, diagonal stage cards, rapid progress marks, and a dramatic "SYNTHESIZING" title.

6. Creature Reveal Screen
- Dramatic but usable reveal moment.
- Header: "New Discovery"
- Large creature portrait/art slot with rarity and type glow.
- Example creature:
  - Name: Cupflare Drifter
  - Type: Light
  - Rarity: Epic
  - Power: 79
  - XP: +100
- Badges: Epic, Light
- First visible stats: HP 76, Attack 84, Defense 67, Speed 88
- Ability previews:
  - Porcelain Halo
  - Steam Waltz
- Primary CTA: "Add to Collection"
- Secondary CTAs: "View Details", "Scan Again"
- Include duplicate reveal variant: "Duplicate Found" and "Converted to 3 Evolution Shards"
- Use the strongest ATLUS-inspired energy here: huge angled "NEW DISCOVERY" / rarity typography, layered cutout creature art, explosive but controlled rarity effects, and a clear Add to Collection CTA.

7. Field Journal / Collection Screen
- Title: "Field Journal"
- Subtitle: "Creatures awakened from everyday objects."
- Grid/list toggle
- Filter strips:
  - Type: All, Nature, Fire, Water, Electric, Shadow, Light, Earth, Air
  - Rarity: All, Common, Uncommon, Rare, Epic, Legendary
  - Date: All, Today, 7 Days, 30 Days
- Sort control: Date, Name, Rarity, Power
- Creature grid card content:
  - Creature art
  - Rarity badge
  - Type badge
  - Name
  - Power
  - Shards if present
- Include empty state:
  - "No creatures match this view."
  - CTA: "Scan Creature"
- Include list row variant for repeated browsing.
- This screen should calm down compared with Reveal. Use ornate fantasy-journal structure, clear filters, specimen cards, and readable metadata. Add only light kinetic accents on selected filters and rare cards.

8. Creature Detail Screen
- Premium specimen page, like a living field journal entry.
- Large creature artwork at top.
- Name, Type, Rarity, Evolution Shards.
- Stats block with clear bars.
- Lore block:
  "Cupflare Drifter forms in the last curl of steam above a quiet drink. It guards the small rituals that keep travelers brave."
- Abilities section with ability tiles.
- Scan Info:
  - Object: Ceramic Mug
  - Labels: mug 94%, ceramic 83%, tableware 79%
  - Discovered: May 7, 2026 at 10:24
- Evolution card:
  - "3 Evolution Shards"
  - Disabled CTA: "Need 7 More Shards"
- Share icon in top bar.
- Blend editorial JRPG page layout with field-journal readability: oversized creature name, angled type/rarity stamp, stable lore blocks, and specimen metadata.

9. Profile Screen
- User avatar, name "Mira Vale", title "AI Field Explorer"
- Level badge and XP strip
- Lifetime stats:
  - Total Creatures: 42
  - Rarest Catch: Epic
  - Current Streak: 9 days
  - Longest Streak: 21 days
- Achievements grid locked/unlocked:
  - First Scan
  - Rare Note
  - 7 Day Flame
  - Nature Master
  - Shard Smith
- Legend Hunter locked
- Settings entry point.
- Make stats feel dramatic: oversized level number, angled XP strip, achievement stamps, and bold contrast without losing scan-first product focus.

10. Settings Screen
- Appearance: Dark / Light segmented control
- Notifications:
  - Daily missions
  - Rare alerts
  - Streak reminder
- Account row
- Privacy controls
- Data and camera permissions
- Sync collection
- Return Home button

11. Production State Frames
Create smaller companion frames for:
- Empty collection
- Offline queue: "Scan saved locally. We will synthesize it when you are online."
- Gemini/API failure fallback: "The signal blurred. A Mystery Creature was recorded."
- Camera denied
- Loading skeleton for creature cards
- Level up celebration
- Achievement unlocked toast

INTERACTION AND PROTOTYPE FLOW
Create clickable prototype connections:
Splash -> Onboarding -> Home -> Scan -> Analyzing -> Reveal -> Add to Collection -> Field Journal -> Creature Detail -> Profile -> Settings.

Implementation note: Onboarding is a proposed new flow. Current app behavior can still go Splash -> Home until onboarding is implemented.

Also prototype:
- Scan Again from Reveal back to Scan
- Field Journal card to Creature Detail
- Bottom nav actions
- Filter chip selected state
- Grid/list toggle
- Duplicate reveal modal

MOTION NOTES FOR DESIGN ANNOTATION
Annotate motion intent so developers can implement it in Flutter:
- Scanner line loops vertically, 1.6-1.8 seconds.
- Locked state changes cyan to green/gold and slightly pulses.
- Capture button compresses on tap and morphs into analyzing spinner.
- Reveal creature scales from 0.55 to 1.0 with elastic easing and a rarity glow.
- Detail sections fade/slide in after reveal.
- Bottom navigation scan button emits a subtle glow pulse.
- Kinetic panels should slide on diagonal paths, snap into place, or mask-reveal with quick 160-260 ms transitions.
- Big title labels can enter with offset layering, but body text should not animate in ways that reduce readability.
- Respect reduced motion: use fades and static glows when reduced motion is enabled.

ACCESSIBILITY AND PRODUCTION CONSTRAINTS
- Maintain strong contrast on dark and light themes.
- Do not rely on color alone for type or rarity; pair color with labels/icons.
- Minimum touch target 44 x 44.
- Keep text readable on real camera background using scrims, blur, or solid underlays.
- Avoid text over busy creature art unless backed by a panel.
- Ensure long creature names truncate gracefully.
- Ensure small phones do not clip buttons or bottom nav.
- Keep icons close to Material Symbols / Flutter Icons for easier implementation.
- Avoid highly complex 3D effects that would be hard to ship in Flutter.
- Use auto layout and responsive constraints throughout.
- Energetic JRPG composition must never break usability: no clipped labels, no unreadable angled body copy, no tiny decorative text pretending to be functional UI.
- Do not use ATLUS-owned imagery, characters, demons/personas, logos, typography, or exact menu compositions.

FIGMA OUTPUT REQUIREMENTS
Create:
- A cover frame with the product name and design direction.
- A "Design System" page with color styles, type styles, spacing, components, and component variants.
- A "Core Flow" page with the main user journey.
- A "States" page for error, empty, offline, duplicate, loading, and permission states.
- All frames named clearly.
- All components named with a production-friendly convention:
  - Navigation/BottomBar
  - Scanner/Frame
  - Scanner/ConfidenceTag
  - Creature/CardGrid
  - Creature/CardList
  - Creature/Portrait
  - Badge/Type
  - Badge/Rarity
  - Progress/XPStrip
  - Mission/Row
  - Achievement/Badge
  - Button/Primary
  - Button/Reward
  - Button/Ghost
  - Settings/SwitchRow
- Add short annotation labels for key implementation details.

QUALITY BAR
The final design should feel:
- App-store ready
- Distinct from common AI apps
- Distinct from generic Pokemon-like collectors
- Easy to implement in Flutter
- Strong enough to guide a redesign of the current codebase
- Fun without losing usability
```

## Notes For The Designer

The existing app already has many of the right pieces. The Figma redesign should not discard the current scanner identity; it should mature it. The best opportunity is to create a stronger contrast between:

- Scanner mode: precise, live, technical, camera-first.
- Journal mode: collectible, readable, specimen-focused.
- Reveal mode: cinematic, emotional, reward-heavy.

That separation will make CreatureLens feel more unique and production-ready than a single visual treatment used everywhere.

## Self-Review

- No unresolved placeholders.
- Prompt includes project context, screens, design system, states, interactions, accessibility, and production constraints.
- Prompt avoids copyrighted branding direction and recommends "Field Journal" for production UI.
- Prompt aligns with the current Flutter app structure and existing color/component system.

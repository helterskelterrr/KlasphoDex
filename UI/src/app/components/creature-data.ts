export type Element = "Fire" | "Water" | "Earth" | "Air" | "Electric" | "Nature" | "Shadow" | "Light";
export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary";

export const ELEMENT_COLORS: Record<Element, string> = {
  Fire: "#FF5F4A",
  Water: "#3BA7FF",
  Earth: "#B8895B",
  Air: "#9DD8FF",
  Electric: "#FFE15A",
  Nature: "#43D17A",
  Shadow: "#8B6CFF",
  Light: "#FFF5D6",
};

export const RARITY_COLORS: Record<Rarity, string> = {
  Common: "#8FA09B",
  Uncommon: "#43D17A",
  Rare: "#3BA7FF",
  Epic: "#FFD300",
  Legendary: "#FFD300",
};

export type Creature = {
  id: string;
  name: string;
  element: Element;
  rarity: Rarity;
  power: number;
  hp: number;
  atk: number;
  def: number;
  spd: number;
  shards: number;
  object: string;
  labels: { name: string; conf: number }[];
  discovered: string;
  lore: string;
  abilities: { name: string; desc: string }[];
  hue: string;
};

export const CREATURES: Creature[] = [
  {
    id: "c1",
    name: "Cupflare Drifter",
    element: "Light",
    rarity: "Epic",
    power: 79,
    hp: 76,
    atk: 84,
    def: 67,
    spd: 88,
    shards: 3,
    object: "Ceramic Mug",
    labels: [
      { name: "mug", conf: 94 },
      { name: "ceramic", conf: 83 },
      { name: "tableware", conf: 79 },
    ],
    discovered: "May 7, 2026 · 10:24",
    lore: "Cupflare Drifter forms in the last curl of steam above a quiet drink. It guards the small rituals that keep travelers brave.",
    abilities: [
      { name: "Porcelain Halo", desc: "Sheathes allies in glazed light, reducing incoming damage." },
      { name: "Steam Waltz", desc: "Drifts through opponents, leaving warm afterimages." },
    ],
    hue: "#FFD300",
  },
  {
    id: "c2",
    name: "Mosswick Sprig",
    element: "Nature",
    rarity: "Rare",
    power: 64,
    hp: 88,
    atk: 52,
    def: 74,
    spd: 60,
    shards: 1,
    object: "Plant Leaf",
    labels: [{ name: "leaf", conf: 92 }, { name: "plant", conf: 88 }],
    discovered: "May 6, 2026 · 18:02",
    lore: "Wakes when fingertips brush a houseplant. Hums tiny weather under its breath.",
    abilities: [
      { name: "Chloro Pulse", desc: "Restores HP to all allies on the field." },
      { name: "Root Tap", desc: "Anchors itself, gaining defense each turn." },
    ],
    hue: "#43D17A",
  },
  {
    id: "c3",
    name: "Inkdrop Watcher",
    element: "Shadow",
    rarity: "Uncommon",
    power: 51,
    hp: 60,
    atk: 70,
    def: 48,
    spd: 72,
    shards: 0,
    object: "Pen",
    labels: [{ name: "pen", conf: 90 }, { name: "ink", conf: 71 }],
    discovered: "May 4, 2026 · 09:11",
    lore: "Pools at the tip of any pen left uncapped. Knows every unfinished sentence.",
    abilities: [
      { name: "Cipher Mark", desc: "Marks an enemy; next hit deals bonus damage." },
      { name: "Slipstroke", desc: "Briefly vanishes, dodging one attack." },
    ],
    hue: "#8B6CFF",
  },
  {
    id: "c4",
    name: "Volt Whisker",
    element: "Electric",
    rarity: "Rare",
    power: 68,
    hp: 58,
    atk: 90,
    def: 44,
    spd: 95,
    shards: 2,
    object: "Charging Cable",
    labels: [{ name: "cable", conf: 93 }, { name: "wire", conf: 80 }],
    discovered: "May 3, 2026 · 14:48",
    lore: "Found purring beside power outlets. Will only travel in straight lines.",
    abilities: [
      { name: "Static Lash", desc: "Quick strike with chance to paralyze." },
      { name: "Loop Surge", desc: "Doubles speed for the next two turns." },
    ],
    hue: "#FFE15A",
  },
  {
    id: "c5",
    name: "Pebbleward",
    element: "Earth",
    rarity: "Common",
    power: 42,
    hp: 100,
    atk: 40,
    def: 92,
    spd: 22,
    shards: 4,
    object: "Stone",
    labels: [{ name: "stone", conf: 86 }],
    discovered: "May 2, 2026 · 12:30",
    lore: "Stoic, dependable. Never forgets the path home.",
    abilities: [
      { name: "Bulwark", desc: "Hardens, doubling defense for one turn." },
      { name: "Slow Roll", desc: "Knocks an enemy back, delaying their action." },
    ],
    hue: "#B8895B",
  },
  {
    id: "c6",
    name: "Tideglass Mote",
    element: "Water",
    rarity: "Legendary",
    power: 92,
    hp: 90,
    atk: 86,
    def: 78,
    spd: 84,
    shards: 0,
    object: "Drinking Glass",
    labels: [{ name: "glass", conf: 96 }, { name: "water", conf: 91 }],
    discovered: "May 1, 2026 · 21:07",
    lore: "Only appears at the meniscus of a perfectly still glass at dusk.",
    abilities: [
      { name: "Mirror Tide", desc: "Reflects a portion of damage taken." },
      { name: "Lullwater", desc: "Calms the field, removing all status effects." },
    ],
    hue: "#3BA7FF",
  },
];

import { CREATURES, Creature, Element } from "./creature-data";

export type SpeedTier = "Slow" | "Normal" | "Quick";
export type EffectKey = "Burn" | "Mend" | "Guard" | "Draft" | "Spark" | "Grow" | "Weaken" | "Focus";

export const EFFECT_BY_ELEMENT: Record<Element, EffectKey> = {
  Fire: "Burn",
  Water: "Mend",
  Earth: "Guard",
  Air: "Draft",
  Electric: "Spark",
  Nature: "Grow",
  Shadow: "Weaken",
  Light: "Focus",
};

export const EFFECT_DESC: Record<EffectKey, string> = {
  Burn: "Deals 1 extra damage at end of turn.",
  Mend: "Restores 1 Resolve when played.",
  Guard: "Adds +1 Shield this turn.",
  Draft: "Draw 1 card.",
  Spark: "Pierces 1 damage through Shield.",
  Grow: "Next card you play deals +1 damage.",
  Weaken: "Reduces next anomaly attack by 1.",
  Focus: "Gain +1 Focus next turn.",
};

export type TrialCard = Creature & {
  cost: number;
  damage: number;
  shield: number;
  speed: SpeedTier;
  effect: EffectKey;
};

function deriveCard(c: Creature): TrialCard {
  const seed = c.power + c.atk;
  const cost = Math.max(1, Math.min(4, Math.round(c.power / 25)));
  const damage = Math.max(1, Math.round(c.atk / 18));
  const shield = Math.max(0, Math.round(c.def / 24));
  const speed: SpeedTier = c.spd >= 80 ? "Quick" : c.spd >= 50 ? "Normal" : "Slow";
  void seed;
  return { ...c, cost, damage, shield, speed, effect: EFFECT_BY_ELEMENT[c.element] };
}

export const TRIAL_CARDS: TrialCard[] = CREATURES.map(deriveCard);

// Pad collection to >= 8 by duplicating with name variants for deck UX
export const COLLECTION: TrialCard[] = [
  ...TRIAL_CARDS,
  ...TRIAL_CARDS.slice(0, 4).map((c, i) => ({
    ...c,
    id: `${c.id}-x`,
    name: ["Emberkin", "Dewmote", "Glasshare", "Cinderbud"][i] || c.name,
    power: Math.max(35, c.power - 8 - i * 2),
    rarity: (["Common", "Uncommon", "Rare"] as const)[i % 3],
  })),
];

export type Difficulty = "Calm" | "Wild" | "Mythic";
export const DIFFICULTIES: Record<Difficulty, { hp: number; atk: number; rec: number; xp: number; shards: number; color: string; desc: string }> = {
  Calm: { hp: 24, atk: 3, rec: 45, xp: 20, shards: 1, color: "#E60012", desc: "Soft anomaly. Steady signal." },
  Wild: { hp: 36, atk: 5, rec: 60, xp: 40, shards: 2, color: "#FFD300", desc: "Volatile. Sharper retaliations." },
  Mythic: { hp: 52, atk: 7, rec: 75, xp: 70, shards: 3, color: "#FFD300", desc: "Catastrophic distortion." },
};

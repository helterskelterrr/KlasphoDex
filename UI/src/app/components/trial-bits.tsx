import { ReactNode } from "react";
import { Flame, Droplets, Mountain, Wind, Zap, Leaf, Moon, Sun } from "lucide-react";
import { ELEMENT_COLORS, RARITY_COLORS } from "./creature-data";
import { TrialCard, EffectKey, EFFECT_DESC } from "./trial-data";
import { CreaturePortrait } from "./CreaturePortrait";

export const ELEMENT_ICON: Record<string, any> = {
  Fire: Flame, Water: Droplets, Earth: Mountain, Air: Wind,
  Electric: Zap, Nature: Leaf, Shadow: Moon, Light: Sun,
};

export function FocusGem({ value, size = 28 }: { value: number; size?: number }) {
  return (
    <div className="relative grid place-items-center" style={{ width: size, height: size }}>
      <svg viewBox="0 0 32 32" width={size} height={size} style={{ position: "absolute", inset: 0 }}>
        <defs>
          <linearGradient id="fg-grad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#E60012" />
            <stop offset="100%" stopColor="#8B0008" />
          </linearGradient>
        </defs>
        <polygon points="16,2 30,12 24,30 8,30 2,12" fill="url(#fg-grad)" stroke="#E60012" />
      </svg>
      <span className="relative" style={{ color: "#0A0A0A", fontSize: size * 0.45, fontWeight: 900 }}>{value}</span>
    </div>
  );
}

export function MiniStat({ icon, value, color }: { icon: ReactNode; value: number | string; color: string }) {
  return (
    <div className="flex items-center gap-1 px-1.5 py-0.5 rounded" style={{ background: "#0A0A0A", border: `1px solid ${color}55` }}>
      <span style={{ color }}>{icon}</span>
      <span style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 800 }}>{value}</span>
    </div>
  );
}

export function HandCard({
  card, disabled, onClick, compact = false,
}: { card: TrialCard; disabled?: boolean; onClick?: () => void; compact?: boolean }) {
  const elem = ELEMENT_COLORS[card.element];
  const rarity = RARITY_COLORS[card.rarity];
  const Icon = ELEMENT_ICON[card.element] || Sun;
  const w = compact ? 116 : 130;
  const h = compact ? 168 : 188;
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="relative shrink-0 overflow-hidden text-left active:scale-[0.97] transition-transform"
      style={{
        width: w, height: h,
        background: `linear-gradient(180deg, ${elem}28 0%, #15100F 55%, #0A0A0A 100%)`,
        border: `2px solid ${disabled ? "#2A1F1F" : elem}`,
        boxShadow: disabled ? "none" : `3px 3px 0 #0A0A0A, 3px 3px 0 1px ${rarity}66`,
        opacity: disabled ? 0.45 : 1,
        clipPath: "polygon(0 0,100% 0,100% 88%,90% 100%,0 100%)",
      }}
    >
      {/* Rarity top stripe */}
      <div className="absolute left-0 right-0 top-0 h-1" style={{ background: rarity }} />

      {/* corner cost */}
      <div className="absolute top-1.5 left-1.5 z-10">
        <FocusGem value={card.cost} size={26} />
      </div>

      {/* Element icon — top right */}
      <div
        className="absolute top-1.5 right-1.5 z-10 size-6 grid place-items-center"
        style={{
          background: `${elem}33`,
          border: `1px solid ${elem}88`,
          clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
        }}
      >
        <Icon size={11} color={elem} />
      </div>

      {/* portrait */}
      <div className="absolute inset-x-0 top-7 h-[52%] grid place-items-center">
        <div style={{ filter: disabled ? "grayscale(0.6)" : undefined }}>
          <CreaturePortrait creature={card} size={compact ? 80 : 92} />
        </div>
      </div>

      {/* Corner slash decoration */}
      <div
        className="absolute bottom-0 right-0 pointer-events-none"
        style={{
          width: 18, height: 18,
          background: elem,
          clipPath: "polygon(100% 0,100% 100%,0 100%)",
          opacity: disabled ? 0.2 : 0.5,
        }}
      />

      {/* footer */}
      <div
        className="absolute bottom-0 left-0 right-0 p-2"
        style={{ background: "linear-gradient(180deg, transparent, #0A0A0A 40%)" }}
      >
        <div className="truncate" style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 900, letterSpacing: "-0.01em", fontStyle: "italic" }}>
          {card.name}
        </div>
        <div className="truncate" style={{ color: elem, fontSize: 9, fontWeight: 800 }}>{card.effect} · {card.speed}</div>
        <div className="mt-1.5 flex items-center justify-between">
          <MiniStat icon={<Flame size={9} />} value={card.damage} color="#FF6B4A" />
          <MiniStat icon={<Droplets size={9} />} value={card.shield} color="#3BA7FF" />
        </div>
      </div>
    </button>
  );
}
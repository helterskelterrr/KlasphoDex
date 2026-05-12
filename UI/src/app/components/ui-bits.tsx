import { ReactNode } from "react";
import { Element, Rarity, ELEMENT_COLORS, RARITY_COLORS } from "./creature-data";

export function TypeBadge({ element, size = "sm" }: { element: Element; size?: "sm" | "md" }) {
  const color = ELEMENT_COLORS[element];
  const px = size === "md" ? "px-2.5 py-1" : "px-2 py-0.5";
  return (
    <span
      className={`inline-flex items-center gap-1.5 ${px} rounded-full border tracking-wider`}
      style={{
        borderColor: `${color}55`,
        background: `${color}18`,
        color,
        fontSize: size === "md" ? 11 : 10,
        fontWeight: 600,
        letterSpacing: "0.12em",
      }}
    >
      <span className="size-1.5 rounded-full" style={{ background: color, boxShadow: `0 0 6px ${color}` }} />
      {element.toUpperCase()}
    </span>
  );
}

export function RarityBadge({ rarity, size = "sm" }: { rarity: Rarity; size?: "sm" | "md" }) {
  const color = RARITY_COLORS[rarity];
  const px = size === "md" ? "px-2.5 py-1" : "px-2 py-0.5";
  return (
    <span
      className={`inline-flex items-center ${px} rounded-sm tracking-[0.18em]`}
      style={{
        background: `${color}1f`,
        color,
        border: `1px solid ${color}66`,
        fontSize: size === "md" ? 10 : 9,
        fontWeight: 700,
        clipPath: "polygon(6% 0,100% 0,94% 100%,0 100%)",
      }}
    >
      {rarity.toUpperCase()}
    </span>
  );
}

export function GlassPanel({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div
      className={`relative rounded-md ${className}`}
      style={{
        background: "#15100F",
        border: "2px solid #0A0A0A",
        outline: "1px solid #2A1F1F",
        outlineOffset: "-1px",
        boxShadow: "3px 3px 0 #0A0A0A, 3px 3px 0 1px #E60012",
      }}
    >
      {children}
    </div>
  );
}

export function StatBar({ label, value, color = "#E60012" }: { label: string; value: number; color?: string }) {
  return (
    <div className="flex items-center gap-2">
      <span className="w-9 tracking-widest" style={{ color: "#8A7F76", fontSize: 10, fontWeight: 600 }}>
        {label.toUpperCase()}
      </span>
      <div className="flex-1 h-1.5 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
        <div
          className="h-full rounded-full"
          style={{
            width: `${value}%`,
            background: `linear-gradient(90deg, ${color}, ${color}77)`,
            boxShadow: `0 0 8px ${color}66`,
          }}
        />
      </div>
      <span className="w-7 text-right tabular-nums" style={{ color: "#F5F1E8", fontSize: 12, fontWeight: 600 }}>
        {value}
      </span>
    </div>
  );
}

export function KineticTitle({ children, accent = "#E60012" }: { children: ReactNode; accent?: string }) {
  return (
    <div className="relative inline-block">
      <span
        aria-hidden
        className="absolute -left-1 -top-1 select-none"
        style={{
          color: accent,
          opacity: 0.25,
          fontWeight: 900,
          letterSpacing: "-0.02em",
          fontSize: "inherit",
          transform: "skewX(-8deg)",
        }}
      >
        {children}
      </span>
      <span
        className="relative"
        style={{ color: "#F5F1E8", fontWeight: 900, letterSpacing: "-0.02em", transform: "skewX(-6deg)", display: "inline-block" }}
      >
        {children}
      </span>
    </div>
  );
}

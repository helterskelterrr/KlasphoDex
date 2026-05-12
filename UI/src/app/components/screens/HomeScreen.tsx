import { Bell, Flame, Sparkles, ChevronRight, Target, Leaf, Star, Swords } from "lucide-react";
import { GlassPanel, TypeBadge, RarityBadge } from "../ui-bits";
import { CREATURES } from "../creature-data";
import { CreaturePortrait } from "../CreaturePortrait";

export function HomeScreen({ onScan, onOpenCreature, onFieldTrials }: { onScan: () => void; onOpenCreature: (id: string) => void; onFieldTrials: () => void }) {
  const recent = CREATURES[0];
  return (
    <div className="px-5 pt-3 pb-28 space-y-5">
      {/* greeting */}
      <div className="flex items-center justify-between">
        <div>
          <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.3em", fontWeight: 800 }}>// FIELD STATUS · ACTIVE</div>
          <h1 className="cl-display" style={{ color: "#F5F1E8", fontSize: 28, marginTop: 4 }}>
            Welcome back,<br /><span style={{ color: "#E60012", textShadow: "3px 3px 0 #FFD300" }}>MIRA.</span>
          </h1>
        </div>
        <button className="size-10 grid place-items-center" style={{ background: "#FFD300", border: "2px solid #0A0A0A", boxShadow: "2px 2px 0 #0A0A0A", transform: "rotate(-3deg)" }}>
          <Bell size={16} color="#0A0A0A" strokeWidth={3} />
        </button>
      </div>

      {/* Mission hub — chaotic P5 hero */}
      <button
        onClick={onScan}
        className="relative w-full text-left active:translate-x-0.5 active:translate-y-0.5 transition-transform cl-halftone"
        style={{
          background: "#E60012",
          border: "3px solid #0A0A0A",
          boxShadow: "6px 6px 0 #0A0A0A, 6px 6px 0 2px #FFD300",
          minHeight: 160,
          overflow: "hidden",
        }}
      >
        {/* yellow burst slash */}
        <div className="absolute -right-12 -top-12 size-48" style={{
          background: "#FFD300",
          clipPath: "polygon(50% 0%, 60% 38%, 100% 35%, 70% 60%, 80% 100%, 50% 75%, 20% 100%, 30% 60%, 0% 35%, 40% 38%)",
          opacity: 0.95,
        }} />
        {/* diagonal black slash band */}
        <div className="absolute inset-y-0 -right-8 w-24" style={{
          background: "#0A0A0A",
          transform: "skewX(-18deg)",
          opacity: 0.85,
        }} />
        <div className="relative p-5 flex justify-between items-end h-full" style={{ minHeight: 160 }}>
          <div>
            <div className="inline-block px-2 py-0.5 cl-stamp" style={{ fontSize: 10, fontWeight: 900, letterSpacing: "0.18em" }}>
              ! PRIMARY
            </div>
            <div className="cl-display mt-2" style={{ color: "#F5F1E8", fontSize: 44, textShadow: "3px 3px 0 #0A0A0A" }}>
              SCAN<br/>CREATURE
            </div>
            <div className="mt-2" style={{ color: "#0A0A0A", fontSize: 11, fontWeight: 800, letterSpacing: "0.05em", background: "#FFD300", padding: "2px 8px", display: "inline-block", border: "2px solid #0A0A0A" }}>
              AWAKEN WHAT'S HIDING IN PLAIN SIGHT
            </div>
          </div>
          <div className="size-16 grid place-items-center relative shrink-0" style={{
            background: "#FFD300", border: "3px solid #0A0A0A", clipPath: "polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)",
          }}>
            <Target size={26} color="#0A0A0A" strokeWidth={3} />
          </div>
        </div>
      </button>

      {/* Rank + Streak */}
      <div className="grid grid-cols-3 gap-3">
        <GlassPanel className="col-span-2 p-4">
          <div className="flex items-center justify-between">
            <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 600 }}>FIELD RANK</div>
            <div style={{ color: "#FFD300", fontSize: 11, fontWeight: 700 }}>LV 12</div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span style={{ color: "#F5F1E8", fontSize: 24, fontWeight: 900 }}>1,240</span>
            <span style={{ color: "#8A7F76", fontSize: 11 }}>/ 1,500 XP</span>
          </div>
          <div className="mt-2 h-2 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
            <div className="h-full rounded-full" style={{ width: "82%", background: "#E60012", boxShadow: "0 0 8px #E60012aa" }} />
          </div>
        </GlassPanel>
        <GlassPanel className="p-4 flex flex-col justify-between">
          <Flame size={18} color="#FFA947" />
          <div>
            <div style={{ color: "#F5F1E8", fontSize: 22, fontWeight: 900, lineHeight: 1 }}>9</div>
            <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.15em", fontWeight: 600 }}>DAY STREAK</div>
          </div>
        </GlassPanel>
      </div>

      {/* Daily Missions */}
      <div>
        <div className="flex items-center justify-between mb-2 px-1">
          <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700, letterSpacing: "0.05em" }}>DAILY MISSIONS</div>
          <div style={{ color: "#8A7F76", fontSize: 11 }}>refreshes 14h</div>
        </div>
        <GlassPanel className="divide-y" style={{}}>
          {[
            { icon: <Target size={16} color="#E60012" />, title: "Scan 3 objects", prog: "1/3", xp: 30, pct: 33 },
            { icon: <Star size={16} color="#FFD300" />, title: "Find a Rare+", prog: "0/1", xp: 50, pct: 0 },
            { icon: <Leaf size={16} color="#43D17A" />, title: "Scan a Nature type", prog: "0/1", xp: 25, pct: 0 },
          ].map((m, i) => (
            <div key={i} className="p-3.5 flex items-center gap-3" style={{ borderColor: "#2A1F1F" }}>
              <div className="size-9 rounded-lg grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>{m.icon}</div>
              <div className="flex-1">
                <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>{m.title}</div>
                <div className="mt-1 h-1 rounded-full" style={{ background: "#1A1414" }}>
                  <div className="h-full rounded-full" style={{ width: `${m.pct}%`, background: "#E60012" }} />
                </div>
              </div>
              <div className="text-right">
                <div style={{ color: "#C9C2B5", fontSize: 11, fontWeight: 600 }}>{m.prog}</div>
                <div style={{ color: "#FFD300", fontSize: 11, fontWeight: 700 }}>+{m.xp} XP</div>
              </div>
            </div>
          ))}
        </GlassPanel>
      </div>

      {/* Recent discovery */}
      <div>
        <div className="flex items-center justify-between mb-2 px-1">
          <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700, letterSpacing: "0.05em" }}>RECENT DISCOVERY</div>
          <button onClick={() => onOpenCreature(recent.id)} className="flex items-center gap-1" style={{ color: "#E60012", fontSize: 11, fontWeight: 600 }}>
            VIEW <ChevronRight size={12} />
          </button>
        </div>
        <button onClick={() => onOpenCreature(recent.id)} className="w-full">
          <GlassPanel className="p-4 flex items-center gap-4">
            <div className="shrink-0 rounded-xl overflow-hidden" style={{ background: "#0A0A0A", border: "1px solid #2A1F1F" }}>
              <CreaturePortrait creature={recent} size={84} />
            </div>
            <div className="flex-1 text-left">
              <div className="flex items-center gap-1.5 mb-1">
                <RarityBadge rarity={recent.rarity} />
                <TypeBadge element={recent.element} />
              </div>
              <div style={{ color: "#F5F1E8", fontSize: 16, fontWeight: 700 }}>{recent.name}</div>
              <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 2 }}>From {recent.object} · PWR {recent.power}</div>
            </div>
            <Sparkles size={16} color="#FFD300" />
          </GlassPanel>
        </button>
      </div>

      {/* Field Trials panel */}
      <button onClick={onFieldTrials} className="w-full text-left active:translate-x-0.5 active:translate-y-0.5 transition-transform">
        <div className="relative overflow-hidden p-4" style={{
          background: "#0A0A0A",
          border: "3px solid #FFD300",
          boxShadow: "5px 5px 0 #E60012",
        }}>
          {/* halftone corner */}
          <div className="absolute right-0 top-0 size-24 cl-halftone-light" />
          <div className="relative flex items-center gap-3">
            <div className="size-11 grid place-items-center shrink-0" style={{
              background: "#FFD300", border: "2px solid #0A0A0A", clipPath: "polygon(15% 0,100% 0,85% 100%,0 100%)",
            }}>
              <Swords size={18} color="#0A0A0A" strokeWidth={3} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5">
                <span className="cl-eyebrow" style={{ color: "#FFD300" }}>// Field trials</span>
                <span className="px-1.5 py-0.5 rounded-sm" style={{ background: "#43D17A22", color: "#43D17A", fontSize: 8, fontWeight: 800, letterSpacing: "0.15em" }}>READY</span>
              </div>
              <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 700, marginTop: 2 }}>An anomaly signal is stable.</div>
              <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 1 }}>Deck 8/8 · avg power 68</div>
            </div>
            <ChevronRight size={16} color="#8A7F76" />
          </div>
        </div>
      </button>

      {/* Stats summary */}
      <div className="grid grid-cols-3 gap-2">
        {[
          { v: "42", l: "CREATURES" },
          { v: "EPIC", l: "RAREST" },
          { v: "21", l: "BEST STREAK" },
        ].map((s, i) => (
          <div key={i} className="p-3 rounded-lg text-center" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
            <div style={{ color: "#F5F1E8", fontSize: 16, fontWeight: 800 }}>{s.v}</div>
            <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.15em", fontWeight: 600, marginTop: 2 }}>{s.l}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

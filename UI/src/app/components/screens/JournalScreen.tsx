import { useState } from "react";
import { Search, LayoutGrid, List, ChevronDown } from "lucide-react";
import { CREATURES, Element, Rarity } from "../creature-data";
import { CreaturePortrait } from "../CreaturePortrait";
import { TypeBadge, RarityBadge } from "../ui-bits";

const TYPES: ("All" | Element)[] = ["All", "Nature", "Fire", "Water", "Electric", "Shadow", "Light", "Earth"];
const RARITIES: ("All" | Rarity)[] = ["All", "Common", "Uncommon", "Rare", "Epic", "Legendary"];

export function JournalScreen({ onOpenCreature }: { onOpenCreature: (id: string) => void }) {
  const [type, setType] = useState<typeof TYPES[number]>("All");
  const [rarity, setRarity] = useState<typeof RARITIES[number]>("All");
  const [view, setView] = useState<"grid" | "list">("grid");

  const items = CREATURES.filter(c => (type === "All" || c.element === type) && (rarity === "All" || c.rarity === rarity));

  return (
    <div className="px-5 pt-3 pb-28">
      {/* Header */}
      <div className="flex items-end justify-between">
        <div>
          <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.2em", fontWeight: 600 }}>VOLUME I</div>
          <h1 style={{ color: "#F5F1E8", fontSize: 26, fontWeight: 800, lineHeight: 1, marginTop: 2 }}>Field Journal</h1>
          <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 4 }}>Creatures awakened from everyday objects.</div>
        </div>
        <div className="flex rounded-lg overflow-hidden" style={{ border: "1px solid #2A1F1F" }}>
          {(["grid", "list"] as const).map((v) => (
            <button key={v} onClick={() => setView(v)} className="size-9 grid place-items-center"
              style={{ background: view === v ? "#E60012" : "#1A1414", color: view === v ? "#0A0A0A" : "#C9C2B5" }}>
              {v === "grid" ? <LayoutGrid size={15} /> : <List size={15} />}
            </button>
          ))}
        </div>
      </div>

      {/* Search */}
      <div className="mt-4 flex items-center gap-2 px-3 h-10 rounded-lg" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
        <Search size={14} color="#8A7F76" />
        <input placeholder="Search specimens..." className="flex-1 bg-transparent outline-none" style={{ color: "#F5F1E8", fontSize: 13 }} />
        <button className="flex items-center gap-1" style={{ color: "#8A7F76", fontSize: 11, fontWeight: 600 }}>
          DATE <ChevronDown size={12} />
        </button>
      </div>

      {/* Filter strips */}
      <div className="mt-3 -mx-5 px-5 overflow-x-auto no-scrollbar">
        <div className="flex gap-1.5 pb-1">
          {TYPES.map((t) => (
            <button key={t} onClick={() => setType(t)}
              className="shrink-0 px-3 py-1.5 rounded-full"
              style={{
                background: type === t ? "#E60012" : "#1A1414",
                color: type === t ? "#0A0A0A" : "#C9C2B5",
                border: `1px solid ${type === t ? "#E60012" : "#2A1F1F"}`,
                fontSize: 11, fontWeight: 700, letterSpacing: "0.08em",
              }}>{t.toUpperCase()}</button>
          ))}
        </div>
      </div>
      <div className="mt-2 -mx-5 px-5 overflow-x-auto no-scrollbar">
        <div className="flex gap-1.5 pb-1">
          {RARITIES.map((r) => (
            <button key={r} onClick={() => setRarity(r)}
              className="shrink-0 px-3 py-1.5 rounded-full"
              style={{
                background: rarity === r ? "#FFD300" : "#1A1414",
                color: rarity === r ? "#0A0A0A" : "#C9C2B5",
                border: `1px solid ${rarity === r ? "#FFD300" : "#2A1F1F"}`,
                fontSize: 11, fontWeight: 700, letterSpacing: "0.08em",
              }}>{r.toUpperCase()}</button>
          ))}
        </div>
      </div>

      {/* Count */}
      <div className="mt-4 flex items-center justify-between">
        <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.15em", fontWeight: 600 }}>
          {items.length} SPECIMENS · 36 UNDISCOVERED
        </div>
      </div>

      {/* Grid */}
      {view === "grid" ? (
        <div className="mt-3 grid grid-cols-2 gap-3">
          {items.map((c) => (
            <button key={c.id} onClick={() => onOpenCreature(c.id)}
              className="relative rounded-xl overflow-hidden text-left active:scale-[0.98] transition-transform"
              style={{ background: "linear-gradient(180deg, #221818, #111111)", border: "1px solid #2A1F1F" }}>
              <div className="aspect-square relative" style={{
                background: `radial-gradient(circle at 50% 40%, ${c.hue}22, transparent 60%)`,
              }}>
                <div className="absolute inset-0 grid place-items-center">
                  <CreaturePortrait creature={c} size={140} />
                </div>
                <div className="absolute top-2 left-2"><RarityBadge rarity={c.rarity} /></div>
                <div className="absolute top-2 right-2"><TypeBadge element={c.element} /></div>
                {c.shards > 0 && (
                  <div className="absolute bottom-2 right-2 px-1.5 py-0.5 rounded" style={{ background: "rgba(5,7,13,0.7)", border: "1px solid #FFD30055", color: "#FFD300", fontSize: 9, fontWeight: 700 }}>
                    ◆ {c.shards}
                  </div>
                )}
              </div>
              <div className="p-2.5">
                <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700, lineHeight: 1.2 }}>{c.name}</div>
                <div className="flex items-center justify-between mt-1">
                  <div style={{ color: "#8A7F76", fontSize: 10 }}>From {c.object}</div>
                  <div style={{ color: c.hue, fontSize: 11, fontWeight: 800 }}>PWR {c.power}</div>
                </div>
              </div>
            </button>
          ))}
        </div>
      ) : (
        <div className="mt-3 space-y-2">
          {items.map((c) => (
            <button key={c.id} onClick={() => onOpenCreature(c.id)}
              className="w-full p-3 rounded-xl flex items-center gap-3 text-left"
              style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
              <div className="size-14 rounded-lg overflow-hidden shrink-0" style={{ background: "#0A0A0A" }}>
                <CreaturePortrait creature={c} size={56} />
              </div>
              <div className="flex-1 min-w-0">
                <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 700 }}>{c.name}</div>
                <div className="flex items-center gap-1.5 mt-1">
                  <RarityBadge rarity={c.rarity} />
                  <TypeBadge element={c.element} />
                </div>
              </div>
              <div className="text-right">
                <div style={{ color: c.hue, fontSize: 14, fontWeight: 800 }}>{c.power}</div>
                <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.15em", fontWeight: 600 }}>POWER</div>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

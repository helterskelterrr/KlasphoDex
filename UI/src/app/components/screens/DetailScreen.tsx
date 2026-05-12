import { ArrowLeft, Share2 } from "lucide-react";
import { CREATURES, RARITY_COLORS } from "../creature-data";
import { CreaturePortrait } from "../CreaturePortrait";
import { TypeBadge, RarityBadge, StatBar } from "../ui-bits";

export function DetailScreen({ id, onBack }: { id: string; onBack: () => void }) {
  const c = CREATURES.find(x => x.id === id) || CREATURES[0];
  const rarity = RARITY_COLORS[c.rarity];

  return (
    <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>
      {/* hero */}
      <div className="relative h-[340px]" style={{
        background: `radial-gradient(ellipse at 50% 40%, ${c.hue}33, transparent 60%), linear-gradient(180deg, #15100F, #0A0A0A)`,
      }}>
        <div className="absolute inset-0 opacity-15" style={{
          backgroundImage: "linear-gradient(0deg, transparent 95%, #E60012 95%), linear-gradient(90deg, transparent 95%, #E60012 95%)",
          backgroundSize: "20px 20px",
        }} />
        <div className="relative flex items-center justify-between p-4 z-10">
          <button onClick={onBack} className="size-10 rounded-full grid place-items-center backdrop-blur" style={{ background: "rgba(5,7,13,0.6)", border: "1px solid #2A1F1F" }}>
            <ArrowLeft size={18} color="#F5F1E8" />
          </button>
          <button className="size-10 rounded-full grid place-items-center backdrop-blur" style={{ background: "rgba(5,7,13,0.6)", border: "1px solid #2A1F1F" }}>
            <Share2 size={16} color="#F5F1E8" />
          </button>
        </div>
        <div className="absolute inset-0 grid place-items-center pt-6">
          <CreaturePortrait creature={c} size={240} />
        </div>
        {/* angled stamp */}
        <div className="absolute right-5 bottom-5 px-3 py-1.5 rounded" style={{
          background: `${rarity}`, color: "#0A0A0A", fontSize: 10, fontWeight: 900, letterSpacing: "0.2em",
          transform: "rotate(-6deg)", boxShadow: `0 4px 12px ${rarity}66`,
        }}>SPECIMEN №{c.id.toUpperCase()}</div>
      </div>

      <div className="px-5 -mt-3 pb-12">
        {/* identity card */}
        <div className="p-4 rounded-xl" style={{ background: "linear-gradient(180deg, #221818, #15100F)", border: "1px solid #2A1F1F" }}>
          <div className="flex items-center gap-1.5 mb-2">
            <RarityBadge rarity={c.rarity} size="md" />
            <TypeBadge element={c.element} size="md" />
            <div className="ml-auto px-2 py-1 rounded text-right" style={{ background: "#1A1414", border: "1px solid #FFD30033" }}>
              <span style={{ color: "#FFD300", fontSize: 11, fontWeight: 700 }}>◆ {c.shards} SHARDS</span>
            </div>
          </div>
          <h1 style={{ color: "#F5F1E8", fontSize: 28, fontWeight: 800, letterSpacing: "-0.01em", lineHeight: 1 }}>{c.name}</h1>
          <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 4 }}>Class · {c.element} Specimen</div>
        </div>

        {/* Stats */}
        <div className="mt-4">
          <SectionLabel>STATISTICS</SectionLabel>
          <div className="mt-2 p-4 rounded-xl space-y-2.5" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
            <StatBar label="HP" value={c.hp} color="#43D17A" />
            <StatBar label="ATK" value={c.atk} color="#FF6B4A" />
            <StatBar label="DEF" value={c.def} color="#3BA7FF" />
            <StatBar label="SPD" value={c.spd} color="#FFE15A" />
          </div>
        </div>

        {/* Lore */}
        <div className="mt-5">
          <SectionLabel>FIELD NOTE</SectionLabel>
          <div className="mt-2 p-4 rounded-xl relative" style={{ background: "#F5F1E8", color: "#142027" }}>
            <div className="absolute left-3 top-3 right-3 h-px" style={{ background: "#142027", opacity: 0.1 }} />
            <p style={{ fontSize: 14, lineHeight: 1.6, fontStyle: "italic", marginTop: 8 }}>"{c.lore}"</p>
            <div className="mt-3 flex items-center justify-between text-xs" style={{ color: "#5F6F6B" }}>
              <span>— transcribed by Mira V.</span>
              <span style={{
                color: "#d4183d", border: "1px solid #d4183d", padding: "2px 6px", borderRadius: 2,
                fontSize: 9, fontWeight: 800, letterSpacing: "0.2em", transform: "rotate(-3deg)", display: "inline-block",
              }}>VERIFIED</span>
            </div>
          </div>
        </div>

        {/* Abilities */}
        <div className="mt-5">
          <SectionLabel>ABILITIES</SectionLabel>
          <div className="mt-2 space-y-2">
            {c.abilities.map((a) => (
              <div key={a.name} className="p-3 rounded-lg flex gap-3" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
                <div className="size-10 rounded-md grid place-items-center shrink-0" style={{ background: `${c.hue}22`, border: `1px solid ${c.hue}55` }}>
                  <span style={{ color: c.hue, fontSize: 18, fontWeight: 900 }}>✦</span>
                </div>
                <div className="flex-1">
                  <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700 }}>{a.name}</div>
                  <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 2, lineHeight: 1.4 }}>{a.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Scan info */}
        <div className="mt-5">
          <SectionLabel>SCAN INFO</SectionLabel>
          <div className="mt-2 p-4 rounded-xl space-y-2" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
            <Row k="Object" v={c.object} />
            <Row k="Discovered" v={c.discovered} />
            <div>
              <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.15em", fontWeight: 600 }}>LABELS</div>
              <div className="mt-1.5 flex flex-wrap gap-1.5">
                {c.labels.map(l => (
                  <span key={l.name} className="px-2 py-1 rounded-sm flex items-center gap-1.5"
                    style={{ background: "#1A1414", border: "1px solid #2A1F1F", fontSize: 11 }}>
                    <span style={{ color: "#F5F1E8", fontWeight: 600 }}>{l.name}</span>
                    <span style={{ color: "#E60012", fontWeight: 800 }}>{l.conf}%</span>
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Evolution */}
        <div className="mt-5">
          <SectionLabel>EVOLUTION</SectionLabel>
          <div className="mt-2 p-4 rounded-xl flex items-center gap-3" style={{
            background: "linear-gradient(135deg, #1a1530, #15100F)", border: "1px solid #FFD30044",
          }}>
            <div className="size-12 rounded-lg grid place-items-center" style={{ background: "#1A1414", border: "1px solid #FFD30055" }}>
              <span style={{ color: "#FFD300", fontSize: 20 }}>◆</span>
            </div>
            <div className="flex-1">
              <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700 }}>{c.shards} Evolution Shards</div>
              <div className="mt-1 h-1 rounded-full" style={{ background: "#1A1414" }}>
                <div className="h-full rounded-full" style={{ width: `${(c.shards/10)*100}%`, background: "#FFD300" }} />
              </div>
            </div>
            <button disabled className="px-3 py-2 rounded-md" style={{ background: "#1A1414", color: "#8A7F76", fontSize: 11, fontWeight: 700 }}>
              NEED 7 MORE
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function SectionLabel({ children }: { children: any }) {
  return <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.25em", fontWeight: 700, paddingLeft: 4 }}>{children}</div>;
}
function Row({ k, v }: { k: string; v: string }) {
  return (
    <div className="flex items-center justify-between py-1">
      <span style={{ color: "#8A7F76", fontSize: 12 }}>{k}</span>
      <span style={{ color: "#F5F1E8", fontSize: 12, fontWeight: 600 }}>{v}</span>
    </div>
  );
}

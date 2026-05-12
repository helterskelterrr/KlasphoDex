import { Settings, Flame, Trophy, Lock } from "lucide-react";
import { GlassPanel } from "../ui-bits";

const ACHIEVEMENTS = [
  { name: "First Scan", icon: "✦", color: "#E60012", unlocked: true },
  { name: "Rare Note", icon: "◆", color: "#3BA7FF", unlocked: true },
  { name: "7 Day Flame", icon: "▲", color: "#FF6B4A", unlocked: true },
  { name: "Nature Master", icon: "❋", color: "#43D17A", unlocked: true },
  { name: "Shard Smith", icon: "✧", color: "#FFD300", unlocked: true },
  { name: "Legend Hunter", icon: "★", color: "#FFD300", unlocked: false },
];

export function ProfileScreen({ onOpenAchievements, onOpenSettings }: { onOpenAchievements: () => void; onOpenSettings: () => void }) {
  return (
    <div className="px-5 pt-3 pb-28 space-y-5">
      <div className="flex items-center justify-between">
        <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.2em", fontWeight: 600 }}>EXPLORER PROFILE</div>
        <button onClick={onOpenSettings} className="size-10 rounded-full grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
          <Settings size={16} color="#C9C2B5" />
        </button>
      </div>

      {/* Identity */}
      <div className="relative overflow-hidden rounded-2xl p-5 cl-hatch" style={{
        background: "#15100F",
        border: "1px solid #2A1F1F",
      }}>
        <div className="absolute left-0 top-0 bottom-0 w-1" style={{ background: "#E60012" }} />
        {/* huge level number */}
        <div className="absolute right-3 top-2 select-none" style={{
          color: "#E60012", opacity: 0.12, fontSize: 120, fontWeight: 900, lineHeight: 1, letterSpacing: "-0.05em",
        }}>12</div>
        <div className="relative flex items-start gap-3">
          <div className="size-16 rounded-full grid place-items-center shrink-0" style={{
            background: "#E60012", color: "#F5F1E8", fontSize: 24, fontWeight: 900, border: "2px solid #FFD300",
          }}>MV</div>
          <div className="flex-1 pt-1">
            <div style={{ color: "#F5F1E8", fontSize: 22, fontWeight: 800, lineHeight: 1.1 }}>Mira Vale</div>
            <div style={{ color: "#E60012", fontSize: 12, fontWeight: 600, marginTop: 2, letterSpacing: "0.05em" }}>AI Field Explorer</div>
          </div>
        </div>
        {/* XP */}
        <div className="relative mt-5">
          <div className="flex items-end justify-between">
            <div>
              <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 600 }}>RANK XP</div>
              <div className="flex items-baseline gap-2">
                <span style={{ color: "#F5F1E8", fontSize: 22, fontWeight: 900 }}>1,240</span>
                <span style={{ color: "#8A7F76", fontSize: 11 }}>/ 1,500</span>
              </div>
            </div>
            <div style={{ color: "#FFD300", fontSize: 11, fontWeight: 700, letterSpacing: "0.15em" }}>NEXT: LV 13</div>
          </div>
          <div className="mt-2 h-2 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
            <div className="h-full" style={{ width: "82%", background: "#E60012" }} />
          </div>
        </div>
      </div>

      {/* Lifetime stats */}
      <div className="grid grid-cols-2 gap-3">
        <Stat v="42" l="TOTAL CREATURES" color="#E60012" />
        <Stat v="EPIC" l="RAREST CATCH" color="#FFD300" />
        <Stat v="9" l="CURRENT STREAK" color="#FF6B4A" icon={<Flame size={14} color="#FF6B4A"/>} />
        <Stat v="21" l="LONGEST STREAK" color="#FFD300" />
      </div>

      {/* Achievements */}
      <div>
        <div className="flex items-center justify-between mb-2 px-1">
          <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700, letterSpacing: "0.05em" }}>ACHIEVEMENTS</div>
          <div style={{ color: "#8A7F76", fontSize: 11 }}>5 / 24</div>
        </div>
        <GlassPanel className="p-3">
          <div className="grid grid-cols-3 gap-3">
            {ACHIEVEMENTS.map((a) => (
              <button key={a.name} onClick={onOpenAchievements} className="flex flex-col items-center gap-1.5">
                <div className="size-16 rounded-full grid place-items-center relative" style={{
                  background: a.unlocked ? `radial-gradient(circle, ${a.color}33, transparent 70%)` : "#15100F",
                  border: `1px solid ${a.unlocked ? a.color : "#2A1F1F"}`,
                  opacity: a.unlocked ? 1 : 0.5,
                }}>
                  {a.unlocked ? (
                    <span style={{ color: a.color, fontSize: 26, textShadow: `0 0 12px ${a.color}` }}>{a.icon}</span>
                  ) : (
                    <Lock size={18} color="#8A7F76" />
                  )}
                </div>
                <div className="text-center" style={{ color: a.unlocked ? "#F5F1E8" : "#8A7F76", fontSize: 10, fontWeight: 600 }}>
                  {a.name}
                </div>
              </button>
            ))}
          </div>
        </GlassPanel>
      </div>

      {/* CTA */}
      <button onClick={onOpenAchievements} className="w-full h-12 rounded-lg flex items-center justify-center gap-2 active:scale-[0.99] transition-transform" style={{
        background: "#1A1414", border: "1px solid #2A1F1F", color: "#F5F1E8", fontWeight: 600, fontSize: 13,
      }}>
        <Trophy size={16} color="#FFD300" /> View All Achievements
      </button>
    </div>
  );
}

function Stat({ v, l, color, icon }: { v: string; l: string; color: string; icon?: any }) {
  return (
    <div className="p-4 rounded-xl relative overflow-hidden" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
      <div className="absolute -right-4 -top-4 size-16 rounded-full" style={{ background: `${color}11` }} />
      <div className="flex items-center gap-1">
        {icon}
        <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 600 }}>{l}</div>
      </div>
      <div className="mt-1" style={{ color, fontSize: 26, fontWeight: 900, letterSpacing: "-0.02em", lineHeight: 1.1 }}>{v}</div>
    </div>
  );
}

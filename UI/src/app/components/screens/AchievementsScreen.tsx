import { useState } from "react";
import { motion } from "motion/react";
import { ArrowLeft, Lock, Check, Trophy, Search } from "lucide-react";
import { GlassPanel } from "../ui-bits";

type Category = "All" | "Discovery" | "Mastery" | "Streak" | "Legend";

type Achievement = {
  id: string;
  name: string;
  desc: string;
  icon: string;
  color: string;
  category: Exclude<Category, "All">;
  prog: number;
  total: number;
  xp: number;
  tier: "Bronze" | "Silver" | "Gold" | "Mythic";
  unlocked: boolean;
  date?: string;
};

const ACHIEVEMENTS: Achievement[] = [
  { id: "a1", name: "First Scan", desc: "Awaken your first creature.", icon: "✦", color: "#E60012", category: "Discovery", prog: 1, total: 1, xp: 25, tier: "Bronze", unlocked: true, date: "Apr 30, 2026" },
  { id: "a2", name: "Rare Note", desc: "Discover a Rare specimen.", icon: "◆", color: "#3BA7FF", category: "Discovery", prog: 1, total: 1, xp: 50, tier: "Silver", unlocked: true, date: "May 2, 2026" },
  { id: "a3", name: "7 Day Flame", desc: "Maintain a 7-day streak.", icon: "▲", color: "#FF6B4A", category: "Streak", prog: 7, total: 7, xp: 80, tier: "Silver", unlocked: true, date: "May 6, 2026" },
  { id: "a4", name: "Nature Master", desc: "Catalog 5 Nature creatures.", icon: "❋", color: "#43D17A", category: "Mastery", prog: 5, total: 5, xp: 100, tier: "Gold", unlocked: true, date: "May 5, 2026" },
  { id: "a5", name: "Shard Smith", desc: "Convert 10 duplicates into shards.", icon: "✧", color: "#FFD300", category: "Mastery", prog: 10, total: 10, xp: 75, tier: "Silver", unlocked: true, date: "May 7, 2026" },
  { id: "a6", name: "Legend Hunter", desc: "Awaken a Legendary specimen.", icon: "★", color: "#FFD300", category: "Legend", prog: 0, total: 1, xp: 250, tier: "Mythic", unlocked: false },
  { id: "a7", name: "Field Cartographer", desc: "Scan from 10 different locations.", icon: "◈", color: "#9DD8FF", category: "Discovery", prog: 6, total: 10, xp: 120, tier: "Gold", unlocked: false },
  { id: "a8", name: "Twilight Caller", desc: "Awaken 20 creatures after sunset.", icon: "☾", color: "#8B6CFF", category: "Mastery", prog: 14, total: 20, xp: 90, tier: "Silver", unlocked: false },
  { id: "a9", name: "Eternal Flame", desc: "Reach a 30-day streak.", icon: "🜂", color: "#FFA947", category: "Streak", prog: 9, total: 30, xp: 200, tier: "Gold", unlocked: false },
  { id: "a10", name: "Bestiary Complete", desc: "Catalog 100 unique specimens.", icon: "✺", color: "#FFD300", category: "Legend", prog: 42, total: 100, xp: 500, tier: "Mythic", unlocked: false },
];

const TIER_COLOR: Record<Achievement["tier"], string> = {
  Bronze: "#B8895B",
  Silver: "#C9C2B5",
  Gold: "#FFD300",
  Mythic: "#FFD300",
};

export function AchievementsScreen({ onBack }: { onBack: () => void }) {
  const [cat, setCat] = useState<Category>("All");
  const [selected, setSelected] = useState<Achievement | null>(null);

  const items = ACHIEVEMENTS.filter(a => cat === "All" || a.category === cat);
  const unlocked = ACHIEVEMENTS.filter(a => a.unlocked).length;
  const totalXp = ACHIEVEMENTS.filter(a => a.unlocked).reduce((s, a) => s + a.xp, 0);
  const pct = Math.round((unlocked / ACHIEVEMENTS.length) * 100);

  return (
    <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>
      {/* Header */}
      <div className="relative px-5 pt-3 pb-5" style={{
        background: "radial-gradient(ellipse at 50% 0%, #FFD30022, transparent 60%), linear-gradient(180deg, #15100F, #0A0A0A)",
      }}>
        <div className="flex items-center justify-between">
          <button onClick={onBack} className="size-10 rounded-full grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
            <ArrowLeft size={18} color="#F5F1E8" />
          </button>
          <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.2em", fontWeight: 600 }}>HALL OF MERIT</div>
          <div className="size-10" />
        </div>

        <div className="mt-4 text-center relative">
          <div className="absolute inset-x-0 -top-1 select-none pointer-events-none" style={{
            color: "#FFD300", opacity: 0.1, fontSize: 60, fontWeight: 900, letterSpacing: "-0.05em", lineHeight: 1,
          }}>{pct}%</div>
          <h1 className="relative" style={{ color: "#F5F1E8", fontSize: 28, fontWeight: 800, letterSpacing: "-0.02em" }}>
            Achievements
          </h1>
        </div>

        {/* progress card */}
        <div className="mt-4 p-4 rounded-2xl relative overflow-hidden" style={{
          background: "linear-gradient(135deg, #1a1a30 0%, #15100F 70%)",
          border: "1px solid #FFD30033",
        }}>
          <div className="absolute -right-6 -top-6 size-32 rounded-full" style={{ background: "#FFD30022", filter: "blur(28px)" }} />
          <div className="relative flex items-center gap-4">
            {/* radial */}
            <div className="relative size-20 shrink-0">
              <svg viewBox="0 0 80 80" className="size-20 -rotate-90">
                <circle cx="40" cy="40" r="34" fill="none" stroke="#2A1F1F" strokeWidth="6" />
                <circle cx="40" cy="40" r="34" fill="none" stroke="url(#ach-grad)" strokeWidth="6" strokeLinecap="round"
                  strokeDasharray={`${(pct/100)*213.6} 213.6`} />
                <defs>
                  <linearGradient id="ach-grad" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#FFD300" />
                    <stop offset="100%" stopColor="#E60012" />
                  </linearGradient>
                </defs>
              </svg>
              <div className="absolute inset-0 grid place-items-center">
                <span style={{ color: "#FFD300", fontSize: 18, fontWeight: 900 }}>{pct}%</span>
              </div>
            </div>
            <div className="flex-1">
              <div style={{ color: "#F5F1E8", fontSize: 16, fontWeight: 800 }}>{unlocked} of {ACHIEVEMENTS.length} unlocked</div>
              <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 2 }}>+{totalXp} lifetime XP earned</div>
              <div className="mt-2 flex items-center gap-3">
                <div className="flex items-center gap-1">
                  <span className="size-2 rounded-full" style={{ background: "#FFD300" }} />
                  <span style={{ color: "#C9C2B5", fontSize: 10, fontWeight: 600 }}>2 GOLD</span>
                </div>
                <div className="flex items-center gap-1">
                  <span className="size-2 rounded-full" style={{ background: "#C9C2B5" }} />
                  <span style={{ color: "#C9C2B5", fontSize: 10, fontWeight: 600 }}>3 SILVER</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="px-5 pb-12">
        {/* Categories */}
        <div className="-mx-5 px-5 overflow-x-auto no-scrollbar">
          <div className="flex gap-1.5 pb-1">
            {(["All", "Discovery", "Mastery", "Streak", "Legend"] as Category[]).map((c) => (
              <button key={c} onClick={() => setCat(c)} className="shrink-0 px-3 py-1.5 rounded-full" style={{
                background: cat === c ? "#FFD300" : "#1A1414",
                color: cat === c ? "#0A0A0A" : "#C9C2B5",
                border: `1px solid ${cat === c ? "#FFD300" : "#2A1F1F"}`,
                fontSize: 11, fontWeight: 700, letterSpacing: "0.08em",
              }}>{c.toUpperCase()}</button>
            ))}
          </div>
        </div>

        {/* search */}
        <div className="mt-3 flex items-center gap-2 px-3 h-10 rounded-lg" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
          <Search size={14} color="#8A7F76" />
          <input placeholder="Search achievements..." className="flex-1 bg-transparent outline-none" style={{ color: "#F5F1E8", fontSize: 13 }} />
        </div>

        {/* List */}
        <div className="mt-4 space-y-2">
          {items.map((a) => {
            const tierColor = TIER_COLOR[a.tier];
            const pct = Math.min(100, (a.prog / a.total) * 100);
            return (
              <button key={a.id} onClick={() => setSelected(a)}
                className="w-full p-3 rounded-xl flex items-center gap-3 text-left active:scale-[0.99] transition-transform"
                style={{
                  background: a.unlocked ? "#15100F" : "#15100F",
                  border: `1px solid ${a.unlocked ? `${a.color}44` : "#2A1F1F"}`,
                  opacity: a.unlocked ? 1 : 0.85,
                }}
              >
                <div className="relative shrink-0">
                  <div className="size-14 rounded-full grid place-items-center" style={{
                    background: a.unlocked ? `radial-gradient(circle, ${a.color}33, #15100F)` : "#15100F",
                    border: `2px solid ${a.unlocked ? a.color : "#2A1F1F"}`,
                    boxShadow: a.unlocked ? `0 0 14px ${a.color}55` : "none",
                  }}>
                    {a.unlocked ? (
                      <span style={{ color: a.color, fontSize: 22, textShadow: `0 0 10px ${a.color}` }}>{a.icon}</span>
                    ) : (
                      <Lock size={16} color="#8A7F76" />
                    )}
                  </div>
                  {/* tier ribbon */}
                  <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 px-1.5 py-0.5 rounded-sm" style={{
                    background: a.unlocked ? tierColor : "#2A1F1F",
                    color: a.unlocked ? "#0A0A0A" : "#8A7F76",
                    fontSize: 8, fontWeight: 900, letterSpacing: "0.15em",
                  }}>{a.tier.toUpperCase()}</div>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span style={{ color: a.unlocked ? "#F5F1E8" : "#C9C2B5", fontSize: 14, fontWeight: 700 }}>{a.name}</span>
                    {a.unlocked && <Check size={12} color="#43D17A" strokeWidth={3} />}
                  </div>
                  <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 1 }}>{a.desc}</div>
                  {!a.unlocked && (
                    <div className="mt-2 flex items-center gap-2">
                      <div className="flex-1 h-1 rounded-full" style={{ background: "#1A1414" }}>
                        <div className="h-full rounded-full" style={{ width: `${pct}%`, background: a.color }} />
                      </div>
                      <span style={{ color: "#8A7F76", fontSize: 10, fontWeight: 600 }}>{a.prog}/{a.total}</span>
                    </div>
                  )}
                </div>
                <div className="text-right shrink-0">
                  <div style={{ color: "#FFD300", fontSize: 12, fontWeight: 800 }}>+{a.xp}</div>
                  <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.15em", fontWeight: 600 }}>XP</div>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Detail modal */}
      {selected && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          onClick={() => setSelected(null)}
          className="absolute inset-0 z-50 grid place-items-center p-5"
          style={{ background: "rgba(5,7,13,0.85)", backdropFilter: "blur(8px)" }}
        >
          <motion.div
            initial={{ scale: 0.85, y: 10 }} animate={{ scale: 1, y: 0 }}
            onClick={(e) => e.stopPropagation()}
            className="w-full rounded-2xl p-6 relative overflow-hidden"
            style={{
              background: `linear-gradient(180deg, ${selected.color}22, #15100F 60%)`,
              border: `1px solid ${selected.color}55`,
            }}
          >
            {/* rays */}
            {selected.unlocked && [...Array(6)].map((_, i) => (
              <div key={i} className="absolute left-1/2 top-1/2 origin-top pointer-events-none" style={{
                width: 1, height: 200, background: `linear-gradient(180deg, ${selected.color}88, transparent)`,
                transform: `translateX(-50%) rotate(${(i - 3) * 18}deg)`, opacity: 0.3,
              }} />
            ))}
            <div className="relative text-center">
              <div className="mx-auto size-24 rounded-full grid place-items-center" style={{
                background: selected.unlocked ? `radial-gradient(circle, ${selected.color}66, #15100F)` : "#15100F",
                border: `3px solid ${selected.unlocked ? selected.color : "#2A1F1F"}`,
                boxShadow: selected.unlocked ? `0 0 30px ${selected.color}88` : "none",
              }}>
                {selected.unlocked ? (
                  <span style={{ color: selected.color, fontSize: 44, textShadow: `0 0 18px ${selected.color}` }}>{selected.icon}</span>
                ) : (
                  <Lock size={28} color="#8A7F76" />
                )}
              </div>
              <div className="mt-3 inline-block px-2 py-0.5 rounded-sm" style={{
                background: TIER_COLOR[selected.tier], color: "#0A0A0A", fontSize: 10, fontWeight: 900, letterSpacing: "0.2em",
              }}>{selected.tier.toUpperCase()} TIER</div>
              <h2 className="mt-2" style={{ color: "#F5F1E8", fontSize: 22, fontWeight: 800, letterSpacing: "-0.01em" }}>{selected.name}</h2>
              <p className="mt-1" style={{ color: "#C9C2B5", fontSize: 13, lineHeight: 1.5 }}>{selected.desc}</p>

              <div className="mt-4 p-3 rounded-lg" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
                {selected.unlocked ? (
                  <>
                    <div style={{ color: "#43D17A", fontSize: 11, letterSpacing: "0.2em", fontWeight: 700 }}>UNLOCKED</div>
                    <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600, marginTop: 2 }}>{selected.date}</div>
                  </>
                ) : (
                  <>
                    <div className="flex items-center justify-between">
                      <span style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.15em", fontWeight: 600 }}>PROGRESS</span>
                      <span style={{ color: "#F5F1E8", fontSize: 12, fontWeight: 700 }}>{selected.prog} / {selected.total}</span>
                    </div>
                    <div className="mt-2 h-1.5 rounded-full" style={{ background: "#1A1414" }}>
                      <div className="h-full rounded-full" style={{ width: `${(selected.prog/selected.total)*100}%`, background: selected.color }} />
                    </div>
                  </>
                )}
              </div>

              <div className="mt-3 flex items-center justify-center gap-2">
                <Trophy size={14} color="#FFD300" />
                <span style={{ color: "#FFD300", fontSize: 13, fontWeight: 800 }}>+{selected.xp} XP</span>
              </div>

              <button onClick={() => setSelected(null)} className="mt-5 w-full h-11 rounded-lg" style={{
                background: "#1A1414", border: "1px solid #2A1F1F", color: "#F5F1E8", fontWeight: 600, fontSize: 13,
              }}>Close</button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </div>
  );
}

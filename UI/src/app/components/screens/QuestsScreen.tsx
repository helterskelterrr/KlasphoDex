import { useState } from "react";
import { motion } from "motion/react";
import { Flame, Target, Star, Leaf, Zap, Moon, Sparkles, Lock, Check, Clock, Trophy, Gift, ChevronRight } from "lucide-react";
import { GlassPanel } from "../ui-bits";

type Tab = "daily" | "weekly" | "saga";

const DAILY = [
  { id: "d1", icon: <Target size={16} color="#E60012" />, title: "Scan 3 objects", prog: 1, total: 3, xp: 30, reward: null },
  { id: "d2", icon: <Star size={16} color="#FFD300" />, title: "Find a Rare or higher", prog: 0, total: 1, xp: 50, reward: null },
  { id: "d3", icon: <Leaf size={16} color="#43D17A" />, title: "Scan a Nature type", prog: 0, total: 1, xp: 25, reward: null },
  { id: "d4", icon: <Sparkles size={16} color="#FFD300" />, title: "Awaken before sunset", prog: 1, total: 1, xp: 40, reward: "claim" },
];

const WEEKLY = [
  { id: "w1", icon: <Zap size={18} color="#FFE15A" />, title: "Spark Surge", desc: "Discover 4 Electric specimens", prog: 2, total: 4, xp: 220, gold: 80, expires: "4d 12h" },
  { id: "w2", icon: <Moon size={18} color="#8B6CFF" />, title: "Twilight Census", desc: "Scan 10 objects after 8pm", prog: 6, total: 10, xp: 180, gold: 60, expires: "4d 12h" },
  { id: "w3", icon: <Flame size={18} color="#FF6B4A" />, title: "Hearthbound", desc: "Maintain a 7-day streak", prog: 7, total: 7, xp: 300, gold: 120, expires: "claim" },
];

const SAGA = [
  { id: "s1", title: "The First Awakening", desc: "Awaken your first 5 creatures", prog: 5, total: 5, status: "done" as const, reward: "Lens Mark · Bronze" },
  { id: "s2", title: "Ink & Ember", desc: "Discover one of each elemental class", prog: 6, total: 8, status: "active" as const, reward: "Title · Elementalist" },
  { id: "s3", title: "Specimen 100", desc: "Catalog 100 unique creatures", prog: 42, total: 100, status: "active" as const, reward: "Journal · Volume II" },
  { id: "s4", title: "Legend Hunter", desc: "Awaken a Legendary specimen", prog: 0, total: 1, status: "locked" as const, reward: "Mythic Frame" },
];

export function QuestsScreen() {
  const [tab, setTab] = useState<Tab>("daily");

  return (
    <div className="px-5 pt-3 pb-28 space-y-4">
      {/* Header */}
      <div className="flex items-end justify-between">
        <div>
          <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.2em", fontWeight: 600 }}>FIELD ASSIGNMENTS</div>
          <h1 style={{ color: "#F5F1E8", fontSize: 26, fontWeight: 800, lineHeight: 1, marginTop: 2 }}>Quests</h1>
        </div>
        <div className="flex items-center gap-1 px-2.5 py-1 rounded-md" style={{ background: "#1A1414", border: "1px solid #FFD30033" }}>
          <Trophy size={12} color="#FFD300" />
          <span style={{ color: "#FFD300", fontSize: 11, fontWeight: 700 }}>3 READY</span>
        </div>
      </div>

      {/* Resource banner */}
      <div className="relative overflow-hidden rounded-2xl p-4" style={{
        background: "linear-gradient(135deg, #1a1530 0%, #15100F 70%)",
        border: "1px solid #FFD30044",
      }}>
        <div className="absolute -right-4 -top-4 size-32 rounded-full" style={{ background: "#FFD30022", filter: "blur(24px)" }} />
        <div className="relative flex items-center gap-3">
          <div className="size-12 rounded-xl grid place-items-center" style={{
            background: "radial-gradient(circle, #FFD300, #4d2a85)", boxShadow: "0 0 16px #FFD30066",
          }}>
            <span style={{ color: "#fff", fontSize: 22, fontWeight: 900 }}>◆</span>
          </div>
          <div className="flex-1">
            <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 700 }}>Season Pass · Aether Bloom</div>
            <div style={{ color: "#C9C2B5", fontSize: 11, marginTop: 2 }}>Tier 4 · 320 / 500 to next reward</div>
            <div className="mt-2 h-1.5 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
              <div className="h-full" style={{ width: "64%", background: "linear-gradient(90deg, #FFD300, #E60012)" }} />
            </div>
          </div>
          <ChevronRight size={16} color="#FFD300" />
        </div>
      </div>

      {/* Tabs */}
      <div className="flex p-1 rounded-lg" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
        {(["daily", "weekly", "saga"] as Tab[]).map((t) => (
          <button key={t} onClick={() => setTab(t)} className="flex-1 h-9 rounded-md relative" style={{
            color: tab === t ? "#0A0A0A" : "#C9C2B5", fontSize: 11, fontWeight: 800, letterSpacing: "0.15em",
          }}>
            {tab === t && (
              <motion.div layoutId="quest-tab" className="absolute inset-0 rounded-md" style={{
                background: "#E60012", boxShadow: "0 2px 12px #E6001255",
              }} />
            )}
            <span className="relative">{t.toUpperCase()}</span>
          </button>
        ))}
      </div>

      {/* Reset banner */}
      <div className="flex items-center justify-between px-3 py-2 rounded-lg" style={{ background: "#15100F", border: "1px dashed #2A1F1F" }}>
        <div className="flex items-center gap-2">
          <Clock size={12} color="#8A7F76" />
          <span style={{ color: "#C9C2B5", fontSize: 11 }}>
            {tab === "daily" ? "Resets in 14h 22m" : tab === "weekly" ? "Resets in 4d 12h" : "Long-form expedition"}
          </span>
        </div>
        <span style={{ color: "#E60012", fontSize: 10, letterSpacing: "0.15em", fontWeight: 700 }}>
          {tab === "daily" ? `${DAILY.filter(d => d.prog >= d.total).length}/${DAILY.length} DONE` : tab === "weekly" ? `${WEEKLY.filter(w => w.prog >= w.total).length}/${WEEKLY.length} DONE` : "2/4 ACTIVE"}
        </span>
      </div>

      {/* Content */}
      {tab === "daily" && (
        <GlassPanel>
          {DAILY.map((q, i) => {
            const done = q.prog >= q.total;
            const pct = (q.prog / q.total) * 100;
            return (
              <div key={q.id} className="p-3.5 flex items-center gap-3" style={{
                borderTop: i === 0 ? "none" : "1px solid #2A1F1F",
              }}>
                <div className="size-10 rounded-lg grid place-items-center shrink-0 relative" style={{
                  background: done ? "#0e2418" : "#1A1414", border: `1px solid ${done ? "#43D17A55" : "#2A1F1F"}`,
                }}>
                  {done ? <Check size={16} color="#43D17A" strokeWidth={3} /> : q.icon}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-baseline justify-between gap-2">
                    <span style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>{q.title}</span>
                    <span style={{ color: "#8A7F76", fontSize: 11, fontWeight: 600 }}>{q.prog}/{q.total}</span>
                  </div>
                  <div className="mt-1.5 h-1 rounded-full" style={{ background: "#1A1414" }}>
                    <div className="h-full rounded-full" style={{
                      width: `${pct}%`,
                      background: done ? "#43D17A" : "#E60012",
                      boxShadow: done ? "0 0 6px #43D17A88" : "none",
                    }} />
                  </div>
                </div>
                {q.reward === "claim" ? (
                  <button className="px-3 h-8 rounded-md shrink-0" style={{
                    background: "#FFD300", color: "#0A0A0A",
                    fontSize: 10, fontWeight: 800, letterSpacing: "0.15em", boxShadow: "0 4px 12px #FFD30055",
                  }}>CLAIM</button>
                ) : (
                  <div className="text-right shrink-0">
                    <div style={{ color: "#FFD300", fontSize: 12, fontWeight: 800 }}>+{q.xp}</div>
                    <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.15em", fontWeight: 600 }}>XP</div>
                  </div>
                )}
              </div>
            );
          })}
        </GlassPanel>
      )}

      {tab === "weekly" && (
        <div className="space-y-3">
          {WEEKLY.map((q) => {
            const done = q.prog >= q.total;
            const pct = (q.prog / q.total) * 100;
            return (
              <div key={q.id} className="relative overflow-hidden rounded-xl p-4" style={{
                background: "linear-gradient(180deg, #221818, #15100F)",
                border: `1px solid ${done ? "#FFD30055" : "#2A1F1F"}`,
              }}>
                {done && (
                  <div className="absolute right-3 top-3 px-2 py-0.5 rounded-sm" style={{
                    background: "#FFD300", color: "#0A0A0A", fontSize: 9, fontWeight: 900, letterSpacing: "0.2em",
                    transform: "rotate(4deg)",
                  }}>READY</div>
                )}
                <div className="flex items-start gap-3">
                  <div className="size-12 rounded-xl grid place-items-center shrink-0" style={{
                    background: "#1A1414", border: "1px solid #2A1F1F",
                  }}>{q.icon}</div>
                  <div className="flex-1 min-w-0">
                    <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 700 }}>{q.title}</div>
                    <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 2 }}>{q.desc}</div>
                  </div>
                </div>
                <div className="mt-3 flex items-center justify-between gap-2">
                  <div className="flex-1 h-1.5 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
                    <div className="h-full" style={{
                      width: `${pct}%`,
                      background: done ? "linear-gradient(90deg, #FFD300, #FFA947)" : "linear-gradient(90deg, #E60012, #8B0008)",
                    }} />
                  </div>
                  <span style={{ color: "#C9C2B5", fontSize: 11, fontWeight: 600 }}>{q.prog}/{q.total}</span>
                </div>
                <div className="mt-3 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="flex items-center gap-1 px-2 py-1 rounded" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
                      <span style={{ color: "#FFD300", fontSize: 11, fontWeight: 800 }}>+{q.xp}</span>
                      <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.15em", fontWeight: 600 }}>XP</span>
                    </div>
                    <div className="flex items-center gap-1 px-2 py-1 rounded" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
                      <span style={{ color: "#FFD300", fontSize: 12 }}>◆</span>
                      <span style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 700 }}>{q.gold}</span>
                    </div>
                  </div>
                  {done ? (
                    <button className="px-3 h-8 rounded-md flex items-center gap-1" style={{
                      background: "#FFD300", color: "#0A0A0A",
                      fontSize: 10, fontWeight: 800, letterSpacing: "0.15em", boxShadow: "0 4px 12px #FFD30055",
                    }}>
                      <Gift size={12} /> CLAIM
                    </button>
                  ) : (
                    <div className="flex items-center gap-1" style={{ color: "#8A7F76", fontSize: 10, fontWeight: 600 }}>
                      <Clock size={10} /> {q.expires}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {tab === "saga" && (
        <div className="relative space-y-0">
          {/* connector line */}
          <div className="absolute left-[27px] top-6 bottom-6 w-px" style={{ background: "linear-gradient(180deg, #2A1F1F, #2A1F1F 95%, transparent)" }} />
          {SAGA.map((q, i) => {
            const locked = q.status === "locked";
            const done = q.status === "done";
            const pct = (q.prog / q.total) * 100;
            const accent = done ? "#43D17A" : locked ? "#8A7F76" : "#E60012";
            return (
              <div key={q.id} className="relative pl-14 pb-4">
                {/* node */}
                <div className="absolute left-0 top-2">
                  <div className="size-14 rounded-full grid place-items-center relative" style={{
                    background: done ? "#0e2418" : locked ? "#15100F" : "#1F1414",
                    border: `2px solid ${accent}`,
                    boxShadow: done || !locked ? `0 0 14px ${accent}55` : "none",
                  }}>
                    {locked ? <Lock size={18} color={accent} /> : done ? <Check size={20} color={accent} strokeWidth={3} /> : (
                      <div style={{ color: accent, fontSize: 16, fontWeight: 900 }}>{String(i + 1).padStart(2, "0")}</div>
                    )}
                  </div>
                </div>
                <div className="rounded-xl p-3.5" style={{
                  background: locked ? "#15100F" : "linear-gradient(180deg, #221818, #15100F)",
                  border: `1px solid ${locked ? "#2A1F1F" : `${accent}33`}`,
                  opacity: locked ? 0.65 : 1,
                }}>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex-1">
                      <div style={{ color: accent, fontSize: 10, letterSpacing: "0.2em", fontWeight: 700 }}>
                        CHAPTER {String(i + 1).padStart(2, "0")} · {q.status.toUpperCase()}
                      </div>
                      <div style={{ color: "#F5F1E8", fontSize: 15, fontWeight: 800, marginTop: 2, letterSpacing: "-0.01em" }}>{q.title}</div>
                      <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 2 }}>{q.desc}</div>
                    </div>
                  </div>
                  {!locked && (
                    <>
                      <div className="mt-3 flex items-center gap-2">
                        <div className="flex-1 h-1.5 rounded-full overflow-hidden" style={{ background: "#1A1414" }}>
                          <div className="h-full" style={{ width: `${pct}%`, background: accent }} />
                        </div>
                        <span style={{ color: "#C9C2B5", fontSize: 11, fontWeight: 600 }}>{q.prog}/{q.total}</span>
                      </div>
                    </>
                  )}
                  <div className="mt-2.5 flex items-center gap-1.5">
                    <Gift size={11} color="#FFD300" />
                    <span style={{ color: "#FFD300", fontSize: 11, fontWeight: 600 }}>{q.reward}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

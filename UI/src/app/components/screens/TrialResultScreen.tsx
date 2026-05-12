import { motion } from "motion/react";
import { Repeat, Edit3, Home, Trophy, AlertTriangle, Camera, Sparkles } from "lucide-react";
import { COLLECTION, DIFFICULTIES, Difficulty } from "../trial-data";
import { CreaturePortrait } from "../CreaturePortrait";

export function TrialResultScreen({
  victory, difficulty, deckIds, turns, defeatReason,
  onRetry, onEdit, onHome, onScan,
}: {
  victory: boolean; difficulty: Difficulty; deckIds: string[]; turns: number;
  defeatReason?: "resolve" | "timeout";
  onRetry: () => void; onEdit: () => void; onHome: () => void; onScan: () => void;
}) {
  const cfg = DIFFICULTIES[difficulty];
  const recipient = COLLECTION.find(c => c.id === deckIds[0]) || COLLECTION[0];
  const accent = victory ? "#FFD300" : "#FF6B4A";

  if (victory) {
    return (
      <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>
        {/* HERO */}
        <div className="relative pt-8 pb-6" style={{
          background: `radial-gradient(ellipse at 50% 30%, #FFD30033, transparent 60%), linear-gradient(180deg, #15100F, #0A0A0A)`,
        }}>
          {/* light rays */}
          {[...Array(8)].map((_, i) => (
            <motion.div key={i}
              initial={{ opacity: 0, scaleY: 0 }} animate={{ opacity: 0.18, scaleY: 1 }} transition={{ delay: 0.1 + i * 0.04, duration: 0.5 }}
              className="absolute left-1/2 top-1/4 origin-top pointer-events-none"
              style={{ width: 2, height: 320, background: `linear-gradient(180deg, #FFD300, transparent)`, transform: `translateX(-50%) rotate(${(i - 4) * 14}deg)` }} />
          ))}
          <div className="relative text-center">
            <motion.div initial={{ scale: 0.6, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} transition={{ type: "spring", stiffness: 160, damping: 14 }}
              className="mx-auto size-24 rounded-full grid place-items-center" style={{
                background: "radial-gradient(circle, #FFD300, #4d3a0e)", boxShadow: "0 0 40px #FFD30088, inset 0 0 20px #0A0A0A",
              }}>
              <Trophy size={36} color="#0A0A0A" strokeWidth={2.5} />
            </motion.div>
            <motion.div initial={{ y: 10, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.2 }} className="mt-4">
              <div style={{ color: "#FFD300", fontSize: 11, letterSpacing: "0.4em", fontWeight: 700 }}>VICTORY</div>
              <div className="relative inline-block mt-1">
                <span aria-hidden className="absolute inset-0 select-none" style={{
                  color: "#FFD300", opacity: 0.35, fontSize: 30, fontWeight: 900, letterSpacing: "-0.02em", transform: "translate(2px,2px) skewX(-6deg)",
                }}>ANOMALY STABILIZED</span>
                <span className="relative" style={{ color: "#F5F1E8", fontSize: 30, fontWeight: 900, letterSpacing: "-0.02em", display: "inline-block", transform: "skewX(-6deg)" }}>
                  ANOMALY STABILIZED
                </span>
              </div>
              <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 4 }}>Field data secured.</div>
            </motion.div>
          </div>
        </div>

        <div className="px-5 pb-32">
          {/* REWARD CHIPS */}
          <motion.div initial={{ y: 16, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.4 }}
            className="grid grid-cols-3 gap-2">
            <RewardChip label="XP GAINED" value={`+${cfg.xp}`} color="#FFD300" stamp />
            <RewardChip label="SHARDS" value={`◆ ${cfg.shards}`} color="#FFD300" stamp />
            <RewardChip label="TURNS" value={`${turns}`} color="#E60012" />
          </motion.div>

          {/* SHARD RECIPIENT */}
          <motion.div initial={{ y: 16, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.55 }}
            className="mt-4 p-4 rounded-xl flex items-center gap-3" style={{
              background: `linear-gradient(135deg, ${recipient.hue}22, #15100F)`,
              border: `1px solid ${recipient.hue}55`,
            }}>
            <div className="size-14 rounded-lg overflow-hidden shrink-0" style={{ background: "#0A0A0A" }}>
              <CreaturePortrait creature={recipient} size={56} />
            </div>
            <div className="flex-1">
              <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 700 }}>SHARDS APPLIED TO</div>
              <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 800, marginTop: 1 }}>{recipient.name}</div>
              <div style={{ color: "#FFD300", fontSize: 11, fontWeight: 700, marginTop: 1 }}>+{cfg.shards} Evolution Shards</div>
            </div>
            <Sparkles size={16} color="#FFD300" />
          </motion.div>

          {/* DECK PERFORMANCE */}
          <motion.div initial={{ y: 16, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.7 }}
            className="mt-4 p-4 rounded-xl" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
            <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.25em", fontWeight: 700 }}>FIELD REPORT</div>
            <div className="mt-2 space-y-1.5">
              <Row k="Difficulty" v={difficulty} />
              <Row k="Turns to stabilize" v={`${turns} / 7`} />
              <Row k="Deck size" v={`${deckIds.length} cards`} />
            </div>
          </motion.div>
        </div>

        <ResultCTAs primary={{ label: "RUN ANOTHER", icon: Repeat, onClick: onRetry }}
          secondary={[{ label: "Edit Deck", icon: Edit3, onClick: onEdit }, { label: "Home", icon: Home, onClick: onHome }]}
          color="#FFD300" />
      </div>
    );
  }

  // DEFEAT
  const reasonText = defeatReason === "resolve" ? "Resolve depleted." : "Turn limit reached.";
  const hint =
    defeatReason === "resolve" ? "Try more Earth cards for shield, or Water cards for healing."
    : "Add higher-power Fire or Electric cards to stabilize faster.";

  return (
    <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>
      <div className="relative pt-8 pb-6" style={{
        background: `radial-gradient(ellipse at 50% 30%, #FF6B4A22, transparent 60%), linear-gradient(180deg, #15100F, #0A0A0A)`,
      }}>
        {/* distortion lines */}
        {[...Array(6)].map((_, i) => (
          <motion.div key={i}
            initial={{ opacity: 0, x: -50 }} animate={{ opacity: 0.2, x: 0 }} transition={{ delay: i * 0.06, duration: 0.4 }}
            className="absolute left-0 right-0 h-px"
            style={{ top: `${20 + i * 8}%`, background: "linear-gradient(90deg, transparent, #FF6B4A, transparent)", transform: `skewY(${i % 2 ? -2 : 2}deg)` }} />
        ))}
        <div className="relative text-center">
          <motion.div initial={{ scale: 0.7, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
            className="mx-auto size-24 rounded-full grid place-items-center" style={{
              background: "radial-gradient(circle, #FFD30055, #1a0d22)", border: "2px solid #FF6B4A88",
              boxShadow: "0 0 30px #FF6B4A55",
            }}>
            <AlertTriangle size={32} color="#FF6B4A" strokeWidth={2.5} />
          </motion.div>
          <div className="mt-4">
            <div style={{ color: "#FF6B4A", fontSize: 11, letterSpacing: "0.4em", fontWeight: 700 }}>DEFEAT</div>
            <div className="relative inline-block mt-1">
              <span aria-hidden className="absolute inset-0 select-none" style={{
                color: "#FF6B4A", opacity: 0.35, fontSize: 30, fontWeight: 900, letterSpacing: "-0.02em", transform: "translate(2px,2px) skewX(-6deg)",
              }}>SIGNAL LOST</span>
              <span className="relative" style={{ color: "#F5F1E8", fontSize: 30, fontWeight: 900, letterSpacing: "-0.02em", display: "inline-block", transform: "skewX(-6deg)" }}>
                SIGNAL LOST
              </span>
            </div>
            <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 4 }}>The anomaly slipped beyond scanner range.</div>
          </div>
        </div>
      </div>

      <div className="px-5 pb-32">
        {/* Reason card */}
        <div className="p-4 rounded-xl flex items-center gap-3" style={{
          background: "linear-gradient(135deg, #1a0d10, #15100F)", border: "1px solid #FF6B4A44",
        }}>
          <div className="size-10 rounded-lg grid place-items-center" style={{ background: "#2a0d10", border: "1px solid #FF6B4A55" }}>
            <AlertTriangle size={16} color="#FF6B4A" />
          </div>
          <div>
            <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 700 }}>REASON</div>
            <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 700, marginTop: 1 }}>{reasonText}</div>
          </div>
        </div>

        {/* Practical hint */}
        <div className="mt-3 p-4 rounded-xl" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
          <div style={{ color: "#E60012", fontSize: 10, letterSpacing: "0.25em", fontWeight: 700 }}>FIELD ADVICE</div>
          <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600, marginTop: 6, lineHeight: 1.5 }}>{hint}</div>
          <div className="mt-3 flex flex-wrap gap-1.5">
            {["Earth · Guard", "Water · Mend", "Fire · Burn", "Electric · Spark"].map((t) => (
              <span key={t} className="px-2 py-1 rounded text-[11px]" style={{
                background: "#15100F", border: "1px solid #2A1F1F", color: "#C9C2B5", fontWeight: 600,
              }}>{t}</span>
            ))}
          </div>
        </div>
      </div>

      <ResultCTAs primary={{ label: "RETRY TRIAL", icon: Repeat, onClick: onRetry }}
        secondary={[
          { label: "Edit Deck", icon: Edit3, onClick: onEdit },
          { label: "Scan", icon: Camera, onClick: onScan },
        ]}
        color="#FF6B4A" />
    </div>
  );
}

function RewardChip({ label, value, color, stamp }: { label: string; value: string; color: string; stamp?: boolean }) {
  return (
    <motion.div initial={{ scale: 0.85, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
      className="relative p-3 rounded-xl text-center overflow-hidden" style={{
        background: `linear-gradient(180deg, ${color}22, #15100F)`,
        border: `1px solid ${color}55`,
      }}>
      {stamp && (
        <div className="absolute -right-3 -top-1 px-1.5 py-0.5 rounded-sm" style={{
          background: color, color: "#0A0A0A", fontSize: 8, fontWeight: 900, letterSpacing: "0.15em",
          transform: "rotate(8deg)",
        }}>NEW</div>
      )}
      <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.2em", fontWeight: 700 }}>{label}</div>
      <div style={{ color, fontSize: 18, fontWeight: 900, lineHeight: 1.1, marginTop: 4 }}>{value}</div>
    </motion.div>
  );
}

function Row({ k, v }: { k: string; v: string }) {
  return (
    <div className="flex items-center justify-between">
      <span style={{ color: "#8A7F76", fontSize: 12 }}>{k}</span>
      <span style={{ color: "#F5F1E8", fontSize: 12, fontWeight: 700 }}>{v}</span>
    </div>
  );
}

function ResultCTAs({ primary, secondary, color }: {
  primary: { label: string; icon: any; onClick: () => void };
  secondary: { label: string; icon: any; onClick: () => void }[];
  color: string;
}) {
  const PIcon = primary.icon;
  return (
    <div className="absolute left-0 right-0 bottom-0 px-5 pt-3 pb-4 z-30 space-y-2" style={{
      background: "linear-gradient(180deg, transparent, #0A0A0A 30%)",
    }}>
      <button onClick={primary.onClick} className="w-full h-13 py-3.5 rounded-xl flex items-center justify-center gap-2" style={{
        background: `linear-gradient(135deg, ${color}, #FFA947)`,
        color: "#0A0A0A", fontWeight: 900, letterSpacing: "0.15em", fontSize: 13,
        boxShadow: `0 8px 22px ${color}55`,
      }}>
        <PIcon size={16} /> {primary.label}
      </button>
      <div className="grid grid-cols-2 gap-2">
        {secondary.map((s) => {
          const Icon = s.icon;
          return (
            <button key={s.label} onClick={s.onClick} className="h-11 rounded-xl flex items-center justify-center gap-2" style={{
              background: "#1A1414", border: "1px solid #2A1F1F", color: "#F5F1E8", fontWeight: 600, fontSize: 13,
            }}>
              <Icon size={14} /> {s.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

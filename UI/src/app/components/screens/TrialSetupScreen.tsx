import { useMemo, useState } from "react";
import { motion } from "motion/react";
import { ArrowLeft, Edit3, Play, Heart, Swords, Trophy, Sparkles, AlertTriangle, Zap } from "lucide-react";
import { COLLECTION, DIFFICULTIES, Difficulty } from "../trial-data";
import { ELEMENT_COLORS, Element } from "../creature-data";

export function TrialSetupScreen({
  deckIds, onBack, onEdit, onStart,
}: { deckIds: string[]; onBack: () => void; onEdit: () => void; onStart: (d: Difficulty) => void }) {
  const [diff, setDiff] = useState<Difficulty>("Wild");
  const cfg = DIFFICULTIES[diff];

  const deckCards = useMemo(() => deckIds.map(id => COLLECTION.find(c => c.id === id)!).filter(Boolean), [deckIds]);
  const avgPower = Math.round(deckCards.reduce((s, c) => s + c.power, 0) / Math.max(deckCards.length, 1));
  const typeMix = deckCards.reduce((acc, c) => { acc[c.element] = (acc[c.element] || 0) + 1; return acc; }, {} as Record<Element, number>);

  const ready = avgPower >= cfg.rec;
  const hint = ready
    ? "Deck power exceeds the recommended signal threshold."
    : avgPower >= cfg.rec - 10
      ? "Deck power is close. Add Earth or Water cards for survival."
      : "Average deck power is below recommended. Scan for stronger creatures.";

  return (
    <div className="absolute inset-0 overflow-y-auto cl-halftone-light" style={{ background: "#0A0A0A" }}>

      {/* ── HERO HEADER ── */}
      <div
        className="relative overflow-hidden cl-hatch"
        style={{
          background: "#15100F",
          borderBottom: `3px solid ${cfg.color}`,
        }}
      >
        {/* Large starburst watermark behind anomaly orb */}
        <div
          className="absolute pointer-events-none"
          style={{
            width: 320, height: 320,
            left: "50%", top: -30,
            transform: "translateX(-50%)",
            background: cfg.color,
            clipPath: "polygon(50% 0%,61% 35%,98% 35%,68% 57%,79% 91%,50% 70%,21% 91%,32% 57%,2% 35%,39% 35%)",
            opacity: 0.07,
            transition: "background 0.4s",
          }}
        />
        {/* Diagonal slash accents — top-right corner */}
        <div className="absolute right-0 top-0 pointer-events-none" style={{
          width: 100, height: 100,
          background: cfg.color,
          clipPath: "polygon(50% 0%,100% 0%,100% 50%)",
          opacity: 0.12,
          transition: "background 0.4s",
        }} />

        {/* Nav row */}
        <div className="relative px-5 pt-3 flex items-center justify-between">
          <button
            onClick={onBack}
            className="size-10 grid place-items-center"
            style={{ background: "#1A1414", border: "2px solid #2A1F1F", boxShadow: "2px 2px 0 #0A0A0A" }}
          >
            <ArrowLeft size={18} color="#F5F1E8" />
          </button>

          {/* Centre label */}
          <div
            className="px-3 py-1 flex items-center gap-2"
            style={{
              background: "#0A0A0A",
              border: `2px solid ${cfg.color}`,
              boxShadow: `3px 3px 0 #0A0A0A`,
              clipPath: "polygon(6% 0,100% 0,94% 100%,0 100%)",
              transition: "border-color 0.4s, box-shadow 0.4s",
            }}
          >
            <Zap size={10} color={cfg.color} fill={cfg.color} />
            <span style={{ color: cfg.color, fontSize: 9, letterSpacing: "0.28em", fontWeight: 900, transition: "color 0.4s" }}>
              SCANNER BRIEFING
            </span>
          </div>

          <div className="size-10" />
        </div>

        {/* Title */}
        <div className="relative text-center px-5 mt-3">
          <div className="relative inline-block">
            <span aria-hidden className="absolute inset-0 select-none" style={{
              color: cfg.color, opacity: 0.3, fontSize: 30, fontWeight: 900,
              fontStyle: "italic", letterSpacing: "-0.03em",
              transform: "translate(3px,3px) skewX(-6deg)", display: "inline-block",
              transition: "color 0.4s",
            }}>
              TRIAL SETUP
            </span>
            <h1 className="relative" style={{
              color: "#F5F1E8", fontSize: 30, fontWeight: 900,
              fontStyle: "italic", letterSpacing: "-0.03em",
              transform: "skewX(-6deg)", display: "inline-block",
              textShadow: "3px 3px 0 #0A0A0A",
            }}>
              TRIAL SETUP
            </h1>
          </div>
        </div>

        {/* ── ANOMALY ORB ── */}
        <div className="relative mx-auto mt-5 mb-2" style={{ width: 210, height: 210 }}>
          {/* Outer rotating dashed hex */}
          <motion.div
            className="absolute inset-0"
            style={{
              border: `2px dashed ${cfg.color}77`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              transition: "border-color 0.4s",
            }}
            animate={{ rotate: 360 }}
            transition={{ duration: 14, repeat: Infinity, ease: "linear" }}
          />
          {/* Mid solid ring */}
          <motion.div
            className="absolute inset-7"
            style={{
              border: `1.5px solid ${cfg.color}44`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              transition: "border-color 0.4s",
            }}
            animate={{ rotate: -360 }}
            transition={{ duration: 9, repeat: Infinity, ease: "linear" }}
          />

          {/* Radiating tick marks */}
          {[0, 45, 90, 135, 180, 225, 270, 315].map((deg) => (
            <div
              key={deg}
              className="absolute left-1/2 top-1/2 origin-center"
              style={{
                width: 3, height: 10,
                background: cfg.color,
                opacity: 0.55,
                transform: `translate(-50%, -50%) rotate(${deg}deg) translateY(-105px)`,
                clipPath: "polygon(0 0,100% 15%,100% 85%,0 100%)",
                transition: "background 0.4s",
              }}
            />
          ))}

          {/* Inner glowing orb — hex-clipped */}
          <motion.div
            className="absolute inset-12 grid place-items-center"
            style={{
              background: `radial-gradient(circle, ${cfg.color}, #0A0A0A 80%)`,
              boxShadow: `0 0 48px ${cfg.color}88, 0 0 0 2px #0A0A0A`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              transition: "background 0.4s, box-shadow 0.4s",
            }}
            animate={{ scale: [1, 1.06, 1] }}
            transition={{ duration: 1.6, repeat: Infinity }}
          >
            <span style={{
              color: "#F5F1E8", fontSize: 8,
              letterSpacing: "0.28em", fontWeight: 900,
              fontStyle: "italic",
            }}>
              ANOMALY
            </span>
          </motion.div>
        </div>

        {/* Difficulty label + description */}
        <div className="relative text-center px-5 pb-5">
          <div
            className="inline-block px-4 py-1 mb-1"
            style={{
              background: cfg.color,
              border: "2px solid #0A0A0A",
              boxShadow: "3px 3px 0 #0A0A0A",
              color: "#0A0A0A",
              fontSize: 11, fontWeight: 900, letterSpacing: "0.2em",
              fontStyle: "italic",
              transform: "rotate(-1deg)",
              transition: "background 0.4s",
            }}
          >
            {diff.toUpperCase()} SIGNAL
          </div>
          <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 4 }}>{cfg.desc}</div>
        </div>
      </div>

      <div className="px-5 pb-36">

        {/* ── DIFFICULTY SELECTOR ── */}
        <div className="mt-5">
          <div
            className="px-2 py-1 mb-3 flex items-center gap-2"
            style={{
              background: "#0A0A0A",
              border: "1px solid #2A1F1F",
              borderLeft: "3px solid #E60012",
              display: "inline-flex",
            }}
          >
            <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.28em", fontWeight: 800 }}>SELECT DIFFICULTY</span>
          </div>

          <div className="grid grid-cols-3 gap-2">
            {(Object.keys(DIFFICULTIES) as Difficulty[]).map((d) => {
              const c = DIFFICULTIES[d];
              const active = diff === d;
              return (
                <button
                  key={d}
                  onClick={() => setDiff(d)}
                  className="relative p-3 text-left overflow-hidden active:translate-x-0.5 active:translate-y-0.5 transition-transform"
                  style={{
                    background: active ? `linear-gradient(135deg, ${c.color}2e 0%, #15100F 70%)` : "#15100F",
                    border: `2px solid ${active ? c.color : "#2A1F1F"}`,
                    boxShadow: active ? `4px 4px 0 #0A0A0A, 4px 4px 0 1px ${c.color}88` : "2px 2px 0 #0A0A0A",
                    transition: "border-color 0.2s, box-shadow 0.2s",
                  }}
                >
                  {/* Corner accent — top right slash */}
                  <div
                    className="absolute top-0 right-0 pointer-events-none"
                    style={{
                      width: 20, height: 20,
                      background: c.color,
                      clipPath: "polygon(100% 0,100% 100%,0 0)",
                      opacity: active ? 0.7 : 0.2,
                      transition: "opacity 0.2s",
                    }}
                  />
                  {/* Active: rarity stripe top */}
                  {active && (
                    <div
                      className="absolute top-0 left-0 right-0 h-0.5"
                      style={{ background: c.color }}
                    />
                  )}

                  <div className="relative">
                    <div
                      style={{
                        color: active ? c.color : "#8A7F76",
                        fontSize: 10, letterSpacing: "0.2em", fontWeight: 900,
                        fontStyle: "italic",
                        transition: "color 0.2s",
                      }}
                    >
                      {d.toUpperCase()}
                    </div>
                    <div className="mt-2 flex items-center gap-1.5">
                      <Heart size={11} color="#FF6B4A" />
                      <span style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 900, fontStyle: "italic" }}>{c.hp}</span>
                    </div>
                    <div className="mt-1 flex items-center gap-1.5">
                      <Swords size={11} color="#FFA947" />
                      <span style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 900, fontStyle: "italic" }}>{c.atk}</span>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* ── THREAT ANALYSIS ── */}
        <div className="mt-4">
          {/* Header strip */}
          <div
            className="px-3 py-1.5 flex items-center gap-2 cl-hatch"
            style={{
              background: "#0A0A0A",
              border: "2px solid #2A1F1F",
              borderBottom: "none",
              borderLeft: `4px solid ${cfg.color}`,
              transition: "border-color 0.4s",
            }}
          >
            <div
              style={{
                width: 8, height: 14,
                background: cfg.color,
                clipPath: "polygon(0 0,100% 15%,100% 85%,0 100%)",
                flexShrink: 0,
                transition: "background 0.4s",
              }}
            />
            <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.25em", fontWeight: 800 }}>THREAT ANALYSIS</span>
          </div>

          <div
            className="p-4"
            style={{
              background: "#15100F",
              border: "2px solid #2A1F1F",
              borderTop: "none",
              boxShadow: `4px 4px 0 #0A0A0A, 4px 4px 0 1px ${cfg.color}55`,
              transition: "box-shadow 0.4s",
            }}
          >
            <div className="grid grid-cols-3 gap-2">
              <ThreatStat label="ANOMALY HP" value={cfg.hp} color="#FF6B4A" />
              <ThreatStat label="ATTACK" value={cfg.atk} color="#FFA947" />
              <ThreatStat label="REC. POWER" value={cfg.rec} color={cfg.color} />
            </div>

            {/* Readiness strip */}
            <div
              className="mt-3 flex items-start gap-2 px-3 py-2.5"
              style={{
                background: ready ? "#0c1c10" : "#1a1400",
                border: `2px solid ${ready ? "#43D17A" : "#FFA947"}`,
                borderLeft: `4px solid ${ready ? "#43D17A" : "#FFA947"}`,
              }}
            >
              <div className="mt-0.5 shrink-0">
                {ready
                  ? <Sparkles size={14} color="#43D17A" />
                  : <AlertTriangle size={14} color="#FFA947" />
                }
              </div>
              <span style={{ color: ready ? "#43D17A" : "#FFA947", fontSize: 11.5, fontWeight: 700, lineHeight: 1.4 }}>
                {hint}
              </span>
            </div>
          </div>
        </div>

        {/* ── DECK SUMMARY ── */}
        <div className="mt-4">
          {/* Header strip */}
          <div
            className="px-3 py-1.5 flex items-center justify-between cl-hatch"
            style={{
              background: "#0A0A0A",
              border: "2px solid #2A1F1F",
              borderBottom: "none",
              borderLeft: "4px solid #E60012",
            }}
          >
            <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.25em", fontWeight: 800 }}>YOUR DECK</span>
            <button
              onClick={onEdit}
              className="flex items-center gap-1 px-2 py-0.5 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
              style={{
                background: "#E6001222",
                border: "1px solid #E6001266",
                color: "#E60012",
                fontSize: 9,
                fontWeight: 900,
                letterSpacing: "0.18em",
                clipPath: "polygon(6% 0,100% 0,94% 100%,0 100%)",
              }}
            >
              <Edit3 size={10} /> EDIT
            </button>
          </div>

          <div
            className="p-4"
            style={{
              background: "#15100F",
              border: "2px solid #2A1F1F",
              borderTop: "none",
              boxShadow: "4px 4px 0 #0A0A0A",
            }}
          >
            {/* Card count + avg power */}
            <div className="flex items-baseline gap-2 mb-3">
              <div
                className="relative inline-block"
                style={{ fontStyle: "italic" }}
              >
                <span aria-hidden className="absolute inset-0 select-none" style={{
                  color: "#E60012", opacity: 0.28, fontSize: 32, fontWeight: 900,
                  transform: "translate(2px,2px)", display: "inline-block",
                }}>{deckCards.length}</span>
                <span className="relative" style={{ color: "#F5F1E8", fontSize: 32, fontWeight: 900 }}>{deckCards.length}</span>
              </div>
              <span style={{ color: "#8A7F76", fontSize: 12 }}>cards · avg power</span>
              <div className="ml-auto flex items-baseline gap-1">
                <span
                  style={{
                    color: avgPower >= cfg.rec ? "#43D17A" : "#FFA947",
                    fontSize: 20, fontWeight: 900, fontStyle: "italic",
                  }}
                >
                  {avgPower}
                </span>
                <span style={{ color: avgPower >= cfg.rec ? "#43D17A55" : "#FFA94766", fontSize: 10, fontWeight: 700 }}>
                  / {cfg.rec} REC
                </span>
              </div>
            </div>

            {/* Type mix bar */}
            <div
              className="flex h-3 overflow-hidden"
              style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}
            >
              {(Object.keys(typeMix) as Element[]).map((e) => (
                <div
                  key={e}
                  style={{
                    width: `${(typeMix[e] / deckCards.length) * 100}%`,
                    background: ELEMENT_COLORS[e],
                  }}
                />
              ))}
            </div>

            {/* Type mix legend */}
            <div className="mt-2 flex flex-wrap gap-1">
              {(Object.keys(typeMix) as Element[]).map((e) => (
                <span
                  key={e}
                  className="px-1.5 py-0.5 flex items-center gap-1"
                  style={{
                    background: `${ELEMENT_COLORS[e]}18`,
                    border: `1px solid ${ELEMENT_COLORS[e]}44`,
                    color: ELEMENT_COLORS[e],
                    fontSize: 9,
                    fontWeight: 800,
                  }}
                >
                  <span style={{ width: 5, height: 5, background: ELEMENT_COLORS[e], display: "inline-block" }} />
                  {e} · {typeMix[e]}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* ── VICTORY REWARDS ── */}
        <div
          className="mt-4 relative overflow-hidden p-4 cl-halftone"
          style={{
            background: "#0A0A0A",
            border: "3px solid #FFD300",
            boxShadow: "5px 5px 0 #E60012",
          }}
        >
          {/* Halftone corner glow */}
          <div
            className="absolute -right-6 -top-6 pointer-events-none"
            style={{
              width: 80, height: 80,
              background: "#FFD300",
              clipPath: "polygon(50% 0%,100% 0%,100% 50%)",
              opacity: 0.18,
            }}
          />

          <div className="relative flex items-center gap-3">
            {/* Trophy icon — hex-clipped */}
            <div
              className="size-12 grid place-items-center shrink-0"
              style={{
                background: "#FFD300",
                border: "2px solid #0A0A0A",
                boxShadow: "3px 3px 0 #0A0A0A",
                clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              }}
            >
              <Trophy size={20} color="#0A0A0A" strokeWidth={2.5} />
            </div>

            <div className="flex-1">
              <div
                className="px-2 py-0.5 mb-2 inline-block"
                style={{
                  background: "#FFD300",
                  border: "1.5px solid #0A0A0A",
                  boxShadow: "2px 2px 0 #0A0A0A",
                  color: "#0A0A0A",
                  fontSize: 9, fontWeight: 900, letterSpacing: "0.22em",
                  transform: "rotate(-1deg)",
                }}
              >
                VICTORY REWARDS
              </div>
              <div className="flex items-center gap-4">
                <div>
                  <div style={{ color: "#8A7F76", fontSize: 8, letterSpacing: "0.2em", fontWeight: 700 }}>XP</div>
                  <div style={{ color: "#F5F1E8", fontSize: 20, fontWeight: 900, fontStyle: "italic", lineHeight: 1 }}>
                    +{cfg.xp}
                  </div>
                </div>
                <div
                  className="w-px self-stretch"
                  style={{ background: "#2A1F1F" }}
                />
                <div>
                  <div style={{ color: "#8A7F76", fontSize: 8, letterSpacing: "0.2em", fontWeight: 700 }}>SHARDS</div>
                  <div style={{ color: "#FFD300", fontSize: 20, fontWeight: 900, fontStyle: "italic", lineHeight: 1 }}>
                    ◆ {cfg.shards}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── STICKY ENGAGE BUTTON ── */}
      <div
        className="absolute left-0 right-0 bottom-0 px-5 pt-4 pb-5 z-30"
        style={{ background: "linear-gradient(180deg, transparent, #0A0A0A 35%)" }}
      >
        <button
          onClick={() => onStart(diff)}
          className="w-full h-14 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
          style={{
            background: cfg.color,
            color: "#0A0A0A",
            border: "3px solid #0A0A0A",
            boxShadow: `5px 5px 0 #0A0A0A, 5px 5px 0 2px #FFD300`,
            fontWeight: 900,
            letterSpacing: "0.18em",
            fontSize: 14,
            transition: "background 0.4s",
          }}
        >
          <Play size={16} fill="#0A0A0A" strokeWidth={0} />
          ENGAGE ANOMALY
        </button>
      </div>
    </div>
  );
}

function ThreatStat({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div
      className="p-2.5 text-center relative overflow-hidden"
      style={{
        background: "#0A0A0A",
        border: `2px solid ${color}66`,
        borderTop: `3px solid ${color}`,
        boxShadow: "2px 2px 0 #0A0A0A",
      }}
    >
      {/* Corner accent */}
      <div
        className="absolute bottom-0 right-0 pointer-events-none"
        style={{
          width: 10, height: 10,
          background: color,
          clipPath: "polygon(100% 0,100% 100%,0 100%)",
          opacity: 0.55,
        }}
      />
      <div style={{ color: "#8A7F76", fontSize: 8, letterSpacing: "0.14em", fontWeight: 700 }}>{label}</div>
      <div
        style={{
          color, fontSize: 24, fontWeight: 900,
          lineHeight: 1.1, marginTop: 2,
          fontStyle: "italic",
        }}
      >
        {value}
      </div>
    </div>
  );
}

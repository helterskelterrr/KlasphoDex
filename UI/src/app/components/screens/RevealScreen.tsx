import { motion } from "motion/react";
import { Plus, Eye, RotateCcw, Sparkles } from "lucide-react";
import { CREATURES, ELEMENT_COLORS, RARITY_COLORS } from "../creature-data";
import { CreaturePortrait } from "../CreaturePortrait";
import { TypeBadge, RarityBadge, StatBar } from "../ui-bits";

export function RevealScreen({ onAdd, onScanAgain, onDetail }: { onAdd: () => void; onScanAgain: () => void; onDetail: () => void }) {
  const c = CREATURES[0];
  const rarity = RARITY_COLORS[c.rarity];
  const elem = ELEMENT_COLORS[c.element];

  return (
    <div className="absolute inset-0 overflow-y-auto cl-halftone-light" style={{ background: "#0A0A0A" }}>

      {/* Deep rarity glow */}
      <div className="absolute inset-0 pointer-events-none" style={{
        background: `radial-gradient(circle at 50% 30%, ${rarity}3a 0%, transparent 60%)`,
      }} />

      {/* Diagonal light rays */}
      <div className="absolute inset-x-0 top-0 h-[65%] overflow-hidden pointer-events-none">
        {[...Array(10)].map((_, i) => (
          <motion.div key={i}
            initial={{ opacity: 0, scaleY: 0 }} animate={{ opacity: 0.14, scaleY: 1 }}
            transition={{ delay: 0.15 + i * 0.04, duration: 0.55 }}
            className="absolute left-1/2 top-0 origin-top"
            style={{
              width: 3, height: 420,
              background: `linear-gradient(180deg, ${rarity}cc, transparent)`,
              transform: `translateX(-50%) rotate(${(i - 4.5) * 11}deg)`,
            }}
          />
        ))}
      </div>

      {/* Giant starburst polygon behind portrait area */}
      <div
        className="absolute pointer-events-none"
        style={{
          width: 340, height: 340,
          left: "50%", top: 90,
          transform: "translateX(-50%)",
          background: rarity,
          clipPath: "polygon(50% 0%,61% 35%,98% 35%,68% 57%,79% 91%,50% 70%,21% 91%,32% 57%,2% 35%,39% 35%)",
          opacity: 0.06,
        }}
      />

      <div className="relative px-5 pt-6 pb-32">

        {/* ── HEADER STAMP ── */}
        <motion.div initial={{ y: -14, opacity: 0 }} animate={{ y: 0, opacity: 1 }} className="text-center">
          {/* Rarity eyebrow tag */}
          <div className="inline-flex items-center gap-2 px-3 py-1 mb-3" style={{
            background: rarity,
            border: "2px solid #0A0A0A",
            boxShadow: "3px 3px 0 #0A0A0A",
            transform: "rotate(-1.5deg)",
            display: "inline-flex",
          }}>
            <Sparkles size={11} color="#0A0A0A" />
            <span style={{ color: "#0A0A0A", fontSize: 10, fontWeight: 900, letterSpacing: "0.22em" }}>
              {c.rarity.toUpperCase()} DISCOVERY
            </span>
          </div>

          {/* Main headline — P5 offset shadow trick */}
          <div className="relative inline-block mt-0.5">
            <span
              aria-hidden
              className="absolute inset-0 select-none"
              style={{
                color: rarity,
                opacity: 0.32,
                fontSize: 42,
                fontWeight: 900,
                letterSpacing: "-0.04em",
                fontStyle: "italic",
                transform: "translate(4px,4px) skewX(-6deg)",
                display: "inline-block",
                lineHeight: 0.95,
              }}
            >
              NEW<br />DISCOVERY
            </span>
            <span
              className="relative"
              style={{
                color: "#F5F1E8",
                fontSize: 42,
                fontWeight: 900,
                letterSpacing: "-0.04em",
                fontStyle: "italic",
                transform: "skewX(-6deg)",
                display: "inline-block",
                lineHeight: 0.95,
                textShadow: `3px 3px 0 #0A0A0A`,
              }}
            >
              NEW<br />DISCOVERY
            </span>
          </div>
        </motion.div>

        {/* ── PORTRAIT ── */}
        <motion.div
          initial={{ scale: 0.5, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: "spring", stiffness: 130, damping: 11, delay: 0.08 }}
          className="relative mt-5 mx-auto"
          style={{ width: 256, height: 256 }}
        >
          {/* Outer glow */}
          <div className="absolute inset-0" style={{
            background: `radial-gradient(circle, ${rarity}55, transparent 65%)`, filter: "blur(14px)",
          }} />
          {/* Rotating ring */}
          <motion.div
            className="absolute inset-3"
            style={{
              border: `2px dashed ${rarity}88`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
            }}
            animate={{ rotate: 360 }}
            transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
          />
          {/* Solid inner hex ring */}
          <motion.div
            className="absolute inset-6"
            style={{
              border: `3px solid ${rarity}`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              boxShadow: `0 0 28px ${rarity}66`,
            }}
            animate={{ rotate: -360 }}
            transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
          />
          {/* Portrait hex container */}
          <div
            className="absolute inset-10 overflow-hidden grid place-items-center"
            style={{
              background: `radial-gradient(circle, ${elem}22, #0A0A0A)`,
              clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              boxShadow: `inset 0 0 30px ${elem}33`,
            }}
          >
            <CreaturePortrait creature={c} size={200} />
          </div>
        </motion.div>

        {/* ── IDENTITY BLOCK ── */}
        <motion.div
          initial={{ y: 12, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.42 }}
          className="text-center mt-5"
        >
          <div className="flex items-center justify-center gap-1.5 mb-2">
            <RarityBadge rarity={c.rarity} size="md" />
            <TypeBadge element={c.element} size="md" />
          </div>

          {/* Name with P5 shadow */}
          <div className="relative inline-block">
            <span aria-hidden className="absolute inset-0 select-none" style={{
              color: rarity, opacity: 0.28, fontSize: 30, fontWeight: 900,
              letterSpacing: "-0.02em", transform: "translate(3px,3px)", display: "inline-block",
            }}>{c.name}</span>
            <h1 className="relative" style={{ color: "#F5F1E8", fontSize: 30, fontWeight: 900, letterSpacing: "-0.02em" }}>{c.name}</h1>
          </div>

          {/* Power / XP bar — hard-edged P5 panel */}
          <div
            className="mt-4 flex items-stretch"
            style={{
              background: "#15100F",
              border: "2px solid #2A1F1F",
              boxShadow: "4px 4px 0 #0A0A0A, 4px 4px 0 1px #FFD300",
            }}
          >
            <div className="flex-1 py-3 flex flex-col items-center" style={{ borderRight: "2px solid #2A1F1F" }}>
              <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.22em", fontWeight: 700 }}>POWER</div>
              <div style={{ color: rarity, fontSize: 30, fontWeight: 900, lineHeight: 1.1 }}>{c.power}</div>
            </div>
            <div className="flex-1 py-3 flex flex-col items-center">
              <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.22em", fontWeight: 700 }}>XP GAIN</div>
              <div style={{ color: "#FFD300", fontSize: 30, fontWeight: 900, lineHeight: 1.1 }}>+100</div>
            </div>
          </div>
        </motion.div>

        {/* ── STATS PANEL ── */}
        <motion.div
          initial={{ y: 12, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.52 }}
          className="mt-4"
        >
          {/* Panel header strip */}
          <div
            className="px-3 py-1.5 flex items-center gap-2 cl-hatch"
            style={{
              background: "#0A0A0A",
              border: "2px solid #2A1F1F",
              borderBottom: "none",
            }}
          >
            <div
              style={{
                width: 8, height: 14,
                background: elem,
                clipPath: "polygon(0 0,100% 15%,100% 85%,0 100%)",
              }}
            />
            <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.25em", fontWeight: 800 }}>CREATURE STATS</span>
          </div>
          <div
            className="p-4 space-y-2"
            style={{
              background: "#15100F",
              border: "2px solid #2A1F1F",
              borderTop: "none",
              boxShadow: "4px 4px 0 #0A0A0A",
            }}
          >
            <StatBar label="HP" value={c.hp} color="#43D17A" />
            <StatBar label="ATK" value={c.atk} color="#FF6B4A" />
            <StatBar label="DEF" value={c.def} color="#3BA7FF" />
            <StatBar label="SPD" value={c.spd} color="#FFE15A" />
          </div>
        </motion.div>

        {/* ── ABILITIES ── */}
        <motion.div
          initial={{ y: 12, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.62 }}
          className="mt-4 grid grid-cols-2 gap-2"
        >
          {c.abilities.map((a) => (
            <div
              key={a.name}
              className="p-3 relative overflow-hidden"
              style={{
                background: "#15100F",
                border: `2px solid ${elem}66`,
                boxShadow: `3px 3px 0 #0A0A0A`,
                clipPath: "polygon(0 0,100% 0,100% 80%,92% 100%,0 100%)",
              }}
            >
              {/* Corner accent */}
              <div
                className="absolute right-0 top-0"
                style={{
                  width: 16, height: 16,
                  background: elem,
                  clipPath: "polygon(100% 0,100% 100%,0 0)",
                  opacity: 0.7,
                }}
              />
              <div style={{ color: elem, fontSize: 9, letterSpacing: "0.18em", fontWeight: 800 }}>ABILITY</div>
              <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 800, marginTop: 3 }}>{a.name}</div>
            </div>
          ))}
        </motion.div>

        {/* ── CTAs ── */}
        <motion.div
          initial={{ y: 12, opacity: 0 }} animate={{ y: 0, opacity: 1 }} transition={{ delay: 0.72 }}
          className="mt-5 space-y-2.5"
        >
          {/* Primary — P5 pop button */}
          <button
            onClick={onAdd}
            className="w-full h-14 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
            style={{
              background: `linear-gradient(135deg, ${rarity}, #FFA947)`,
              color: "#0A0A0A",
              border: "3px solid #0A0A0A",
              boxShadow: "5px 5px 0 #0A0A0A, 5px 5px 0 2px #FFD300",
              fontWeight: 900,
              letterSpacing: "0.12em",
              fontSize: 14,
            }}
          >
            <Plus size={18} strokeWidth={3} />
            ADD TO COLLECTION
          </button>

          {/* Secondary pair — skewed parallelogram chips */}
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={onDetail}
              className="h-12 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
              style={{
                background: "#15100F",
                border: "2px solid #2A1F1F",
                color: "#F5F1E8",
                fontWeight: 700,
                fontSize: 12,
                letterSpacing: "0.06em",
                boxShadow: "3px 3px 0 #0A0A0A",
                clipPath: "polygon(0 0,100% 0,96% 100%,4% 100%)",
              }}
            >
              <Eye size={15} /> VIEW DETAILS
            </button>
            <button
              onClick={onScanAgain}
              className="h-12 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
              style={{
                background: "#15100F",
                border: "2px solid #2A1F1F",
                color: "#F5F1E8",
                fontWeight: 700,
                fontSize: 12,
                letterSpacing: "0.06em",
                boxShadow: "3px 3px 0 #0A0A0A",
                clipPath: "polygon(4% 0,96% 0,100% 100%,0 100%)",
              }}
            >
              <RotateCcw size={15} /> SCAN AGAIN
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

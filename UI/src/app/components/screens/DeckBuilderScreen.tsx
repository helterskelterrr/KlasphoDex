import { useMemo, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ArrowLeft, Sparkles, Plus, Check, X, Swords } from "lucide-react";
import { COLLECTION, TrialCard, EFFECT_DESC } from "../trial-data";
import { ELEMENT_COLORS, RARITY_COLORS, Element, Rarity } from "../creature-data";
import { CreaturePortrait } from "../CreaturePortrait";
import { TypeBadge, RarityBadge } from "../ui-bits";
import { ELEMENT_ICON, FocusGem, MiniStat, HandCard } from "../trial-bits";
import { Flame, Droplets } from "lucide-react";

const DECK_SIZE = 8;

export function DeckBuilderScreen({
  initialDeckIds, onBack, onStartTrial,
}: { initialDeckIds: string[]; onBack: () => void; onStartTrial: (ids: string[]) => void }) {
  const [deck, setDeck] = useState<string[]>(initialDeckIds);
  const [type, setType] = useState<"All" | Element>("All");
  const [rarity, setRarity] = useState<"All" | Rarity>("All");
  const [sheet, setSheet] = useState<TrialCard | null>(null);

  const deckCards = useMemo(() => deck.map(id => COLLECTION.find(c => c.id === id)!).filter(Boolean), [deck]);
  const avgPower = deckCards.length ? Math.round(deckCards.reduce((s, c) => s + c.power, 0) / deckCards.length) : 0;
  const valid = deck.length === DECK_SIZE;

  const typeMix = deckCards.reduce((acc, c) => { acc[c.element] = (acc[c.element] || 0) + 1; return acc; }, {} as Record<Element, number>);

  const pool = COLLECTION.filter(c =>
    (type === "All" || c.element === type) && (rarity === "All" || c.rarity === rarity)
  );

  const toggle = (id: string) => {
    setDeck(d => d.includes(id) ? d.filter(x => x !== id) : d.length < DECK_SIZE ? [...d, id] : d);
  };

  const autoBuild = () => {
    const sorted = [...COLLECTION].sort((a, b) => b.power - a.power);
    const seen = new Set<string>();
    const picks: string[] = [];
    for (const c of sorted) {
      if (picks.length >= DECK_SIZE) break;
      if (!seen.has(c.name)) { picks.push(c.id); seen.add(c.name); }
    }
    setDeck(picks);
  };

  return (
    <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>

      {/* ── HEADER ── */}
      <div
        className="relative px-5 pt-3 pb-4 cl-hatch overflow-hidden"
        style={{
          background: "#15100F",
          borderBottom: "2px solid #E60012",
        }}
      >
        {/* Background slash decoration */}
        <div
          className="absolute right-0 top-0 bottom-0 pointer-events-none"
          style={{
            width: 120,
            background: "linear-gradient(90deg, transparent, #E6001208)",
            clipPath: "polygon(30% 0,100% 0,100% 100%,0 100%)",
          }}
        />
        {/* Starburst watermark */}
        <div
          className="absolute pointer-events-none"
          style={{
            width: 120, height: 120,
            right: -20, top: -20,
            background: "#E60012",
            clipPath: "polygon(50% 0%,61% 35%,98% 35%,68% 57%,79% 91%,50% 70%,21% 91%,32% 57%,2% 35%,39% 35%)",
            opacity: 0.06,
          }}
        />

        <div className="relative flex items-center justify-between">
          <button
            onClick={onBack}
            className="size-10 grid place-items-center"
            style={{ background: "#1A1414", border: "2px solid #2A1F1F", boxShadow: "2px 2px 0 #0A0A0A" }}
          >
            <ArrowLeft size={18} color="#F5F1E8" />
          </button>

          <div style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.22em", fontWeight: 700 }}>RESEARCH KIT</div>

          <button
            onClick={autoBuild}
            className="px-3 h-9 flex items-center gap-1.5 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
            style={{
              background: "#0A0A0A",
              border: "2px solid #E60012",
              color: "#E60012",
              fontSize: 10,
              fontWeight: 900,
              letterSpacing: "0.15em",
              boxShadow: "2px 2px 0 #E60012",
              clipPath: "polygon(0 0,100% 0,92% 100%,0 100%)",
              paddingRight: 18,
            }}
          >
            <Sparkles size={12} /> AUTO
          </button>
        </div>

        <div className="relative mt-3">
          {/* Title with P5 offset shadow */}
          <div className="relative inline-block">
            <span aria-hidden className="absolute inset-0 select-none" style={{
              color: "#E60012", opacity: 0.28, fontSize: 28, fontWeight: 900,
              fontStyle: "italic", letterSpacing: "-0.03em",
              transform: "translate(3px,3px) skewX(-6deg)", display: "inline-block",
            }}>FIELD TRIALS</span>
            <h1
              className="relative"
              style={{
                color: "#F5F1E8", fontSize: 28, fontWeight: 900,
                fontStyle: "italic", letterSpacing: "-0.03em",
                transform: "skewX(-6deg)", display: "inline-block",
              }}
            >
              FIELD TRIALS
            </h1>
          </div>
          <div style={{ color: "#8A7F76", fontSize: 12, marginTop: 4 }}>Build an 8-creature research deck.</div>
        </div>
      </div>

      {/* ── DECK SLOTS ── */}
      <div className="px-5 mt-4">
        <div className="flex items-baseline justify-between mb-2">
          <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.28em", fontWeight: 800 }}>▶ ACTIVE DECK</div>
          <div
            className="px-2 py-0.5"
            style={{
              background: valid ? "#43D17A22" : "#FFA94722",
              border: `1px solid ${valid ? "#43D17A" : "#FFA947"}`,
              color: valid ? "#43D17A" : "#FFA947",
              fontSize: 10, fontWeight: 900, letterSpacing: "0.12em",
              clipPath: "polygon(8% 0,100% 0,92% 100%,0 100%)",
            }}
          >
            {deck.length}/{DECK_SIZE} CARDS
          </div>
        </div>

        <div className="grid grid-cols-4 gap-2">
          {Array.from({ length: DECK_SIZE }).map((_, i) => {
            const c = deckCards[i];
            return <DeckSlot key={i} card={c} onClick={() => c && toggle(c.id)} />;
          })}
        </div>

        {/* Power + Type mix */}
        <div className="mt-3 grid grid-cols-3 gap-2">
          {/* AVG POWER — P5 pop panel */}
          <div
            className="col-span-1 p-3 relative overflow-hidden cl-hatch"
            style={{
              background: "#15100F",
              border: "2px solid #E60012",
              boxShadow: "3px 3px 0 #0A0A0A, 3px 3px 0 1px #FFD300",
            }}
          >
            <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.2em", fontWeight: 700 }}>AVG PWR</div>
            <div
              className="relative inline-block"
              style={{
                color: "#E60012", fontSize: 26, fontWeight: 900, lineHeight: 1.1,
                fontStyle: "italic",
              }}
            >
              {avgPower}
            </div>
          </div>

          {/* Type mix */}
          <div
            className="col-span-2 p-3"
            style={{
              background: "#15100F",
              border: "2px solid #2A1F1F",
              boxShadow: "3px 3px 0 #0A0A0A",
            }}
          >
            <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.2em", fontWeight: 700, marginBottom: 6 }}>TYPE MIX</div>
            <div className="flex h-3 overflow-hidden" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
              {(Object.keys(typeMix) as Element[]).map((e) => (
                <div
                  key={e}
                  style={{
                    width: `${(typeMix[e] / Math.max(deck.length, 1)) * 100}%`,
                    background: ELEMENT_COLORS[e],
                  }}
                />
              ))}
              {deck.length === 0 && <div className="flex-1" />}
            </div>
            <div className="mt-2 flex flex-wrap gap-1">
              {(Object.keys(typeMix) as Element[]).map((e) => (
                <span
                  key={e}
                  className="flex items-center gap-1 px-1.5 py-0.5"
                  style={{
                    background: `${ELEMENT_COLORS[e]}22`,
                    color: ELEMENT_COLORS[e],
                    fontWeight: 800,
                    fontSize: 9,
                    border: `1px solid ${ELEMENT_COLORS[e]}55`,
                  }}
                >
                  <span className="size-1.5" style={{ background: ELEMENT_COLORS[e], display: "inline-block" }} />
                  {e} {typeMix[e]}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* Warning strip */}
        {!valid && (
          <div
            className="mt-3 px-3 py-2 flex items-center gap-2"
            style={{
              background: "#1a1400",
              border: "2px solid #FFA947",
              borderLeft: "4px solid #FFA947",
            }}
          >
            <div
              style={{
                width: 8, height: 14,
                background: "#FFA947",
                clipPath: "polygon(0 0,100% 15%,100% 85%,0 100%)",
                flexShrink: 0,
              }}
            />
            <span style={{ color: "#FFA947", fontSize: 12, fontWeight: 700 }}>
              Needs {DECK_SIZE - deck.length} more card{DECK_SIZE - deck.length === 1 ? "" : "s"} to start.
            </span>
          </div>
        )}
      </div>

      {/* ── FILTERS ── */}
      <div className="mt-5 -mx-5 px-5 overflow-x-auto no-scrollbar">
        <div className="flex gap-1.5 pb-2">
          {(["All", "Fire", "Water", "Earth", "Air", "Electric", "Nature", "Shadow", "Light"] as const).map((t) => {
            const active = type === t;
            const color = t !== "All" ? ELEMENT_COLORS[t as Element] : "#E60012";
            return (
              <button
                key={t}
                onClick={() => setType(t)}
                className="shrink-0 px-3.5 py-1.5 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
                style={{
                  background: active ? color : "#15100F",
                  color: active ? "#0A0A0A" : "#8A7F76",
                  border: `2px solid ${active ? color : "#2A1F1F"}`,
                  boxShadow: active ? `3px 3px 0 #0A0A0A` : "none",
                  fontSize: 9,
                  fontWeight: 900,
                  letterSpacing: "0.12em",
                  clipPath: "polygon(6% 0,100% 0,94% 100%,0 100%)",
                  paddingLeft: 14,
                  paddingRight: 14,
                }}
              >
                {t.toUpperCase()}
              </button>
            );
          })}
        </div>
      </div>

      {/* ── COLLECTION POOL ── */}
      <div className="px-5 mt-3 space-y-2 pb-36">
        <div className="flex items-center justify-between">
          <div
            className="px-2 py-1 flex items-center gap-2"
            style={{
              background: "#15100F",
              border: "1px solid #2A1F1F",
              borderLeft: "3px solid #E60012",
            }}
          >
            <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.28em", fontWeight: 800 }}>
              COLLECTION · {pool.length}
            </span>
          </div>
        </div>

        {pool.map((c) => {
          const inDeck = deck.includes(c.id);
          const elem = ELEMENT_COLORS[c.element];
          const Icon = ELEMENT_ICON[c.element];
          const full = !inDeck && deck.length >= DECK_SIZE;
          return (
            <CollectionRow
              key={c.id}
              card={c}
              inDeck={inDeck}
              full={full}
              onInfo={() => setSheet(c)}
              onToggle={() => !full && toggle(c.id)}
            />
          );
        })}
      </div>

      {/* ── STICKY START BAR ── */}
      <div
        className="absolute left-0 right-0 bottom-0 px-5 pt-4 pb-5 z-30"
        style={{ background: "linear-gradient(180deg, transparent, #0A0A0A 35%)" }}
      >
        <button
          onClick={() => valid && onStartTrial(deck)}
          disabled={!valid}
          className="w-full h-14 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
          style={{
            background: valid ? "#E60012" : "#1A1414",
            color: valid ? "#F5F1E8" : "#8A7F76",
            border: valid ? "3px solid #0A0A0A" : "2px solid #2A1F1F",
            boxShadow: valid ? "5px 5px 0 #0A0A0A, 5px 5px 0 2px #FFD300" : "none",
            fontWeight: 900,
            letterSpacing: "0.18em",
            fontSize: 14,
          }}
        >
          <Swords size={18} strokeWidth={2.5} />
          {valid ? "START FIELD TRIAL" : `ADD ${DECK_SIZE - deck.length} MORE CARD${DECK_SIZE - deck.length === 1 ? "" : "S"}`}
        </button>
      </div>

      {/* ── CARD DETAIL SHEET ── */}
      <AnimatePresence>
        {sheet && (
          <CardDetailSheet
            card={sheet}
            inDeck={deck.includes(sheet.id)}
            canAdd={deck.length < DECK_SIZE}
            onClose={() => setSheet(null)}
            onToggle={() => { toggle(sheet.id); setSheet(null); }}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

// ── Collection Row ──────────────────────────────────────────────────────────
function CollectionRow({
  card, inDeck, full, onInfo, onToggle,
}: { card: TrialCard; inDeck: boolean; full: boolean; onInfo: () => void; onToggle: () => void }) {
  const elem = ELEMENT_COLORS[card.element];
  const rarity = RARITY_COLORS[card.rarity];
  const Icon = ELEMENT_ICON[card.element];

  return (
    <div
      className="relative flex items-center gap-2.5 overflow-hidden"
      style={{
        background: inDeck ? "#0c1c10" : "#15100F",
        border: `2px solid ${inDeck ? "#43D17A" : "#2A1F1F"}`,
        boxShadow: inDeck ? "3px 3px 0 #0A0A0A, 3px 3px 0 1px #43D17A66" : "2px 2px 0 #0A0A0A",
        opacity: full ? 0.42 : 1,
        transition: "opacity 0.15s",
      }}
    >
      {/* Left element color accent bar — skewed slash */}
      <div
        className="absolute left-0 top-0 bottom-0 pointer-events-none"
        style={{
          width: 20,
          background: `linear-gradient(90deg, ${elem}, transparent)`,
          opacity: 0.55,
          clipPath: "polygon(0 0,60% 0,100% 100%,0 100%)",
        }}
      />

      {/* Rarity top stripe */}
      <div
        className="absolute left-0 right-0 top-0 pointer-events-none"
        style={{ height: 2, background: rarity, opacity: 0.7 }}
      />

      {/* Portrait thumbnail */}
      <button
        onClick={onInfo}
        className="ml-2 my-2 size-14 shrink-0 grid place-items-center overflow-hidden"
        style={{
          background: "#0A0A0A",
          border: `1px solid ${elem}44`,
          clipPath: "polygon(0 0,100% 0,100% 80%,90% 100%,0 100%)",
        }}
      >
        <CreaturePortrait creature={card} size={56} />
      </button>

      {/* Card info */}
      <div className="flex-1 min-w-0 py-2">
        <div className="flex items-center gap-1.5">
          <span className="truncate" style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 800 }}>{card.name}</span>
          <RarityBadge rarity={card.rarity} />
        </div>
        <div className="mt-0.5 flex items-center gap-1" style={{ color: elem, fontSize: 10, fontWeight: 700 }}>
          <Icon size={10} /> {card.element} · {card.effect} · {card.speed}
        </div>
        <div className="mt-1.5 flex items-center gap-1.5">
          <FocusGem value={card.cost} size={20} />
          <MiniStat icon={<Flame size={10} />} value={card.damage} color="#FF6B4A" />
          <MiniStat icon={<Droplets size={10} />} value={card.shield} color="#3BA7FF" />
          <span
            className="ml-auto mr-1 px-1.5 py-0.5"
            style={{
              color: card.hue,
              fontSize: 10,
              fontWeight: 900,
              fontStyle: "italic",
              background: `${card.hue}18`,
              border: `1px solid ${card.hue}44`,
            }}
          >
            PWR {card.power}
          </span>
        </div>
      </div>

      {/* Add / remove toggle */}
      <button
        onClick={() => !full && onToggle()}
        disabled={full}
        className="mr-2 size-10 grid place-items-center shrink-0 active:scale-95 transition-transform"
        style={{
          background: inDeck ? "#43D17A" : "#1A1414",
          border: `2px solid ${inDeck ? "#43D17A" : "#2A1F1F"}`,
          boxShadow: inDeck ? "2px 2px 0 #0A0A0A" : "none",
          clipPath: "polygon(10% 0,100% 0,90% 100%,0 100%)",
        }}
      >
        {inDeck
          ? <Check size={16} color="#0A0A0A" strokeWidth={3} />
          : <Plus size={16} color="#8A7F76" />
        }
      </button>
    </div>
  );
}

// ── Deck Slot ────────────────────────────────────────────────────────────────
function DeckSlot({ card, onClick }: { card?: TrialCard; onClick: () => void }) {
  if (!card) {
    return (
      <div
        className="aspect-[3/4] grid place-items-center"
        style={{
          background: "#0A0A0A",
          border: "2px dashed #2A1F1F",
        }}
      >
        <Plus size={14} color="#2A1F1F" />
      </div>
    );
  }

  const elem = ELEMENT_COLORS[card.element];
  const rarity = RARITY_COLORS[card.rarity];

  return (
    <button
      onClick={onClick}
      className="aspect-[3/4] relative overflow-hidden active:scale-95 transition-transform"
      style={{
        background: `linear-gradient(160deg, ${elem}44 0%, #15100F 55%, #0A0A0A 100%)`,
        border: `2px solid ${elem}`,
        boxShadow: `3px 3px 0 #0A0A0A, 3px 3px 0 1px ${rarity}66`,
      }}
    >
      {/* Rarity top bar */}
      <div className="absolute top-0 left-0 right-0 h-1" style={{ background: rarity }} />

      {/* Cost gem */}
      <div className="absolute top-1.5 left-1">
        <FocusGem value={card.cost} size={18} />
      </div>

      {/* Power badge — top right */}
      <div
        className="absolute top-0.5 right-0.5 px-1"
        style={{
          background: "#0A0A0A",
          color: elem,
          fontSize: 8,
          fontWeight: 900,
          fontStyle: "italic",
          border: `1px solid ${elem}66`,
        }}
      >
        {card.power}
      </div>

      {/* Portrait */}
      <div className="absolute inset-0 grid place-items-center pt-4">
        <CreaturePortrait creature={card} size={64} />
      </div>

      {/* Footer gradient + name */}
      <div
        className="absolute bottom-0 left-0 right-0 px-1 pb-1 pt-2"
        style={{ background: "linear-gradient(180deg, transparent, #0A0A0A 60%)" }}
      >
        <div
          className="text-center truncate"
          style={{ color: "#F5F1E8", fontSize: 8, fontWeight: 800 }}
        >
          {card.name}
        </div>
      </div>

      {/* Corner slash overlay */}
      <div
        className="absolute bottom-0 right-0 pointer-events-none"
        style={{
          width: 12, height: 12,
          background: elem,
          clipPath: "polygon(100% 0,100% 100%,0 100%)",
          opacity: 0.6,
        }}
      />
    </button>
  );
}

// ── Card Detail Sheet ────────────────────────────────────────────────────────
function CardDetailSheet({ card, inDeck, canAdd, onClose, onToggle }: {
  card: TrialCard; inDeck: boolean; canAdd: boolean; onClose: () => void; onToggle: () => void;
}) {
  const elem = ELEMENT_COLORS[card.element];
  const rarity = RARITY_COLORS[card.rarity];

  return (
    <motion.div
      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      onClick={onClose}
      className="absolute inset-0 z-50 flex items-end"
      style={{ background: "rgba(5,7,13,0.75)", backdropFilter: "blur(6px)" }}
    >
      <motion.div
        initial={{ y: 420 }} animate={{ y: 0 }} exit={{ y: 420 }}
        transition={{ type: "spring", stiffness: 320, damping: 32 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full relative overflow-hidden"
        style={{
          background: `linear-gradient(180deg, ${elem}22 0%, #15100F 40%, #0A0A0A 100%)`,
          border: `2px solid ${elem}`,
          borderBottom: "none",
          boxShadow: `0 -4px 0 #0A0A0A, 0 -4px 0 1px #FFD300`,
        }}
      >
        {/* Top-edge starburst */}
        <div
          className="absolute pointer-events-none"
          style={{
            width: 140, height: 140,
            right: -20, top: -40,
            background: elem,
            clipPath: "polygon(50% 0%,61% 35%,98% 35%,68% 57%,79% 91%,50% 70%,21% 91%,32% 57%,2% 35%,39% 35%)",
            opacity: 0.08,
          }}
        />

        {/* Drag handle */}
        <div className="mx-auto w-12 h-1 mt-3 mb-3" style={{ background: "#2A1F1F" }} />

        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute top-3 right-4 size-8 grid place-items-center"
          style={{ background: "#1A1414", border: "2px solid #2A1F1F", boxShadow: "1px 1px 0 #0A0A0A" }}
        >
          <X size={14} color="#C9C2B5" />
        </button>

        <div className="px-5 pb-5">
          {/* Card header */}
          <div className="flex gap-3">
            <div
              className="size-24 shrink-0 overflow-hidden grid place-items-center"
              style={{
                background: `radial-gradient(circle, ${elem}33, #0A0A0A)`,
                border: `2px solid ${elem}`,
                boxShadow: `3px 3px 0 #0A0A0A`,
                clipPath: "polygon(0 0,100% 0,100% 80%,88% 100%,0 100%)",
              }}
            >
              <CreaturePortrait creature={card} size={96} />
            </div>
            <div className="flex-1">
              {/* Rarity stripe */}
              <div className="flex items-center gap-1.5 mb-1">
                <RarityBadge rarity={card.rarity} />
                <TypeBadge element={card.element} />
              </div>
              {/* Name */}
              <div
                className="relative inline-block"
                style={{ fontStyle: "italic" }}
              >
                <span aria-hidden className="absolute inset-0 select-none" style={{
                  color: elem, opacity: 0.25, fontSize: 19, fontWeight: 900,
                  transform: "translate(2px,2px)", display: "inline-block",
                }}>{card.name}</span>
                <div className="relative" style={{ color: "#F5F1E8", fontSize: 19, fontWeight: 900 }}>{card.name}</div>
              </div>
              <div style={{ color: elem, fontSize: 11, fontWeight: 700, marginTop: 2, letterSpacing: "0.06em" }}>
                Speed · {card.speed}
              </div>
            </div>
          </div>

          {/* Stat cells — P5 hard-edge grid */}
          <div className="mt-4 grid grid-cols-4 gap-1.5">
            <StatCell label="COST" value={card.cost} color="#E60012" />
            <StatCell label="DMG" value={card.damage} color="#FF6B4A" />
            <StatCell label="SHLD" value={card.shield} color="#3BA7FF" />
            <StatCell label="PWR" value={card.power} color={card.hue} />
          </div>

          {/* Effect block */}
          <div
            className="mt-3 p-3 relative overflow-hidden"
            style={{
              background: "#15100F",
              border: `2px solid ${elem}66`,
              borderLeft: `4px solid ${elem}`,
            }}
          >
            <div style={{ color: elem, fontSize: 9, letterSpacing: "0.22em", fontWeight: 800 }}>
              TYPE EFFECT · {card.effect.toUpperCase()}
            </div>
            <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600, marginTop: 4, lineHeight: 1.45 }}>
              {EFFECT_DESC[card.effect]}
            </div>
          </div>

          {/* Lore */}
          <div
            className="mt-3 px-3 py-2"
            style={{
              background: "#0A0A0A",
              border: "1px solid #2A1F1F",
              borderTop: "2px solid #2A1F1F",
            }}
          >
            <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.22em", fontWeight: 700 }}>// FIELD NOTE</div>
            <div style={{ color: "#C9C2B5", fontSize: 12, marginTop: 4, lineHeight: 1.5, fontStyle: "italic" }}>
              "{card.lore}"
            </div>
          </div>

          {/* CTA */}
          <button
            onClick={onToggle}
            disabled={!inDeck && !canAdd}
            className="mt-4 w-full h-12 flex items-center justify-center gap-2 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
            style={{
              background: inDeck ? "#1a0d10" : (!canAdd ? "#1A1414" : "#E60012"),
              color: inDeck ? "#FF6B4A" : (!canAdd ? "#8A7F76" : "#0A0A0A"),
              border: inDeck ? "2px solid #FF6B4A66" : (!canAdd ? "1px solid #2A1F1F" : "3px solid #0A0A0A"),
              boxShadow: !inDeck && canAdd ? "4px 4px 0 #0A0A0A, 4px 4px 0 1px #FFD300" : "none",
              fontWeight: 900,
              letterSpacing: "0.12em",
              fontSize: 13,
            }}
          >
            {inDeck ? "REMOVE FROM DECK" : (!canAdd ? "DECK FULL" : "ADD TO DECK")}
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

function StatCell({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div
      className="p-2 text-center relative overflow-hidden"
      style={{
        background: "#15100F",
        border: `2px solid ${color}66`,
        borderTop: `3px solid ${color}`,
        boxShadow: "2px 2px 0 #0A0A0A",
      }}
    >
      {/* Corner accent */}
      <div
        className="absolute bottom-0 right-0 pointer-events-none"
        style={{
          width: 8, height: 8,
          background: color,
          clipPath: "polygon(100% 0,100% 100%,0 100%)",
          opacity: 0.5,
        }}
      />
      <div style={{ color: "#8A7F76", fontSize: 8, letterSpacing: "0.15em", fontWeight: 700 }}>{label}</div>
      <div style={{ color, fontSize: 18, fontWeight: 900, lineHeight: 1.15, fontStyle: "italic" }}>{value}</div>
    </div>
  );
}

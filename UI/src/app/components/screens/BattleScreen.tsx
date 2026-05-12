import { useEffect, useMemo, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Heart, Shield as ShieldIcon, Swords, Eye, ChevronsRight, Sparkles, Zap } from "lucide-react";
import { COLLECTION, DIFFICULTIES, Difficulty, TrialCard, EFFECT_DESC } from "../trial-data";
import { ELEMENT_COLORS } from "../creature-data";
import { ELEMENT_ICON, FocusGem, HandCard } from "../trial-bits";
import { CreaturePortrait } from "../CreaturePortrait";

type Intent = { kind: "Attack"; value: number } | { kind: "Guard"; value: number } | { kind: "Distort"; value: number };

export function BattleScreen({
  deckIds, difficulty, onVictory, onDefeat, onClose,
}: {
  deckIds: string[]; difficulty: Difficulty;
  onVictory: (turns: number) => void; onDefeat: (reason: "resolve" | "timeout") => void; onClose: () => void;
}) {
  const cfg = DIFFICULTIES[difficulty];
  const deck = useMemo(() => deckIds.map(id => COLLECTION.find(c => c.id === id)!).filter(Boolean), [deckIds]);

  const [drawPile, setDrawPile] = useState<TrialCard[]>(() => shuffle(deck));
  const [hand, setHand] = useState<TrialCard[]>([]);
  const [discard, setDiscard] = useState<TrialCard[]>([]);

  const [focus, setFocus] = useState(3);
  const [resolve, setResolve] = useState(20);
  const [shield, setShield] = useState(0);
  const [anomalyHp, setAnomalyHp] = useState(cfg.hp);
  const [anomalyShield, setAnomalyShield] = useState(0);
  const [turn, setTurn] = useState(1);
  const [intent, setIntent] = useState<Intent>({ kind: "Attack", value: cfg.atk });
  const [log, setLog] = useState<{ id: number; text: string; color: string }[]>([{ id: 0, text: `Anomaly signal locked. Stabilize within 7 turns.`, color: "#8A7F76" }]);
  const [growBuff, setGrowBuff] = useState(0);
  const [weakenNext, setWeakenNext] = useState(0);
  const [focusBonus, setFocusBonus] = useState(0);
  const [animatedHit, setAnimatedHit] = useState<number | null>(null);

  const addLog = (text: string, color: string) =>
    setLog(l => [...l.slice(-3), { id: Date.now() + Math.random(), text, color }]);

  // Initial draw
  useEffect(() => { drawTo(3); /* eslint-disable-next-line */ }, []);

  function drawTo(target: number) {
    setHand(h => {
      const need = target - h.length;
      if (need <= 0) return h;
      let pile = drawPile.slice();
      let disc = discard.slice();
      const drawn: TrialCard[] = [];
      for (let i = 0; i < need; i++) {
        if (pile.length === 0) {
          if (disc.length === 0) break;
          pile = shuffle(disc); disc = [];
        }
        drawn.push(pile.shift()!);
      }
      setDrawPile(pile);
      setDiscard(disc);
      return [...h, ...drawn];
    });
  }

  function rollIntent(): Intent {
    const r = Math.random();
    if (r < 0.6) return { kind: "Attack", value: cfg.atk + (turn > 3 ? 1 : 0) };
    if (r < 0.85) return { kind: "Guard", value: 3 };
    return { kind: "Distort", value: 2 };
  }

  function playCard(card: TrialCard, idx: number) {
    if (focus < card.cost || anomalyHp <= 0) return;
    setFocus(f => f - card.cost);
    let dmg = card.damage + growBuff;
    let shAdd = card.shield;

    let pierce = 0;
    let logColor = ELEMENT_COLORS[card.element];
    let nextGrow = 0;

    switch (card.effect) {
      case "Burn": dmg += 1; break;
      case "Mend": setResolve(r => Math.min(20, r + 1)); break;
      case "Guard": shAdd += 1; break;
      case "Draft": setTimeout(() => drawTo(hand.length), 80); break;
      case "Spark": pierce = 1; break;
      case "Grow": nextGrow = 1; break;
      case "Weaken": setWeakenNext(w => w + 1); break;
      case "Focus": setFocusBonus(b => b + 1); break;
    }

    // damage to anomaly: shield blocks first, except pierce
    let remaining = dmg;
    let shieldHit = 0;
    if (anomalyShield > 0 && pierce < remaining) {
      const blocked = Math.min(anomalyShield, remaining - pierce);
      shieldHit = blocked;
      setAnomalyShield(s => s - blocked);
      remaining -= blocked;
    }
    if (remaining > 0) {
      setAnomalyHp(hp => Math.max(0, hp - remaining));
      setAnimatedHit(remaining);
      setTimeout(() => setAnimatedHit(null), 600);
    }
    if (shAdd > 0) setShield(s => s + shAdd);
    setGrowBuff(nextGrow);

    addLog(`${card.name} → ${dmg} dmg${shAdd ? `, +${shAdd} shield` : ""}`, logColor);

    setHand(h => h.filter((_, i) => i !== idx));
    setDiscard(d => [...d, card]);

    if (anomalyHp - remaining <= 0) {
      setTimeout(() => onVictory(turn), 700);
    }
  }

  function endTurn() {
    if (anomalyHp <= 0) return;
    let nextResolve = resolve;
    let nextShield = shield;
    let nextAnomalyShield = anomalyShield;

    if (intent.kind === "Attack") {
      let v = Math.max(0, intent.value - weakenNext);
      const blocked = Math.min(nextShield, v);
      nextShield -= blocked;
      v -= blocked;
      nextResolve -= v;
      addLog(`Anomaly attacks for ${intent.value}${weakenNext ? ` (–${weakenNext})` : ""}`, "#FF6B4A");
    } else if (intent.kind === "Guard") {
      nextAnomalyShield += intent.value;
      addLog(`Anomaly hardens · +${intent.value} shield`, "#3BA7FF");
    } else {
      nextResolve -= intent.value;
      addLog(`Distortion · ${intent.value} unblockable`, "#FFD300");
    }

    setShield(nextShield);
    setAnomalyShield(nextAnomalyShield);
    setResolve(nextResolve);
    setWeakenNext(0);

    if (nextResolve <= 0) { setTimeout(() => onDefeat("resolve"), 600); return; }
    if (turn >= 7) { setTimeout(() => onDefeat("timeout"), 600); return; }

    setDiscard(d => [...d, ...hand]);
    setHand([]);

    setTurn(t => t + 1);
    setFocus(3 + focusBonus);
    setFocusBonus(0);
    setShield(0);
    setIntent(rollIntent());
    setTimeout(() => drawTo(3), 60);
  }

  const IntentIcon = intent.kind === "Attack" ? Swords : intent.kind === "Guard" ? ShieldIcon : Eye;
  const intentColor = intent.kind === "Attack" ? "#FF6B4A" : intent.kind === "Guard" ? "#3BA7FF" : "#FFD300";

  return (
    <div
      className="absolute inset-0 overflow-hidden flex flex-col cl-halftone-light"
      style={{
        background: `radial-gradient(ellipse at 50% 25%, ${cfg.color}22, transparent 55%), #0A0A0A`,
      }}
    >
      {/* TOP BAR */}
      <div
        className="relative px-4 pt-3 pb-2 flex items-center justify-between z-10 cl-hatch"
        style={{ background: "#0A0A0A", borderBottom: `2px solid ${cfg.color}66` }}
      >
        <button
          onClick={onClose}
          className="size-9 grid place-items-center"
          style={{ background: "#15100F", border: "2px solid #2A1F1F", boxShadow: "2px 2px 0 #0A0A0A" }}
        >
          <X size={16} color="#F5F1E8" />
        </button>

        {/* Center: turn counter as P5 skewed display */}
        <div className="flex flex-col items-center">
          <div style={{ color: "#8A7F76", fontSize: 8, letterSpacing: "0.35em", fontWeight: 800 }}>// FIELD TRIAL</div>
          <div className="relative mt-0.5" style={{ display: "inline-block" }}>
            <span
              aria-hidden
              className="absolute inset-0 select-none"
              style={{
                color: cfg.color, opacity: 0.3, fontSize: 14, fontWeight: 900,
                letterSpacing: "0.12em", transform: "translate(2px,2px) skewX(-8deg)", display: "inline-block",
              }}
            >
              TURN {turn} / 7
            </span>
            <span
              className="relative"
              style={{
                color: cfg.color, fontSize: 14, fontWeight: 900,
                letterSpacing: "0.12em", transform: "skewX(-8deg)", display: "inline-block",
              }}
            >
              TURN {turn} / 7
            </span>
          </div>
        </div>

        {/* Turn pip row */}
        <div className="flex items-center gap-1">
          {Array.from({ length: 7 }).map((_, i) => (
            <div
              key={i}
              style={{
                width: 6, height: 10,
                background: i < turn ? cfg.color : "#2A1F1F",
                transform: "skewX(-12deg)",
                transition: "background 0.2s",
              }}
            />
          ))}
        </div>
      </div>

      {/* ANOMALY PANEL */}
      <div className="px-4 mt-3">
        <div
          className="relative overflow-hidden cl-halftone"
          style={{
            background: `linear-gradient(135deg, ${cfg.color}28 0%, #15100F 65%)`,
            border: `2px solid ${cfg.color}`,
            boxShadow: `4px 4px 0 #0A0A0A, 4px 4px 0 2px #FFD300`,
          }}
        >
          {/* Top-right slash decoration */}
          <div
            className="absolute -right-8 -top-8 pointer-events-none"
            style={{
              width: 80, height: 80,
              background: cfg.color,
              clipPath: "polygon(50% 0%, 100% 0%, 100% 50%)",
              opacity: 0.2,
            }}
          />
          {/* Starburst behind orb */}
          <div
            className="absolute pointer-events-none"
            style={{
              width: 80, height: 80, left: 8, top: 4,
              background: cfg.color,
              clipPath: "polygon(50% 0%,61% 35%,98% 35%,68% 57%,79% 91%,50% 70%,21% 91%,32% 57%,2% 35%,39% 35%)",
              opacity: 0.15,
            }}
          />

          <div className="relative p-3.5 flex items-center gap-3">
            {/* Anomaly orb */}
            <motion.div
              className="size-16 grid place-items-center shrink-0"
              style={{
                background: `radial-gradient(circle, ${cfg.color}, #0A0A0A 80%)`,
                boxShadow: `0 0 18px ${cfg.color}88, 0 0 0 2px #0A0A0A`,
                clipPath: "polygon(50% 0%,100% 25%,100% 75%,50% 100%,0% 75%,0% 25%)",
              }}
              animate={{ scale: [1, 1.06, 1] }}
              transition={{ duration: 1.8, repeat: Infinity }}
            >
              <Sparkles size={20} color="#F5F1E8" />
            </motion.div>

            <div className="flex-1 min-w-0">
              {/* Name + difficulty stamp */}
              <div className="flex items-center gap-2 mb-1.5">
                <span style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 800 }}>Scanner Anomaly</span>
                <span
                  className="px-2 py-0.5"
                  style={{
                    background: cfg.color, color: "#0A0A0A", fontSize: 8, fontWeight: 900,
                    letterSpacing: "0.2em", border: "1.5px solid #0A0A0A",
                    boxShadow: "1.5px 1.5px 0 #FFD300",
                    transform: "rotate(-2deg)", display: "inline-block",
                  }}
                >
                  {difficulty.toUpperCase()}
                </span>
              </div>

              {/* HP bar */}
              <div className="flex items-center gap-2">
                <Heart size={11} color="#FF6B4A" />
                <div className="flex-1 h-2.5 overflow-hidden relative" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
                  <motion.div
                    className="h-full"
                    style={{
                      background: "linear-gradient(90deg, #FF6B4A, #FFA947)",
                      boxShadow: "0 0 8px #FF6B4A88",
                    }}
                    animate={{ width: `${(anomalyHp / cfg.hp) * 100}%` }}
                  />
                  {/* HP bar tick marks */}
                  <div className="absolute inset-0 flex" style={{ pointerEvents: "none" }}>
                    {Array.from({ length: 9 }).map((_, i) => (
                      <div
                        key={i}
                        className="flex-1"
                        style={{ borderRight: i < 8 ? "1px solid rgba(0,0,0,0.4)" : "none" }}
                      />
                    ))}
                  </div>
                </div>
                <span
                  className="tabular-nums"
                  style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 900, minWidth: 42, textAlign: "right" }}
                >
                  {anomalyHp}/{cfg.hp}
                </span>
              </div>

              {anomalyShield > 0 && (
                <div className="mt-1 flex items-center gap-1">
                  <ShieldIcon size={10} color="#3BA7FF" />
                  <span style={{ color: "#3BA7FF", fontSize: 11, fontWeight: 700 }}>Shield {anomalyShield}</span>
                </div>
              )}
            </div>

            {/* Animated hit number */}
            <AnimatePresence>
              {animatedHit !== null && (
                <motion.div
                  initial={{ y: 4, opacity: 0, scale: 0.6, rotate: -12 }}
                  animate={{ y: -28, opacity: 1, scale: 1.2, rotate: -8 }}
                  exit={{ opacity: 0, scale: 0.8 }}
                  className="absolute right-3 top-2"
                  style={{
                    background: "#E60012",
                    color: "#F5F1E8",
                    fontSize: 18,
                    fontWeight: 900,
                    letterSpacing: "-0.02em",
                    padding: "1px 8px",
                    border: "2px solid #0A0A0A",
                    boxShadow: "3px 3px 0 #FFD300",
                    zIndex: 20,
                  }}
                >
                  -{animatedHit}
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Intent strip — parallelogram */}
          <div
            className="mx-3.5 mb-3 flex items-center justify-between"
            style={{
              background: "#0A0A0A",
              border: `1px solid ${intentColor}66`,
              borderLeft: `3px solid ${intentColor}`,
              padding: "6px 10px",
            }}
          >
            <div style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.22em", fontWeight: 700 }}>NEXT INTENT</div>
            <div
              className="flex items-center gap-1.5 px-3 py-1"
              style={{
                background: `${intentColor}22`,
                border: `1px solid ${intentColor}`,
                clipPath: "polygon(8% 0,100% 0,92% 100%,0 100%)",
                paddingLeft: 16, paddingRight: 16,
              }}
            >
              <IntentIcon size={12} color={intentColor} />
              <span style={{ color: intentColor, fontSize: 11, fontWeight: 800, letterSpacing: "0.1em" }}>
                {intent.kind.toUpperCase()} {intent.kind !== "Guard" ? intent.value : ""}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* BATTLE LOG */}
      <div className="flex-1 px-4 mt-3 overflow-hidden flex flex-col">
        <div
          className="flex-1 relative overflow-hidden flex flex-col"
          style={{
            background: "#15100F",
            border: "2px solid #2A1F1F",
            borderTop: "3px solid #E60012",
          }}
        >
          {/* Log header bar */}
          <div
            className="px-3 py-1.5 flex items-center gap-2 cl-hatch shrink-0"
            style={{ background: "#0A0A0A", borderBottom: "1px solid #2A1F1F" }}
          >
            <Zap size={10} color="#E60012" fill="#E60012" />
            <span style={{ color: "#E60012", fontSize: 9, letterSpacing: "0.28em", fontWeight: 800 }}>BATTLE LOG</span>
            <span
              className="ml-auto px-1.5"
              style={{
                background: "#E60012", color: "#0A0A0A", fontSize: 8,
                fontWeight: 900, letterSpacing: "0.15em",
                clipPath: "polygon(10% 0,100% 0,90% 100%,0 100%)",
              }}
            >
              LIVE
            </span>
          </div>

          {/* Log entries */}
          <div className="flex-1 overflow-y-auto p-3 space-y-1.5">
            <AnimatePresence initial={false}>
              {log.slice(-4).map((l) => (
                <motion.div
                  key={l.id}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="flex items-start gap-2"
                >
                  <div
                    className="mt-0.5 shrink-0"
                    style={{
                      width: 6, height: 12,
                      background: l.color,
                      clipPath: "polygon(0 0,100% 20%,100% 80%,0 100%)",
                    }}
                  />
                  <span style={{ color: "#C9C2B5", fontSize: 11.5, lineHeight: 1.4 }}>{l.text}</span>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        </div>
      </div>

      {/* PLAYER STATUS */}
      <div className="px-4 mt-3">
        <div
          className="relative flex items-center gap-3 p-2.5"
          style={{
            background: "#15100F",
            border: "2px solid #2A1F1F",
            borderLeft: "3px solid #43D17A",
          }}
        >
          <FocusGem value={focus} size={44} />

          <div className="flex-1 min-w-0">
            {/* Resolve bar */}
            <div className="flex items-center gap-2">
              <Heart size={11} color="#43D17A" />
              <div
                className="flex-1 h-2.5 overflow-hidden relative"
                style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}
              >
                <motion.div
                  className="h-full"
                  style={{
                    background: "linear-gradient(90deg, #43D17A, #C8102E)",
                    boxShadow: "0 0 6px #43D17A88",
                  }}
                  animate={{ width: `${(resolve / 20) * 100}%` }}
                />
                {/* Tick marks */}
                <div className="absolute inset-0 flex" style={{ pointerEvents: "none" }}>
                  {Array.from({ length: 19 }).map((_, i) => (
                    <div
                      key={i}
                      className="flex-1"
                      style={{ borderRight: "1px solid rgba(0,0,0,0.35)" }}
                    />
                  ))}
                </div>
              </div>
              <span
                className="tabular-nums"
                style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 900, minWidth: 38, textAlign: "right" }}
              >
                {resolve}/20
              </span>
            </div>

            {/* Status row */}
            <div className="mt-1.5 flex items-center gap-1.5 flex-wrap">
              <span style={{ color: "#8A7F76", fontSize: 9, letterSpacing: "0.2em", fontWeight: 700 }}>RESOLVE</span>
              {shield > 0 && (
                <span
                  className="flex items-center gap-1 px-1.5 py-0.5"
                  style={{ background: "#0c1820", border: "1px solid #3BA7FF55", clipPath: "polygon(6% 0,100% 0,94% 100%,0 100%)" }}
                >
                  <ShieldIcon size={9} color="#3BA7FF" />
                  <span style={{ color: "#3BA7FF", fontSize: 10, fontWeight: 800 }}>{shield}</span>
                </span>
              )}
              {growBuff > 0 && (
                <span
                  className="px-1.5 py-0.5"
                  style={{ background: "#0c1f12", color: "#43D17A", fontSize: 10, fontWeight: 800, border: "1px solid #43D17A55" }}
                >
                  +{growBuff} DMG
                </span>
              )}
              {focusBonus > 0 && (
                <span
                  className="px-1.5 py-0.5"
                  style={{ background: "#0c1f1f", color: "#E60012", fontSize: 10, fontWeight: 800, border: "1px solid #E6001255" }}
                >
                  +{focusBonus} FOCUS
                </span>
              )}
            </div>
          </div>

          {/* END TURN — skewed P5 action button */}
          <button
            onClick={endTurn}
            className="h-12 px-4 shrink-0 active:translate-x-0.5 active:translate-y-0.5 transition-transform"
            style={{
              background: "#FFD300",
              color: "#0A0A0A",
              border: "3px solid #0A0A0A",
              boxShadow: "4px 4px 0 #0A0A0A",
              fontWeight: 900,
              letterSpacing: "0.12em",
              fontSize: 12,
              transform: "skewX(-8deg)",
            }}
          >
            <span style={{ display: "inline-block", transform: "skewX(8deg)" }}>END TURN</span>
          </button>
        </div>
      </div>

      {/* HAND */}
      <div className="mt-3 pb-4 overflow-x-auto no-scrollbar">
        <div className="flex gap-2 px-4 min-w-min">
          <AnimatePresence>
            {hand.map((card, i) => {
              const disabled = focus < card.cost || anomalyHp <= 0;
              return (
                <motion.div
                  key={card.id + i}
                  initial={{ y: 24, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  exit={{ y: -44, opacity: 0, scale: 0.82 }}
                  transition={{ duration: 0.18 }}
                >
                  <HandCard card={card} disabled={disabled} onClick={() => playCard(card, i)} compact />
                </motion.div>
              );
            })}
          </AnimatePresence>
          {hand.length === 0 && (
            <div
              className="grid place-items-center w-full py-10"
              style={{ color: "#8A7F76", fontSize: 12, fontStyle: "italic" }}
            >
              No cards in hand — end turn to redraw.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function shuffle<T>(arr: T[]): T[] {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

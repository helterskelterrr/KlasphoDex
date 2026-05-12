import { motion } from "motion/react";
import { useEffect, useState } from "react";
import { X, Zap, Image as ImageIcon, RefreshCw } from "lucide-react";

export function ScanScreen({ onCapture, onClose }: { onCapture: () => void; onClose: () => void }) {
  const [phase, setPhase] = useState<"detecting" | "locked">("detecting");
  useEffect(() => {
    const t = setTimeout(() => setPhase("locked"), 2200);
    return () => clearTimeout(t);
  }, []);

  const isLocked = phase === "locked";
  const accent = isLocked ? "#FFD300" : "#E60012";

  return (
    <div className="absolute inset-0 overflow-hidden" style={{ background: "#000" }}>
      {/* mock camera background */}
      <div className="absolute inset-0" style={{
        background:
          "radial-gradient(ellipse at 50% 60%, #2a3942 0%, #0c1318 50%, #0A0A0A 100%)",
      }} />
      {/* mock subject (mug) */}
      <div className="absolute left-1/2 -translate-x-1/2" style={{ top: "38%" }}>
        <svg width="180" height="180" viewBox="0 0 200 200">
          <defs>
            <radialGradient id="mug-g" cx="40%" cy="35%" r="60%">
              <stop offset="0%" stopColor="#d8cdb8" />
              <stop offset="100%" stopColor="#3a3329" />
            </radialGradient>
          </defs>
          <ellipse cx="100" cy="170" rx="60" ry="8" fill="#000" opacity="0.5" />
          <rect x="55" y="70" width="80" height="90" rx="8" fill="url(#mug-g)" />
          <ellipse cx="95" cy="72" rx="40" ry="8" fill="#1a1612" />
          <ellipse cx="95" cy="70" rx="40" ry="6" fill="#5a4a36" opacity="0.6" />
          <path d="M 135 90 Q 165 100 165 120 Q 165 140 135 145" stroke="url(#mug-g)" strokeWidth="10" fill="none" />
          {/* steam */}
          <motion.path
            d="M 80 60 Q 75 40 85 25"
            stroke="#fff" strokeOpacity="0.25" strokeWidth="3" fill="none" strokeLinecap="round"
            animate={{ y: [-2, -8, -2], opacity: [0.3, 0.15, 0.3] }} transition={{ duration: 3, repeat: Infinity }}
          />
          <motion.path
            d="M 100 55 Q 95 35 105 20"
            stroke="#fff" strokeOpacity="0.2" strokeWidth="3" fill="none" strokeLinecap="round"
            animate={{ y: [0, -10, 0], opacity: [0.25, 0.1, 0.25] }} transition={{ duration: 2.6, repeat: Infinity, delay: 0.5 }}
          />
        </svg>
      </div>

      {/* grid overlay */}
      <div className="absolute inset-0 pointer-events-none opacity-20" style={{
        backgroundImage: "linear-gradient(0deg, transparent 95%, #E60012 95%), linear-gradient(90deg, transparent 95%, #E60012 95%)",
        backgroundSize: "32px 32px",
      }} />

      {/* top bar */}
      <div className="absolute top-0 inset-x-0 p-4 flex items-center justify-between z-10">
        <button onClick={onClose} className="size-10 rounded-full grid place-items-center backdrop-blur" style={{ background: "rgba(5,7,13,0.6)", border: "1px solid #2A1F1F" }}>
          <X size={18} color="#F5F1E8" />
        </button>
        <motion.div
          key={phase}
          initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
          className="px-3 py-1.5 rounded-full flex items-center gap-2 backdrop-blur"
          style={{ background: "rgba(5,7,13,0.6)", border: `1px solid ${accent}66` }}
        >
          <motion.span className="size-2 rounded-full" style={{ background: accent, boxShadow: `0 0 6px ${accent}` }}
            animate={{ opacity: [1, 0.3, 1] }} transition={{ duration: 1, repeat: Infinity }} />
          <span style={{ color: accent, fontSize: 11, fontWeight: 700, letterSpacing: "0.2em" }}>
            {isLocked ? "TARGET LOCKED" : "DETECTING"}
          </span>
        </motion.div>
        <button className="size-10 rounded-full grid place-items-center backdrop-blur" style={{ background: "rgba(5,7,13,0.6)", border: "1px solid #2A1F1F" }}>
          <RefreshCw size={16} color="#F5F1E8" />
        </button>
      </div>

      {/* scanner frame */}
      <div className="absolute left-1/2 -translate-x-1/2" style={{ top: "30%" }}>
        <div className="relative" style={{ width: 240, height: 240 }}>
          {/* corner brackets */}
          {[
            { t: 0, l: 0, rot: 0 },
            { t: 0, r: 0, rot: 90 },
            { b: 0, r: 0, rot: 180 },
            { b: 0, l: 0, rot: 270 },
          ].map((c, i) => (
            <div key={i} className="absolute" style={{
              top: c.t, left: c.l, right: c.r as any, bottom: c.b as any,
              width: 32, height: 32,
              borderTop: `3px solid ${accent}`, borderLeft: `3px solid ${accent}`,
              transform: `rotate(${c.rot}deg)`,
              boxShadow: `0 0 12px ${accent}66`,
            }} />
          ))}
          {/* scan line */}
          {!isLocked && (
            <motion.div
              className="absolute left-2 right-2 h-0.5 rounded-full"
              style={{ background: `linear-gradient(90deg, transparent, ${accent}, transparent)`, boxShadow: `0 0 12px ${accent}` }}
              initial={{ top: 8 }} animate={{ top: 224 }}
              transition={{ duration: 1.7, repeat: Infinity, ease: "easeInOut", repeatType: "reverse" }}
            />
          )}
          {/* lock burst */}
          {isLocked && (
            <motion.div
              initial={{ scale: 0.7, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
              className="absolute inset-0 rounded-md"
              style={{ border: `1px solid ${accent}`, boxShadow: `0 0 32px ${accent}66, inset 0 0 32px ${accent}33` }}
            />
          )}
        </div>
      </div>

      {/* confidence labels */}
      <motion.div
        initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}
        className="absolute" style={{ top: "32%", left: "12%" }}
      >
        <div className="px-2 py-1 rounded backdrop-blur flex items-center gap-1.5" style={{ background: "rgba(5,7,13,0.7)", border: `1px solid ${accent}55` }}>
          <span style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 600 }}>ceramic mug</span>
          <span style={{ color: accent, fontSize: 11, fontWeight: 800 }}>94%</span>
        </div>
        <div style={{ width: 1, height: 20, background: accent, marginLeft: 14, opacity: 0.6 }} />
      </motion.div>
      <motion.div
        initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.7 }}
        className="absolute" style={{ top: "62%", right: "10%" }}
      >
        <div style={{ width: 1, height: 20, background: accent, marginLeft: "auto", marginRight: 14, opacity: 0.6 }} />
        <div className="px-2 py-1 rounded backdrop-blur flex items-center gap-1.5" style={{ background: "rgba(5,7,13,0.7)", border: `1px solid ${accent}55` }}>
          <span style={{ color: "#F5F1E8", fontSize: 11, fontWeight: 600 }}>plant leaf</span>
          <span style={{ color: accent, fontSize: 11, fontWeight: 800 }}>88%</span>
        </div>
      </motion.div>

      {/* Bottom panel */}
      <div className="absolute bottom-0 inset-x-0 px-5 pb-8 pt-6 z-10" style={{
        background: "linear-gradient(180deg, transparent, rgba(5,7,13,0.85) 30%, #0A0A0A 100%)",
      }}>
        <div className="text-center mb-5">
          <motion.div
            key={phase}
            initial={{ y: 6, opacity: 0 }} animate={{ y: 0, opacity: 1 }}
            style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}
          >
            {isLocked ? "Object lock is stable. Capture to awaken it." : "Move slowly until the scanner ring locks."}
          </motion.div>
        </div>
        <div className="flex items-center justify-around">
          <button className="size-12 rounded-full grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
            <ImageIcon size={18} color="#C9C2B5" />
          </button>
          <button
            onClick={onCapture}
            className="size-20 rounded-full grid place-items-center relative active:scale-95 transition-transform"
            style={{ background: "#0A0A0A", border: `3px solid ${accent}`, boxShadow: `0 0 24px ${accent}66` }}
          >
            <div className="size-14 rounded-full" style={{
              background: `radial-gradient(circle, ${accent}, ${accent}88)`,
              boxShadow: `0 0 16px ${accent}`,
            }} />
          </button>
          <button className="size-12 rounded-full grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
            <Zap size={18} color="#C9C2B5" />
          </button>
        </div>
      </div>
    </div>
  );
}

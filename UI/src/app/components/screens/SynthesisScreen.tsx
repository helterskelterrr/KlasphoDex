import { motion } from "motion/react";
import { useEffect, useState } from "react";
import { Check } from "lucide-react";

const STAGES = [
  "Reading object signature",
  "Mixing elemental traits",
  "Writing field lore",
  "Preparing reveal",
];

export function SynthesisScreen({ onDone }: { onDone: () => void }) {
  const [stage, setStage] = useState(0);
  useEffect(() => {
    const id = setInterval(() => {
      setStage((s) => {
        if (s >= STAGES.length - 1) {
          clearInterval(id);
          setTimeout(onDone, 700);
          return s;
        }
        return s + 1;
      });
    }, 700);
    return () => clearInterval(id);
  }, [onDone]);

  return (
    <div className="absolute inset-0 overflow-hidden" style={{ background: "#0A0A0A" }}>
      <div className="absolute inset-0 opacity-40" style={{
        background: "radial-gradient(circle at 50% 40%, #E6001233, transparent 60%)",
      }} />
      <div className="absolute inset-0 opacity-15" style={{
        backgroundImage: "linear-gradient(0deg, transparent 95%, #E60012 95%), linear-gradient(90deg, transparent 95%, #E60012 95%)",
        backgroundSize: "20px 20px",
      }} />

      {/* spinning rings */}
      <div className="absolute left-1/2 top-[28%] -translate-x-1/2">
        <div className="relative" style={{ width: 200, height: 200 }}>
          <motion.div className="absolute inset-0 rounded-full" style={{ border: "2px dashed #E6001288" }}
            animate={{ rotate: 360 }} transition={{ duration: 8, repeat: Infinity, ease: "linear" }} />
          <motion.div className="absolute inset-6 rounded-full" style={{ border: "1px solid #FFD30088" }}
            animate={{ rotate: -360 }} transition={{ duration: 5, repeat: Infinity, ease: "linear" }} />
          <motion.div className="absolute inset-12 rounded-full" style={{
            background: "radial-gradient(circle, #E60012, #8B0008)",
            boxShadow: "0 0 40px #E60012",
          }} animate={{ scale: [1, 1.08, 1] }} transition={{ duration: 1.4, repeat: Infinity }} />
        </div>
      </div>

      <div className="absolute left-0 right-0 top-[58%] px-6 text-center">
        <div style={{ color: "#E60012", fontSize: 11, letterSpacing: "0.4em", fontWeight: 700 }}>SYNTHESIZING</div>
        <div style={{ color: "#F5F1E8", fontSize: 28, fontWeight: 800, letterSpacing: "-0.02em", lineHeight: 1, marginTop: 6 }}>
          New lifeform
        </div>
      </div>

      <div className="absolute left-5 right-5 bottom-10 space-y-2">
        <div className="flex flex-wrap gap-1.5 mb-3 justify-center">
          {["mug 94%", "ceramic 83%", "tableware 79%"].map((l, i) => (
            <motion.span key={l}
              initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }}
              className="px-2 py-1 rounded-sm" style={{ background: "#1A1414", border: "1px solid #2A1F1F", color: "#C9C2B5", fontSize: 11, fontWeight: 600, letterSpacing: "0.05em" }}
            >
              {l}
            </motion.span>
          ))}
        </div>
        {STAGES.map((s, i) => {
          const done = i < stage;
          const active = i === stage;
          return (
            <motion.div key={s}
              initial={{ opacity: 0, x: -8 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.1 }}
              className="flex items-center gap-3 p-2.5 rounded-lg"
              style={{
                background: active ? "#1F1414" : "#15100F",
                border: `1px solid ${active ? "#E6001288" : "#2A1F1F"}`,
              }}
            >
              <div className="size-6 rounded-full grid place-items-center shrink-0" style={{
                background: done ? "#43D17A" : active ? "#E60012" : "#1A1414",
                border: "1px solid #2A1F1F",
              }}>
                {done ? <Check size={12} color="#0A0A0A" strokeWidth={3} /> : (
                  <motion.div className="size-2 rounded-full" style={{ background: "#0A0A0A" }}
                    animate={active ? { scale: [1, 1.4, 1] } : {}} transition={{ duration: 0.8, repeat: Infinity }} />
                )}
              </div>
              <span style={{ color: active || done ? "#F5F1E8" : "#8A7F76", fontSize: 13, fontWeight: 600 }}>{s}</span>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}

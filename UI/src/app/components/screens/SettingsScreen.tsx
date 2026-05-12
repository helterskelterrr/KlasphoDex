import { useState } from "react";
import { motion } from "motion/react";
import {
  ArrowLeft, Sun, Moon, Bell, Camera, Shield, Database, Volume2, Globe, Smartphone,
  HelpCircle, FileText, LogOut, ChevronRight, Sparkles, Vibrate, Cloud
} from "lucide-react";

type Theme = "Dark" | "Light" | "Auto";

export function SettingsScreen({ onBack }: { onBack: () => void }) {
  const [theme, setTheme] = useState<Theme>("Dark");
  const [missions, setMissions] = useState(true);
  const [rare, setRare] = useState(true);
  const [streak, setStreak] = useState(true);
  const [haptics, setHaptics] = useState(true);
  const [reduced, setReduced] = useState(false);
  const [sfx, setSfx] = useState(true);
  const [sync, setSync] = useState(true);

  return (
    <div className="absolute inset-0 overflow-y-auto" style={{ background: "#0A0A0A" }}>
      <div className="px-5 pt-3 pb-12">
        {/* Header */}
        <div className="flex items-center justify-between">
          <button onClick={onBack} className="size-10 rounded-full grid place-items-center" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
            <ArrowLeft size={18} color="#F5F1E8" />
          </button>
          <div style={{ color: "#8A7F76", fontSize: 11, letterSpacing: "0.2em", fontWeight: 600 }}>CONFIGURATION</div>
          <div className="size-10" />
        </div>

        <h1 className="mt-3" style={{ color: "#F5F1E8", fontSize: 28, fontWeight: 800, letterSpacing: "-0.02em" }}>Settings</h1>

        {/* Account card */}
        <div className="mt-5 p-4 rounded-2xl flex items-center gap-3" style={{
          background: "#15100F",
          border: "1px solid #2A1F1F",
        }}>
          <div className="size-12 rounded-full grid place-items-center shrink-0" style={{
            background: "#E60012", color: "#F5F1E8", fontSize: 16, fontWeight: 900, border: "2px solid #FFD300",
          }}>MV</div>
          <div className="flex-1">
            <div style={{ color: "#F5F1E8", fontSize: 14, fontWeight: 700 }}>Mira Vale</div>
            <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 1 }}>mira.vale@field.kit · Field Explorer</div>
          </div>
          <ChevronRight size={16} color="#8A7F76" />
        </div>

        {/* Appearance */}
        <Section title="APPEARANCE">
          <div className="p-4">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles size={14} color="#E60012" />
              <span style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>Theme</span>
            </div>
            <div className="grid grid-cols-3 gap-2 p-1 rounded-lg" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
              {(["Dark", "Light", "Auto"] as Theme[]).map((t) => {
                const active = theme === t;
                const Icon = t === "Light" ? Sun : t === "Dark" ? Moon : Smartphone;
                return (
                  <button key={t} onClick={() => setTheme(t)} className="relative h-10 rounded-md flex items-center justify-center gap-1.5">
                    {active && (
                      <motion.div layoutId="theme-active" className="absolute inset-0 rounded-md" style={{
                        background: "#E60012",
                      }} />
                    )}
                    <span className="relative" style={{ color: active ? "#0A0A0A" : "#C9C2B5" }}><Icon size={14} /></span>
                    <span className="relative" style={{
                      color: active ? "#0A0A0A" : "#C9C2B5", fontSize: 11, fontWeight: 800, letterSpacing: "0.1em",
                    }}>{t.toUpperCase()}</span>
                  </button>
                );
              })}
            </div>
            <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 8, lineHeight: 1.4 }}>
              Light mode uses a daylight-expedition palette with parchment and ink accents.
            </div>
          </div>
          <Divider />
          <ToggleRow icon={<Vibrate size={16} color="#FFD300" />} label="Reduced motion" desc="Disable kinetic transitions and pulses." value={reduced} onChange={setReduced} />
          <Divider />
          <ToggleRow icon={<Volume2 size={16} color="#43D17A" />} label="Scanner SFX" desc="Detection chimes and reveal stings." value={sfx} onChange={setSfx} />
        </Section>

        {/* Notifications */}
        <Section title="NOTIFICATIONS">
          <ToggleRow icon={<Bell size={16} color="#E60012" />} label="Daily missions" desc="Morning briefing at 9:00 AM." value={missions} onChange={setMissions} />
          <Divider />
          <ToggleRow icon={<Sparkles size={16} color="#FFD300" />} label="Rare alerts" desc="Notify when rarity ≥ Rare is awakened." value={rare} onChange={setRare} />
          <Divider />
          <ToggleRow icon={<Vibrate size={16} color="#FF6B4A" />} label="Streak reminder" desc="Nudge before your streak resets." value={streak} onChange={setStreak} />
          <Divider />
          <ToggleRow icon={<Smartphone size={16} color="#9DD8FF" />} label="Haptics" desc="Vibration on capture and reveal." value={haptics} onChange={setHaptics} />
        </Section>

        {/* Privacy & permissions */}
        <Section title="PRIVACY & PERMISSIONS">
          <NavRow icon={<Camera size={16} color="#E60012" />} label="Camera access" hint="Granted" />
          <Divider />
          <NavRow icon={<Globe size={16} color="#43D17A" />} label="Location" hint="While in use" />
          <Divider />
          <NavRow icon={<Shield size={16} color="#FFD300" />} label="AI usage policy" hint="" />
          <Divider />
          <div className="p-4 flex items-start gap-3" style={{ borderTop: "1px solid #2A1F1F" }}>
            <div className="size-8 rounded-md grid place-items-center mt-0.5" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
              <Shield size={14} color="#FFD300" />
            </div>
            <p style={{ color: "#8A7F76", fontSize: 11, lineHeight: 1.5 }}>
              Live camera detects object labels on-device. Labels (not images) are sent to the synthesis service to generate creatures. Photos are never stored.
            </p>
          </div>
        </Section>

        {/* Data */}
        <Section title="DATA">
          <ToggleRow icon={<Cloud size={16} color="#E60012" />} label="Sync collection" desc="Last synced 2 minutes ago." value={sync} onChange={setSync} />
          <Divider />
          <NavRow icon={<Database size={16} color="#9DD8FF" />} label="Storage" hint="184 MB" />
          <Divider />
          <NavRow icon={<FileText size={16} color="#C9C2B5" />} label="Export field journal" hint="PDF / JSON" />
          <Divider />
          <button className="w-full p-4 flex items-center gap-3 text-left" style={{ borderTop: "1px solid #2A1F1F" }}>
            <div className="size-8 rounded-md grid place-items-center" style={{ background: "#2a0d10", border: "1px solid #FF6B4A33" }}>
              <Database size={14} color="#FF6B4A" />
            </div>
            <div className="flex-1">
              <div style={{ color: "#FF6B4A", fontSize: 13, fontWeight: 600 }}>Clear scan cache</div>
              <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 1 }}>Removes locally queued scans.</div>
            </div>
          </button>
        </Section>

        {/* About */}
        <Section title="ABOUT">
          <NavRow icon={<HelpCircle size={16} color="#E60012" />} label="Help & Support" hint="" />
          <Divider />
          <NavRow icon={<FileText size={16} color="#C9C2B5" />} label="Terms & Privacy" hint="" />
          <Divider />
          <div className="p-4 flex items-center justify-between">
            <div>
              <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>Version</div>
              <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 1 }}>CreatureLens 1.4.0 · Build 2042</div>
            </div>
            <div className="px-2 py-1 rounded" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
              <span style={{ color: "#E60012", fontSize: 10, fontWeight: 800, letterSpacing: "0.15em" }}>UP TO DATE</span>
            </div>
          </div>
        </Section>

        {/* Sign out */}
        <button className="mt-5 w-full h-12 rounded-lg flex items-center justify-center gap-2" style={{
          background: "#1a0d10", border: "1px solid #FF6B4A33", color: "#FF6B4A", fontWeight: 700, fontSize: 13,
        }}>
          <LogOut size={16} /> Sign Out
        </button>

        <div className="mt-4 text-center" style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.2em", fontWeight: 600 }}>
          SCAN · AWAKEN · COLLECT
        </div>
      </div>
    </div>
  );
}

function Section({ title, children }: { title: string; children: any }) {
  return (
    <div className="mt-5">
      <div className="px-1 mb-2" style={{ color: "#8A7F76", fontSize: 10, letterSpacing: "0.25em", fontWeight: 700 }}>{title}</div>
      <div className="rounded-2xl overflow-hidden" style={{ background: "#15100F", border: "1px solid #2A1F1F" }}>
        {children}
      </div>
    </div>
  );
}

function Divider() { return <div style={{ height: 1, background: "#2A1F1F" }} />; }

function ToggleRow({ icon, label, desc, value, onChange }: { icon: any; label: string; desc?: string; value: boolean; onChange: (v: boolean) => void }) {
  return (
    <div className="p-4 flex items-center gap-3">
      <div className="size-8 rounded-md grid place-items-center shrink-0" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>{label}</div>
        {desc && <div style={{ color: "#8A7F76", fontSize: 11, marginTop: 1 }}>{desc}</div>}
      </div>
      <button onClick={() => onChange(!value)} className="relative shrink-0" style={{
        width: 44, height: 26, borderRadius: 13,
        background: value ? "#E60012" : "#2A1F1F",
        boxShadow: value ? "0 0 10px #E6001255" : "none",
        transition: "background 0.2s",
      }}>
        <motion.div
          animate={{ x: value ? 20 : 2 }}
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
          className="absolute top-0.5 size-[22px] rounded-full"
          style={{ background: "#F5F1E8", boxShadow: "0 1px 4px rgba(0,0,0,0.4)" }}
        />
      </button>
    </div>
  );
}

function NavRow({ icon, label, hint }: { icon: any; label: string; hint: string }) {
  return (
    <button className="w-full p-4 flex items-center gap-3 text-left">
      <div className="size-8 rounded-md grid place-items-center shrink-0" style={{ background: "#1A1414", border: "1px solid #2A1F1F" }}>
        {icon}
      </div>
      <div className="flex-1">
        <div style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600 }}>{label}</div>
      </div>
      {hint && <span style={{ color: "#8A7F76", fontSize: 11 }}>{hint}</span>}
      <ChevronRight size={14} color="#8A7F76" />
    </button>
  );
}

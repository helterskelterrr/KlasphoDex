import { useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import { Home as HomeIcon, BookOpen, User, Target, Trophy } from "lucide-react";
import { HomeScreen } from "./components/screens/HomeScreen";
import { ScanScreen } from "./components/screens/ScanScreen";
import { SynthesisScreen } from "./components/screens/SynthesisScreen";
import { RevealScreen } from "./components/screens/RevealScreen";
import { JournalScreen } from "./components/screens/JournalScreen";
import { DetailScreen } from "./components/screens/DetailScreen";
import { ProfileScreen } from "./components/screens/ProfileScreen";
import { QuestsScreen } from "./components/screens/QuestsScreen";
import { AchievementsScreen } from "./components/screens/AchievementsScreen";
import { SettingsScreen } from "./components/screens/SettingsScreen";
import { DeckBuilderScreen } from "./components/screens/DeckBuilderScreen";
import { TrialSetupScreen } from "./components/screens/TrialSetupScreen";
import { BattleScreen } from "./components/screens/BattleScreen";
import { TrialResultScreen } from "./components/screens/TrialResultScreen";
import { COLLECTION, Difficulty } from "./components/trial-data";

type Screen =
  | "home" | "scan" | "synth" | "reveal" | "journal" | "detail" | "profile"
  | "quests" | "achievements" | "settings"
  | "deck" | "trialSetup" | "battle" | "victory" | "defeat";

export default function App() {
  const [screen, setScreen] = useState<Screen>("home");
  const [detailId, setDetailId] = useState("c1");
  const [deck, setDeck] = useState<string[]>(() => COLLECTION.slice(0, 8).map(c => c.id));
  const [difficulty, setDifficulty] = useState<Difficulty>("Wild");
  const [battleResult, setBattleResult] = useState<{ turns: number; reason?: "resolve" | "timeout" }>({ turns: 0 });

  const isFullBleed =
    screen === "scan" || screen === "synth" || screen === "reveal" || screen === "detail" ||
    screen === "achievements" || screen === "settings" ||
    screen === "deck" || screen === "trialSetup" || screen === "battle" || screen === "victory" || screen === "defeat";
  const showNav = screen === "home" || screen === "journal" || screen === "profile" || screen === "quests";

  const openDetail = (id: string) => { setDetailId(id); setScreen("detail"); };

  return (
    <div className="size-full grid place-items-center p-6 overflow-auto relative" style={{
      background: "#E60012",
      backgroundImage:
        "repeating-linear-gradient(-45deg, transparent 0 18px, rgba(0,0,0,0.18) 18px 20px), radial-gradient(#0A0A0A 1.5px, transparent 1.8px)",
      backgroundSize: "auto, 8px 8px",
    }}>
      {/* Brand mark */}
      <div className="fixed top-6 left-6 z-10 flex items-center gap-2.5 select-none" style={{ transform: "rotate(-2deg)" }}>
        <div className="size-9 grid place-items-center" style={{
          background: "#FFD300", border: "2px solid #0A0A0A", boxShadow: "2px 2px 0 #0A0A0A",
          clipPath: "polygon(15% 0,100% 0,85% 100%,0 100%)",
        }}>
          <Target size={16} color="#0A0A0A" strokeWidth={3} />
        </div>
        <div style={{ background: "#0A0A0A", padding: "3px 8px", border: "2px solid #FFD300" }}>
          <div className="cl-display" style={{ color: "#F5F1E8", fontSize: 14, lineHeight: 1 }}>CREATURELENS</div>
          <div style={{ color: "#FFD300", fontSize: 8, letterSpacing: "0.3em", fontWeight: 800, textTransform: "uppercase", marginTop: 1 }}>v1.4 · PROTOTYPE</div>
        </div>
      </div>

      {/* Phone frame */}
      <div className="relative" style={{ width: 390, height: 844 }}>
        <div className="relative size-full rounded-[44px] overflow-hidden" style={{
          background: "#0A0A0A",
          border: "9px solid #000000",
          boxShadow: "0 30px 60px -20px rgba(0,0,0,0.6), 0 0 0 1px #2A1F1F",
        }}>
          {/* dynamic island */}
          <div className="absolute top-2 left-1/2 -translate-x-1/2 z-30 w-28 h-7 rounded-full" style={{ background: "#000" }} />

          {/* status bar */}
          <div className="absolute top-2.5 inset-x-0 z-20 px-7 flex items-center justify-between cl-num" style={{ color: "#F5F1E8", fontSize: 13, fontWeight: 600, height: 20 }}>
            <span>9:41</span>
            <div className="flex items-center gap-1.5">
              <SignalIcon />
              <WifiIcon />
              <BatteryIcon />
            </div>
          </div>

          {/* Screen content */}
          <div className="absolute inset-0 pt-7 overflow-hidden">
            <AnimatePresence mode="wait">
              <motion.div
                key={screen}
                initial={{ opacity: 0, y: isFullBleed ? 0 : 6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.25 }}
                className="absolute inset-0 overflow-y-auto"
              >
                {screen === "home" && <HomeScreen onScan={() => setScreen("scan")} onOpenCreature={openDetail} onFieldTrials={() => setScreen("deck")} />}
                {screen === "scan" && <ScanScreen onCapture={() => setScreen("synth")} onClose={() => setScreen("home")} />}
                {screen === "synth" && <SynthesisScreen onDone={() => setScreen("reveal")} />}
                {screen === "reveal" && <RevealScreen onAdd={() => setScreen("journal")} onScanAgain={() => setScreen("scan")} onDetail={() => openDetail("c1")} />}
                {screen === "journal" && <JournalScreen onOpenCreature={openDetail} />}
                {screen === "detail" && <DetailScreen id={detailId} onBack={() => setScreen("journal")} />}
                {screen === "profile" && <ProfileScreen onOpenAchievements={() => setScreen("achievements")} onOpenSettings={() => setScreen("settings")} />}
                {screen === "quests" && <QuestsScreen />}
                {screen === "achievements" && <AchievementsScreen onBack={() => setScreen("profile")} />}
                {screen === "settings" && <SettingsScreen onBack={() => setScreen("profile")} />}
                {screen === "deck" && <DeckBuilderScreen initialDeckIds={deck} onBack={() => setScreen("home")} onStartTrial={(ids) => { setDeck(ids); setScreen("trialSetup"); }} />}
                {screen === "trialSetup" && <TrialSetupScreen deckIds={deck} onBack={() => setScreen("deck")} onEdit={() => setScreen("deck")} onStart={(d) => { setDifficulty(d); setScreen("battle"); }} />}
                {screen === "battle" && (
                  <BattleScreen
                    deckIds={deck} difficulty={difficulty}
                    onClose={() => setScreen("trialSetup")}
                    onVictory={(turns) => { setBattleResult({ turns }); setScreen("victory"); }}
                    onDefeat={(reason) => { setBattleResult({ turns: 0, reason }); setScreen("defeat"); }}
                  />
                )}
                {screen === "victory" && (
                  <TrialResultScreen victory difficulty={difficulty} deckIds={deck} turns={battleResult.turns}
                    onRetry={() => setScreen("trialSetup")} onEdit={() => setScreen("deck")} onHome={() => setScreen("home")} onScan={() => setScreen("scan")} />
                )}
                {screen === "defeat" && (
                  <TrialResultScreen victory={false} difficulty={difficulty} deckIds={deck} turns={battleResult.turns} defeatReason={battleResult.reason}
                    onRetry={() => setScreen("battle")} onEdit={() => setScreen("deck")} onHome={() => setScreen("home")} onScan={() => setScreen("scan")} />
                )}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Bottom nav */}
          {showNav && (
            <div className="absolute bottom-0 inset-x-0 z-20 px-3 pb-2 pt-1.5" style={{
              background: "rgba(5,7,13,0.95)",
              borderTop: "1px solid #2A1F1F",
              backdropFilter: "blur(12px)",
            }}>
              <div className="relative flex items-center justify-around" style={{ height: 56 }}>
                <NavBtn icon={<HomeIcon size={20} strokeWidth={2} />} label="Home" active={screen === "home"} onClick={() => setScreen("home")} />
                <NavBtn icon={<BookOpen size={20} strokeWidth={2} />} label="Journal" active={screen === "journal"} onClick={() => setScreen("journal")} />
                <button onClick={() => setScreen("scan")} className="relative -mt-5 active:translate-y-0.5 transition-transform">
                  <div className="size-14 grid place-items-center" style={{
                    background: "#E60012",
                    border: "3px solid #0A0A0A",
                    boxShadow: "0 4px 0 #FFD300, 0 4px 0 1px #0A0A0A",
                    clipPath: "polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)",
                  }}>
                    <Target size={22} color="#F5F1E8" strokeWidth={3} />
                  </div>
                </button>
                <NavBtn icon={<Trophy size={20} strokeWidth={2} />} label="Quests" active={screen === "quests"} onClick={() => setScreen("quests")} />
                <NavBtn icon={<User size={20} strokeWidth={2} />} label="Profile" active={screen === "profile"} onClick={() => setScreen("profile")} />
              </div>
              <div className="mx-auto w-32 h-1 rounded-full" style={{ background: "#2A1F1F" }} />
            </div>
          )}
        </div>
      </div>

    </div>
  );
}

function NavBtn({ icon, label, active, onClick, disabled }: { icon: any; label: string; active: boolean; onClick: () => void; disabled?: boolean }) {
  return (
    <button onClick={onClick} disabled={disabled} className="flex flex-col items-center gap-1 py-2 px-3 relative" style={{ opacity: disabled ? 0.4 : 1 }}>
      <span style={{ color: active ? "#FFD300" : "#8A7F76", transition: "color 0.15s" }}>{icon}</span>
      <span className="cl-display" style={{ color: active ? "#FFD300" : "#8A7F76", fontSize: 9, letterSpacing: "0.12em" }}>{label.toUpperCase()}</span>
      {active && (
        <motion.div layoutId="nav-active" className="absolute -bottom-1 left-1/2 -translate-x-1/2" style={{ width: 18, height: 3, background: "#E60012", boxShadow: "0 2px 0 #FFD300" }} />
      )}
    </button>
  );
}

function SignalIcon() {
  return (
    <svg width="16" height="11" viewBox="0 0 16 11" fill="none">
      {[0,1,2,3].map(i => (
        <rect key={i} x={i*4} y={11 - (i+1)*2.5 - 1} width="3" height={(i+1)*2.5 + 1} rx="0.5" fill="#F5F1E8" />
      ))}
    </svg>
  );
}
function WifiIcon() {
  return (
    <svg width="15" height="11" viewBox="0 0 15 11" fill="none">
      <path d="M7.5 1c2.4 0 4.6.9 6.3 2.4l-1.4 1.5A7 7 0 007.5 3a7 7 0 00-4.9 1.9L1.2 3.4A9 9 0 017.5 1z" fill="#F5F1E8" />
      <path d="M7.5 5a5 5 0 013.6 1.5L9.7 8a3 3 0 00-4.4 0L3.9 6.5A5 5 0 017.5 5z" fill="#F5F1E8" />
      <circle cx="7.5" cy="9.5" r="1.2" fill="#F5F1E8" />
    </svg>
  );
}
function BatteryIcon() {
  return (
    <div className="flex items-center gap-0.5">
      <div className="relative" style={{ width: 24, height: 11, border: "1px solid #F5F1E866", borderRadius: 3 }}>
        <div className="absolute" style={{ inset: 1.5, width: "75%", background: "#F5F1E8", borderRadius: 1.5 }} />
      </div>
      <div style={{ width: 1.5, height: 4, background: "#F5F1E866", borderRadius: 1 }} />
    </div>
  );
}

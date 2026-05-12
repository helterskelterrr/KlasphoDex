import { Creature } from "./creature-data";

export function CreaturePortrait({ creature, size = 200 }: { creature: Creature; size?: number }) {
  const c = creature;
  const seed = c.id.charCodeAt(1) || 1;
  const eyeY = 52 + (seed % 5);
  const earCurve = 30 + (seed % 10);
  return (
    <svg viewBox="0 0 200 200" width={size} height={size} style={{ display: "block" }}>
      <defs>
        <radialGradient id={`bg-${c.id}`} cx="50%" cy="55%" r="60%">
          <stop offset="0%" stopColor={c.hue} stopOpacity="0.55" />
          <stop offset="60%" stopColor={c.hue} stopOpacity="0.12" />
          <stop offset="100%" stopColor="#0A0A0A" stopOpacity="0" />
        </radialGradient>
        <radialGradient id={`body-${c.id}`} cx="50%" cy="40%" r="70%">
          <stop offset="0%" stopColor={c.hue} stopOpacity="1" />
          <stop offset="100%" stopColor="#8B0008" stopOpacity="0.85" />
        </radialGradient>
        <linearGradient id={`shine-${c.id}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#fff" stopOpacity="0.6" />
          <stop offset="100%" stopColor="#fff" stopOpacity="0" />
        </linearGradient>
      </defs>

      <circle cx="100" cy="110" r="90" fill={`url(#bg-${c.id})`} />

      {/* aura rings */}
      <circle cx="100" cy="110" r="78" fill="none" stroke={c.hue} strokeOpacity="0.18" strokeWidth="1" strokeDasharray="2 6" />
      <circle cx="100" cy="110" r="64" fill="none" stroke={c.hue} strokeOpacity="0.12" strokeWidth="1" />

      {/* ears */}
      <path d={`M 60 80 Q ${earCurve + 30} 30 95 70 Z`} fill={`url(#body-${c.id})`} opacity="0.95" />
      <path d={`M 140 80 Q ${170 - earCurve} 30 105 70 Z`} fill={`url(#body-${c.id})`} opacity="0.95" />

      {/* body blob */}
      <ellipse cx="100" cy="120" rx="56" ry="58" fill={`url(#body-${c.id})`} />
      <ellipse cx="100" cy="100" rx="52" ry="34" fill={`url(#shine-${c.id})`} opacity="0.35" />

      {/* eyes */}
      <ellipse cx="82" cy={eyeY + 60} rx="7" ry="9" fill="#0A0A0A" />
      <ellipse cx="118" cy={eyeY + 60} rx="7" ry="9" fill="#0A0A0A" />
      <circle cx="84" cy={eyeY + 58} r="2.2" fill="#fff" />
      <circle cx="120" cy={eyeY + 58} r="2.2" fill="#fff" />

      {/* mouth */}
      <path d={`M 92 ${eyeY + 80} Q 100 ${eyeY + 86} 108 ${eyeY + 80}`} stroke="#0A0A0A" strokeWidth="2" strokeLinecap="round" fill="none" />

      {/* element mark */}
      <circle cx="100" cy="170" r="4" fill={c.hue} />
    </svg>
  );
}

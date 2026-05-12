import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

export const openRouterApiKey = defineSecret("OPENROUTER_API_KEY");

const endpoint = "https://openrouter.ai/api/v1/chat/completions";
export const modelCandidates = [
  "google/gemma-4-31b-it:free",
  "google/gemma-4-26b-a4b-it:free",
  "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
] as const;

export interface GenerateCreatureRequest {
  labels: string[];
  userLevel: number;
  streakMultiplier: number;
  imageBase64?: string;
  imageMimeType?: string;
}

export type CreaturePayload = Record<string, unknown>;
type OpenRouterMessage = {
  role: "user";
  content: string | Array<
    | { type: "text"; text: string }
    | { type: "image_url"; image_url: { url: string } }
  >;
};

export function validateGenerateCreatureRequest(
  data: unknown,
): GenerateCreatureRequest {
  if (!data || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Request body must be an object.");
  }
  const value = data as Record<string, unknown>;
  const labels = value.labels;
  const userLevel = value.userLevel;
  const streakMultiplier = value.streakMultiplier;
  const imageBase64 = value.imageBase64;
  const imageMimeType = value.imageMimeType;

  if (
    !Array.isArray(labels) ||
    labels.length === 0 ||
    labels.length > 5 ||
    labels.some((label) => typeof label !== "string" || label.trim() === "")
  ) {
    throw new HttpsError(
      "invalid-argument",
      "labels must contain 1 to 5 non-empty strings.",
    );
  }
  if (
    typeof userLevel !== "number" ||
    !Number.isInteger(userLevel) ||
    userLevel < 1 ||
    userLevel > 100
  ) {
    throw new HttpsError(
      "invalid-argument",
      "userLevel must be an integer from 1 to 100.",
    );
  }
  if (
    typeof streakMultiplier !== "number" ||
    !Number.isInteger(streakMultiplier) ||
    streakMultiplier < 0 ||
    streakMultiplier > 365
  ) {
    throw new HttpsError(
      "invalid-argument",
      "streakMultiplier must be an integer from 0 to 365.",
    );
  }
  if (
    imageBase64 !== undefined &&
    (
      typeof imageBase64 !== "string" ||
      imageBase64.length > 5_000_000 ||
      !/^[A-Za-z0-9+/=]+$/.test(imageBase64)
    )
  ) {
    throw new HttpsError(
      "invalid-argument",
      "imageBase64 must be a base64 string up to 5MB.",
    );
  }
  if (
    imageMimeType !== undefined &&
    (
      typeof imageMimeType !== "string" ||
      !["image/jpeg", "image/png", "image/webp"].includes(imageMimeType)
    )
  ) {
    throw new HttpsError(
      "invalid-argument",
      "imageMimeType must be image/jpeg, image/png, or image/webp.",
    );
  }

  return {
    labels: labels.map((label) => label.trim()),
    userLevel,
    streakMultiplier,
    ...(imageBase64 ? {
      imageBase64,
      imageMimeType: typeof imageMimeType === "string" ?
        imageMimeType :
        "image/jpeg",
    } : {}),
  };
}

export function buildCreaturePrompt(request: GenerateCreatureRequest): string {
  return `You are a fantasy creature designer for CreatureLens.

The user scanned a real-world object and the AI detected these labels: ${request.labels.join(", ")}.
${request.imageBase64 ? "A final camera image is attached. Use the image as the source of truth when labels look generic or uncertain." : ""}

Return ONLY valid JSON with this exact structure:
{
  "name": "Creative creature name",
  "type": "One of: Fire, Water, Earth, Air, Electric, Nature, Shadow, Light",
  "rarity": "One of: Common, Uncommon, Rare, Epic, Legendary",
  "hp": <number 30-100>,
  "attack": <number 20-100>,
  "defense": <number 20-100>,
  "speed": <number 20-100>,
  "abilities": [
    {"name": "Ability Name", "description": "What it does", "type": "Element type"}
  ],
  "lore": "A short, atmospheric backstory paragraph"
}

Rules:
- Creature should be inspired by the scanned object but fantastical.
- Higher stats for rarer creatures.
- User level is ${request.userLevel}.
- Streak multiplier is ${request.streakMultiplier}.
- Generate 2-3 abilities.
Contoh Output yang Benar: {"name": "Ignis Fern", "type": "Fire", "rarity": "Rare", "hp": 65, "attack": 70, "defense": 40, "speed": 55, "abilities": [{"name": "Ember Spores", "description": "Ignites the air around it.", "type": "Fire"}], "lore": "Born from the ash of a burning forest."}`;
}

export function buildOpenRouterMessages(
  request: GenerateCreatureRequest,
): OpenRouterMessage[] {
  const prompt = buildCreaturePrompt(request);
  if (!request.imageBase64) {
    return [{ role: "user", content: prompt }];
  }

  return [
    {
      role: "user",
      content: [
        { type: "text", text: prompt },
        {
          type: "image_url",
          image_url: {
            url: `data:${request.imageMimeType ?? "image/jpeg"};base64,${request.imageBase64}`,
          },
        },
      ],
    },
  ];
}

export function extractJsonObject(text: string): CreaturePayload {
  const codeBlock = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  const candidate = codeBlock?.[1] ?? text.match(/\{[\s\S]*\}/)?.[0] ?? text;
  try {
    const parsed = JSON.parse(candidate.trim());
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      throw new Error("JSON response must be an object.");
    }
    return parsed as CreaturePayload;
  } catch (error) {
    throw new HttpsError(
      "internal",
      `AI response was not valid creature JSON: ${String(error)}`,
    );
  }
}

export function normalizeCreaturePayload(payload: CreaturePayload): CreaturePayload {
  return {
    name: typeof payload.name === "string" ? payload.name : "Mystery Creature",
    type: typeof payload.type === "string" ? payload.type : "Nature",
    rarity: typeof payload.rarity === "string" ? payload.rarity : "Common",
    hp: payload.hp,
    attack: payload.attack,
    defense: payload.defense,
    speed: payload.speed,
    abilities: Array.isArray(payload.abilities) ? payload.abilities : [],
    lore: typeof payload.lore === "string" ? payload.lore : "",
  };
}

export async function callOpenRouter(
  apiKey: string,
  request: GenerateCreatureRequest,
): Promise<CreaturePayload> {
  for (const [index, model] of modelCandidates.entries()) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20000);
    let response: Response;
    try {
      response = await fetch(endpoint, {
        method: "POST",
        signal: controller.signal,
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
          "X-OpenRouter-Title": "CreatureLens",
        },
        body: JSON.stringify({
          model,
          messages: buildOpenRouterMessages(request),
          temperature: 0.5,
          response_format: { type: "json_object" },
        }),
      });
    } finally {
      clearTimeout(timeout);
    }

    if (!response.ok) {
      const retryable = response.status === 429 || response.status >= 500;
      if (retryable && index < modelCandidates.length - 1) continue;
      throw new HttpsError(
        "unavailable",
        `OpenRouter request for ${model} failed with status ${response.status}.`,
      );
    }

    const data = (await response.json()) as Record<string, unknown>;
    const choices = data.choices;
    const first = Array.isArray(choices) ? choices[0] : undefined;
    const message = first && typeof first === "object" ?
      (first as Record<string, unknown>).message :
      undefined;
    const content = message && typeof message === "object" ?
      (message as Record<string, unknown>).content :
      undefined;
    if (typeof content !== "string") {
      throw new HttpsError("internal", "OpenRouter returned no text content.");
    }
    return normalizeCreaturePayload(extractJsonObject(content));
  }
  throw new HttpsError("unavailable", "OpenRouter request failed.");
}

export const generateCreature = onCall(
  { secrets: [openRouterApiKey], timeoutSeconds: 30 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in before generating.");
    }
    const input = validateGenerateCreatureRequest(request.data);
    return callOpenRouter(openRouterApiKey.value(), input);
  },
);

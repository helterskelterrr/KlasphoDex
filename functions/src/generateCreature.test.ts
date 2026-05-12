import assert from "node:assert/strict";
import test from "node:test";

import {
  buildOpenRouterMessages,
  buildCreaturePrompt,
  callOpenRouter,
  extractJsonObject,
  normalizeCreaturePayload,
  validateGenerateCreatureRequest,
} from "./generateCreature";

test("validates creature generation request payload", () => {
  const request = validateGenerateCreatureRequest({
    labels: [" ceramic mug 94% "],
    userLevel: 8,
    streakMultiplier: 2,
  });

  assert.deepEqual(request, {
    labels: ["ceramic mug 94%"],
    userLevel: 8,
    streakMultiplier: 2,
  });
});

test("validates optional scan image payload", () => {
  const request = validateGenerateCreatureRequest({
    labels: ["unknown object 50%"],
    userLevel: 8,
    streakMultiplier: 2,
    imageBase64: "ZmFrZS1pbWFnZQ==",
    imageMimeType: "image/jpeg",
  });

  assert.equal(request.imageBase64, "ZmFrZS1pbWFnZQ==");
  assert.equal(request.imageMimeType, "image/jpeg");
});

test("rejects missing labels", () => {
  assert.throws(
    () => validateGenerateCreatureRequest({
      labels: [],
      userLevel: 8,
      streakMultiplier: 2,
    }),
    /labels must contain 1 to 5/,
  );
});

test("builds prompt with labels and JSON response example", () => {
  const prompt = buildCreaturePrompt({
    labels: ["fern 91%"],
    userLevel: 3,
    streakMultiplier: 1,
  });

  assert.match(prompt, /fern 91%/);
  assert.match(prompt, /Contoh Output yang Benar/);
  assert.match(prompt, /"name"/);
});

test("builds multimodal OpenRouter message when scan image is present", () => {
  const messages = buildOpenRouterMessages({
    labels: ["unknown object 50%"],
    userLevel: 3,
    streakMultiplier: 1,
    imageBase64: "ZmFrZS1pbWFnZQ==",
    imageMimeType: "image/jpeg",
  });

  const content = messages[0].content;
  assert.ok(Array.isArray(content));
  assert.equal(content[0].type, "text");
  assert.equal(content[1].type, "image_url");
  assert.deepEqual(content[1], {
    type: "image_url",
    image_url: {
      url: "data:image/jpeg;base64,ZmFrZS1pbWFnZQ==",
    },
  });
});

test("extracts JSON from fenced model output", () => {
  const payload = extractJsonObject('```json\n{"name":"Ignis Fern"}\n```');

  assert.deepEqual(payload, {name: "Ignis Fern"});
});

test("extracts JSON from prose-wrapped model output", () => {
  const payload = extractJsonObject(
    'Here is the creature:\n{"name":"Cupflare","type":"Fire"}\nEnjoy!',
  );

  assert.deepEqual(payload, {name: "Cupflare", type: "Fire"});
});

test("extracts JSON from unlabeled fenced model output", () => {
  const payload = extractJsonObject('```\n{"name":"Mossbyte"}\n```');

  assert.deepEqual(payload, {name: "Mossbyte"});
});

test("throws on malformed model JSON", () => {
  assert.throws(() => extractJsonObject("not json"), /valid creature JSON/);
});

test("normalizes missing optional creature fields", () => {
  const payload = normalizeCreaturePayload({name: "Cupflare"});

  assert.deepEqual(payload, {
    name: "Cupflare",
    type: "Nature",
    rarity: "Common",
    hp: undefined,
    attack: undefined,
    defense: undefined,
    speed: undefined,
    abilities: [],
    lore: "",
  });
});

test("calls only the configured Gemma model", async (t) => {
  const originalFetch = globalThis.fetch;
  const models: string[] = [];

  globalThis.fetch = (async (_url, init) => {
    const body = JSON.parse(String(init?.body)) as Record<string, unknown>;
    models.push(String(body.model));

    return new Response(
      JSON.stringify({
        model: body.model,
        choices: [
          {
            finish_reason: "stop",
            message: {
              content: JSON.stringify({
                name: "Mugleaf Guardian",
                type: "Nature",
                rarity: "Rare",
                hp: 70,
                attack: 75,
                defense: 50,
                speed: 60,
                abilities: [
                  {
                    name: "Porcelain Grove",
                    description: "Raises leaf-shaped ceramic shields.",
                    type: "Nature",
                  },
                ],
                lore: "A guardian awakened from a mug beside a living plant.",
              }),
            },
          },
        ],
      }),
      {status: 200},
    );
  }) as typeof fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  const payload = await callOpenRouter("test-key", {
    labels: ["ceramic mug 94%"],
    userLevel: 8,
    streakMultiplier: 2,
    imageBase64: "ZmFrZS1pbWFnZQ==",
    imageMimeType: "image/jpeg",
  });

  assert.deepEqual(models, [
    "google/gemma-4-31b-it:free",
  ]);
  assert.equal(payload.name, "Mugleaf Guardian");
});

test("does not fall back to the free model router when Gemma is rate-limited", async (t) => {
  const originalFetch = globalThis.fetch;
  const models: string[] = [];

  globalThis.fetch = (async (_url, init) => {
    const body = JSON.parse(String(init?.body)) as Record<string, unknown>;
    models.push(String(body.model));

    return new Response(
      JSON.stringify({error: {message: "primary model rate-limited"}}),
      {status: 429},
    );
  }) as typeof fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  await assert.rejects(
    () => callOpenRouter("test-key", {
      labels: ["ceramic mug 94%"],
      userLevel: 8,
      streakMultiplier: 2,
    }),
    /failed with status 429/,
  );

  assert.deepEqual(models, [
    "google/gemma-4-31b-it:free",
    "google/gemma-4-26b-a4b-it:free",
    "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
  ]);
});

test("falls back to Gemma 26B A4B when primary Gemma is rate-limited", async (t) => {
  const originalFetch = globalThis.fetch;
  const models: string[] = [];

  globalThis.fetch = (async (_url, init) => {
    const body = JSON.parse(String(init?.body)) as Record<string, unknown>;
    const model = String(body.model);
    models.push(model);

    if (model === "google/gemma-4-31b-it:free") {
      return new Response(
        JSON.stringify({error: {message: "primary model rate-limited"}}),
        {status: 429},
      );
    }

    return new Response(
      JSON.stringify({
        model,
        choices: [
          {
            finish_reason: "stop",
            message: {
              content: JSON.stringify({
                name: "A4B Backup Sprite",
                type: "Electric",
                rarity: "Uncommon",
                hp: 64,
                attack: 70,
                defense: 58,
                speed: 76,
                abilities: [
                  {
                    name: "Backup Spark",
                    description: "Triggers when the primary Gemma path is busy.",
                    type: "Electric",
                  },
                ],
                lore: "A fallback creature generated by Gemma 26B A4B.",
              }),
            },
          },
        ],
      }),
      {status: 200},
    );
  }) as typeof fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  const payload = await callOpenRouter("test-key", {
    labels: ["speaker case 73%"],
    userLevel: 8,
    streakMultiplier: 2,
  });

  assert.deepEqual(models, [
    "google/gemma-4-31b-it:free",
    "google/gemma-4-26b-a4b-it:free",
  ]);
  assert.equal(payload.name, "A4B Backup Sprite");
});

test("falls back to Nemotron Omni when both Gemmas are rate-limited", async (t) => {
  const originalFetch = globalThis.fetch;
  const models: string[] = [];

  globalThis.fetch = (async (_url, init) => {
    const body = JSON.parse(String(init?.body)) as Record<string, unknown>;
    const model = String(body.model);
    models.push(model);

    if (model.startsWith("google/gemma-4-")) {
      return new Response(
        JSON.stringify({error: {message: "gemma model rate-limited"}}),
        {status: 429},
      );
    }

    return new Response(
      JSON.stringify({
        model,
        choices: [
          {
            finish_reason: "stop",
            message: {
              content: JSON.stringify({
                name: "Nemotron Fieldseer",
                type: "Light",
                rarity: "Rare",
                hp: 72,
                attack: 68,
                defense: 61,
                speed: 82,
                abilities: [
                  {
                    name: "Omni Read",
                    description: "Reads the image after both Gemma paths are busy.",
                    type: "Light",
                  },
                ],
                lore: "A perception sprite generated by the Nemotron plan C.",
              }),
            },
          },
        ],
      }),
      {status: 200},
    );
  }) as typeof fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  const payload = await callOpenRouter("test-key", {
    labels: ["unknown object 50%"],
    userLevel: 8,
    streakMultiplier: 2,
    imageBase64: "ZmFrZS1pbWFnZQ==",
    imageMimeType: "image/jpeg",
  });

  assert.deepEqual(models, [
    "google/gemma-4-31b-it:free",
    "google/gemma-4-26b-a4b-it:free",
    "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
  ]);
  assert.equal(payload.name, "Nemotron Fieldseer");
});

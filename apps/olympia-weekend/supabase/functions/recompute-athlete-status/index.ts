// Olympia Weekend — recompute-athlete-status
//
// Runs every 5 minutes (via `supabase functions schedule` — see the
// `supabase/config.toml` snippet in PLAN.md). For every appearance with
// >= 2 distinct device_ids in `sightings`, marks that appearance as
// `confirmed` in the in-memory athletes payload, then writes the
// merged blob to Storage at `olympia-live/athletes.json`.
//
// The app fetches this file on open (with `?v=<timestamp>` to bust CDN
// caches). Offline devices keep using the bundled athletes.json.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.3";
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

type Athlete = {
  id: string;
  name: string;
  divisionId: string;
  country: string;
  tagline: string;
  instagram: string | null;
  booth?: string | null;
  appearances: Appearance[];
};

type Appearance = {
  date: string;
  start: string;
  end?: string | null;
  venueId: string;
  booth: string;
  sponsor?: string | null;
  status: "reported" | "confirmed";
  confirmations: number;
  source: string;
};

function appearanceKey(a: { athleteId: string; date: string; start: string; venueId: string; booth: string }) {
  return `${a.athleteId}|${a.date}|${a.start}|${a.venueId}|${a.booth}`;
}

serve(async () => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) {
    return new Response("missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY", { status: 500 });
  }

  const client = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  // 1. Load the bundled athletes.json seed. In production we keep the
  //    latest seed uploaded to Storage as `olympia-live/athletes.seed.json`;
  //    the deploy step (see PLAN.md) uploads it once at release time.
  const seedResp = await client.storage
    .from("olympia-live")
    .download("athletes.seed.json");
  if (seedResp.error || !seedResp.data) {
    return new Response(
      `no seed athletes.seed.json in olympia-live (${seedResp.error?.message ?? "empty"})`,
      { status: 500 },
    );
  }
  const seed = JSON.parse(await seedResp.data.text()) as { athletes: Athlete[] };

  // 2. Count distinct device_ids per appearance_key.
  const { data: rows, error } = await client
    .from("sightings")
    .select("appearance_key, device_id");
  if (error) {
    return new Response(`select sightings failed: ${error.message}`, { status: 500 });
  }

  const distinctByAppearance = new Map<string, Set<string>>();
  for (const r of rows ?? []) {
    const key = r.appearance_key as string;
    const set = distinctByAppearance.get(key) ?? new Set<string>();
    set.add(r.device_id as string);
    distinctByAppearance.set(key, set);
  }

  // 3. Merge counts into the seed.
  for (const athlete of seed.athletes) {
    for (const app of athlete.appearances) {
      const key = appearanceKey({
        athleteId: athlete.id,
        date: app.date,
        start: app.start,
        venueId: app.venueId,
        booth: app.booth,
      });
      const distinct = distinctByAppearance.get(key)?.size ?? 0;
      app.confirmations = distinct;
      app.status = distinct >= 2 ? "confirmed" : "reported";
    }
  }

  // 4. Upload the merged file.
  const payload = new Blob([JSON.stringify(seed)], { type: "application/json" });
  const uploadResp = await client.storage
    .from("olympia-live")
    .upload("athletes.json", payload, {
      cacheControl: "60",
      upsert: true,
      contentType: "application/json",
    });
  if (uploadResp.error) {
    return new Response(`upload failed: ${uploadResp.error.message}`, { status: 500 });
  }

  return new Response(
    JSON.stringify({
      ok: true,
      athletes: seed.athletes.length,
      distinctAppearances: distinctByAppearance.size,
    }),
    { headers: { "content-type": "application/json" } },
  );
});

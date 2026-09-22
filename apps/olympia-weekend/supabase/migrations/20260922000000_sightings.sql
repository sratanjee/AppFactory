-- Olympia Weekend — sightings table + policies.
--
-- The app is anon-only (no login). Users report which athletes they
-- see at which booth; two distinct device_ids on the same appearance
-- flips the appearance's status from "reported" to "confirmed" (see
-- the recompute-athlete-status edge function).
--
-- Rate limit: 30 sightings/device/hour. Enforced by a BEFORE INSERT
-- trigger, not by RLS, so the failure surfaces as a proper error
-- message the app can show.

set search_path = public;

create table if not exists public.sightings (
  id            uuid primary key default gen_random_uuid(),
  athlete_id    text not null,
  appearance_key text not null,
  device_id     text not null,
  created_at    timestamptz not null default now()
);

create index if not exists sightings_appearance_idx
  on public.sightings (appearance_key, created_at desc);

create index if not exists sightings_device_recent_idx
  on public.sightings (device_id, created_at desc);

-- Unique per (appearance, device) — a device can only confirm once per
-- appearance. Additional inserts collapse silently on the client.
create unique index if not exists sightings_unique_per_device
  on public.sightings (appearance_key, device_id);

alter table public.sightings enable row level security;

-- Anon insert allowed; no auth column to check. Rate limit lives in the
-- trigger below so we can raise a friendly error.
drop policy if exists "anon can insert sightings" on public.sightings;
create policy "anon can insert sightings"
  on public.sightings
  for insert
  to anon, authenticated
  with check (true);

-- Everyone can read raw sightings (the public athletes.json is derived
-- from these; keeping raw select public makes debugging easier).
drop policy if exists "anyone can read sightings" on public.sightings;
create policy "anyone can read sightings"
  on public.sightings
  for select
  to anon, authenticated
  using (true);

-- ---- Rate-limit trigger ----

create or replace function public.sightings_rate_limit()
returns trigger
language plpgsql
as $$
declare
  recent_count int;
begin
  select count(*)
    into recent_count
    from public.sightings
   where device_id = new.device_id
     and created_at > now() - interval '1 hour';
  if recent_count >= 30 then
    raise exception 'rate_limited'
      using detail = 'more than 30 sightings from this device in the last hour';
  end if;
  return new;
end;
$$;

drop trigger if exists sightings_rate_limit_trg on public.sightings;
create trigger sightings_rate_limit_trg
  before insert on public.sightings
  for each row execute function public.sightings_rate_limit();

-- ---- Storage bucket for the derived athletes.json ----
-- The edge function rewrites this file every 5 minutes so the app can
-- pull the live confirmation status without opening a websocket.

insert into storage.buckets (id, name, public)
  values ('olympia-live', 'olympia-live', true)
  on conflict (id) do update set public = excluded.public;

-- Public read on that bucket. No policy needed for public reads once
-- the bucket is public, but be explicit for the object-level too.
drop policy if exists "public read on olympia-live" on storage.objects;
create policy "public read on olympia-live"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'olympia-live');

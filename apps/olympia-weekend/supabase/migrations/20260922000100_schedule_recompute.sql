-- Olympia Weekend — schedule the recompute-athlete-status edge function
-- to run every 5 minutes.
--
-- Uses pg_cron (postgres-side scheduler) + pg_net (async HTTP client).
-- The service key lives in Supabase's Vault so it isn't stored in
-- plaintext in cron.job.
--
-- The service key is inserted at deploy time by the pipeline (see
-- REVIEW.md — the pipeline runs `select vault.create_secret(...)`
-- once from psql/pooler with the key value out-of-band, not in this
-- migration file, so this SQL is safe to commit).

create extension if not exists pg_cron  with schema extensions;
create extension if not exists pg_net   with schema extensions;

-- Drop the prior schedule if the migration is re-applied.
select cron.unschedule('olympia-recompute-athlete-status')
  where exists (
    select 1 from cron.job where jobname = 'olympia-recompute-athlete-status'
  );

select cron.schedule(
  'olympia-recompute-athlete-status',
  '*/5 * * * *',
  $$
    select net.http_post(
      url := (
        select 'https://' || decrypted_secret || '.supabase.co/functions/v1/recompute-athlete-status'
          from vault.decrypted_secrets
         where name = 'olympia_project_ref'
      ),
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || (
          select decrypted_secret
            from vault.decrypted_secrets
           where name = 'olympia_service_role_key'
        ),
        'Content-Type', 'application/json'
      ),
      body := jsonb_build_object('source', 'pg_cron')
    );
  $$
);

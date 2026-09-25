# olympiaweekend.app — marketing site

Static HTML + hand-written CSS. No build step. No React. No Tailwind runtime.
Deploys as a folder of assets on Vercel.

## Local preview

    cd apps/olympia-weekend/marketing
    python3 -m http.server 4000
    # open http://localhost:4000

The Flutter app at `/app` won't work in local preview (it's not merged in), but
every other section will. To preview the full merged output including `/app`,
run `./deploy.sh` — the merged folder is at `apps/olympia-weekend/build/vercel-deploy/`
and you can serve that with the same `python3 -m http.server` before deploying.

## File tree

    marketing/
    ├── index.html              # landing page — 8 sections, ~500 lines of HTML
    ├── privacy.html            # copy of store/privacy.html so /privacy works
    ├── vercel.json             # rewrites + cache headers for merged deploy
    ├── deploy.sh               # build Flutter + merge + vercel deploy --prod
    ├── README.md               # you are here
    └── assets/
        ├── css/site.css        # hand-written, no framework
        ├── js/site.js          # nav-scroll + IntersectionObserver + drag scroll
        └── img/
            ├── icon.png                    # app icon (favicon, nav mark, footer mark)
            ├── silhouette-hero.svg         # bodybuilder mark, hero + CTA backdrop
            ├── screenshot-schedule.png     # phone frame — inside/Schedule card
            ├── screenshot-expo.png         # phone frame — inside/Expo card
            ├── screenshot-athletes.png     # phone frame — inside/Athletes card
            ├── screenshot-event.png        # phone frame — Venues section
            ├── screenshot-now.png          # (unused, kept for future)
            ├── screenshot-athlete-detail.png (unused, kept for future)
            ├── floor-plan.png              # LVCC South Hall
            ├── app-store-badge.svg         # Apple official black badge
            ├── google-play-badge.png       # Google official generic English badge
            └── athletes/
                ├── derek-lunsford.jpg
                ├── hadi-choopan.jpg
                ├── samson-dauda.jpg
                ├── andrew-jacked.jpg
                ├── nick-walker.jpg
                ├── brandon-curry.jpg
                ├── keone-pearson.jpg
                ├── wesley-vissers.jpg
                ├── ryan-terry.jpg
                ├── ali-bilal.jpg
                ├── brandon-hendrickson.jpg
                └── erin-banks.jpg

All athlete photos are self-hosted (downloaded from Wikimedia + Fitness Volt at
build time). No hotlinking at page-render.

## How the deploy works

Vercel wants one folder to serve. The Flutter app currently lives at
`apps/olympia-weekend/build/web/` and the marketing site lives here at
`apps/olympia-weekend/marketing/`. `deploy.sh` does three things:

1. **Builds the Flutter web app** with `--base-href /app/` so all its asset
   URLs resolve under `/app/*` instead of the root.
2. **Assembles a merged folder** at `apps/olympia-weekend/build/vercel-deploy/`
   by rsync-ing marketing → root and Flutter build → `/app/`.
3. **Runs `vercel deploy --prod --yes`** from that merged folder, reusing the
   existing `.vercel/` project link.

The resulting URL structure:

    /                    -> marketing landing page (this repo)
    /privacy.html        -> privacy policy (same as before)
    /app                 -> Flutter web app (previously at /)
    /app/*               -> Flutter routes

## Run the deploy

    cd apps/olympia-weekend/marketing
    ./deploy.sh

That's it. Verify at https://olympiaweekend.app/ once it finishes.

## Content edits

- **Athlete roster**: edit the twelve `<figure class="card-athlete">` blocks in
  `index.html`. Photos live in `assets/img/athletes/` — filename should match
  the athlete's `id` in `apps/olympia-weekend/assets/data/athletes.json`.
- **Sections**: everything is a `<section>` inside `<main>`. Reorder by moving
  the whole `<section>` element.
- **Screenshots**: replace files in `assets/img/screenshot-*.png` in place.
  They stay in the same 1206x2622 aspect ratio to fit the phone bezel.
- **Copy**: hero headline is `.hero__headline`, final CTA is `.cta__display`.
  Keep Barlow Condensed for large type only — never for paragraphs.

## Design tokens (kept in sync with the Flutter app)

    charcoal   #0E0E0E   (app OlympiaColors.dark)
    accent     #E10600   (app OlympiaColors.dark.accent)
    ivory      #EFE6D2   (icon foreground)

If the app's design tokens change, mirror them in `assets/css/site.css` under
the `:root` block.

## What's intentionally not here

- No cookie banner (the marketing site sets no cookies; analytics live inside
  the Flutter app once you land on `/app`).
- No newsletter signup form (no backend for it, and the app is free anyway).
- No testimonials, no download counts (we don't have real numbers yet).
- No Tailwind, no PostCSS, no bundler. If you want to add utilities, add them
  by hand — the site is deliberately dependency-free.

## The unofficial disclaimer

Exact wording matches the app and the App Store listing:

> Olympia Weekend is an independent app. It is not affiliated with American
> Media LLC, Olympia LLC, or the IFBB Professional League.

Lives in the footer. If Apple/Google ever ask you to move it more prominent,
promote it to a chip at the top of the footer instead of body copy.

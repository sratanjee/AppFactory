# Factory-level open items

Fleet-wide unknowns. App-level unknowns live in each `apps/<slug>/QUESTIONS.md` and are the planner's job.

## Unblock scaffolding for a real app

- [ ] Confirm bundle prefix. Current default: `com.appfactory`. If a real studio brand exists, rename in `factory.config` (`BUNDLE_PREFIX`). One line, no code changes elsewhere.
- [ ] Developer account A — fill `DEV_ACCOUNT_A_LABEL` and the four App Store Connect API fields (`_ASC_TEAM_ID`, `_ASC_ISSUER_ID`, `_ASC_KEY_ID`, and the private `.p8` key path in `factory.config.local`). Also the Google Play service account JSON path.

## RevenueCat (no project yet)

- [ ] Create the RevenueCat project. One project, one entitlement (`pro`), multiple apps under it.
- [ ] Once created, fill in `REVENUECAT_PROJECT_ID`, `REVENUECAT_API_V2_TOKEN`, `REVENUECAT_IOS_PUBLIC_KEY`, `REVENUECAT_ANDROID_PUBLIC_KEY`.
- [ ] `tools/monetize/` will call the RC API v2 to create products from spec §6. This is stubbed until the token exists.

## Store product creation

- [ ] App Store Connect API — see Developer account A above. Needed by `tools/monetize/` to create in-app subscription products from spec §6.
- [ ] Google Play Developer API — needs a service account JSON with in-app subscription permissions. Same trigger.

## Shorebird & Codemagic

- [ ] Deferred. Both stubbed in `factory.config`. Step 4 (`packages/core`) wires the Shorebird SDK but the org + token can be filled in later. Codemagic YAML lands in step 5.

## Backend / AI proxy

- [ ] Deploy target for the shared backend (Fly, Railway, Cloudflare Workers?). Undecided.
- [ ] `ANTHROPIC_API_KEY` will live in the backend host, never in the mobile apps. The apps call `BACKEND_BASE_URL` only.

## Devices for the tester

- [ ] `tools/devices.json` needs real iOS Simulator and Android emulator IDs. Currently empty and will fail the tester. Populated on first machine setup.

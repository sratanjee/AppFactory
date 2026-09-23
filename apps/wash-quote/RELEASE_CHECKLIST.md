# Wash Quote & Invoice — Release Checklist

Human-facing handoff for the first TestFlight + Play internal build.
Everything below happens on **your** side of the wall — Claude has done
the code, screenshots, ASO and Codemagic config; you wire the accounts.

**Do the steps in order.** Each block is idempotent — safe to re-run
if a value changes.

---

## 0. Pre-flight — verify the branch state

```bash
cd ~/AppFactory
git switch app/wash-quote
git status                      # should be clean or only local ignores
grep '^version:' apps/wash-quote/pubspec.yaml   # should print 1.0.0+1
ls apps/wash-quote/store/ios/en-US/screenshots/ | wc -l    # should print 5
ls apps/wash-quote/store/android/en-US/screenshots/ | wc -l # should print 5
```

If any of those don't match, stop and re-run the release-prep pipeline
(`.claude/agents/release.md`).

---

## 1. Install Flutter 3.47.4 locally (blocks CI parity)

The app's `pubspec.yaml` pins `flutter: ">=3.47.4 <3.48.0"` and Dart
`^3.13.0`. The machine currently has Flutter 3.35.2 / Dart 3.9.0.
`flutter pub get`, `flutter analyze`, and `flutter drive` all refuse
to run until this is fixed.

Options in order of preference:

```bash
# Option A — fvm (recommended, matches CLAUDE.md conventions)
brew install fvm
fvm install 3.47.4
fvm use 3.47.4 --force
# From apps/wash-quote:
fvm flutter --version           # verify 3.47.4

# Option B — direct install (if 3.47.4 isn't in fvm cache yet)
git clone --branch 3.47.4 --depth 1 https://github.com/flutter/flutter.git ~/flutter-3.47.4
export PATH="$HOME/flutter-3.47.4/bin:$PATH"
flutter --version               # verify 3.47.4
```

Once installed:

```bash
cd apps/wash-quote
fvm flutter pub get             # or `flutter pub get` for Option B
fvm flutter analyze             # must be clean
fvm flutter test                # unit + widget tests, must pass
```

---

## 2. Reshoot store screenshots on real Flutter

The five store shots currently in `store/{ios,android}/en-US/screenshots/`
were composed by `tool/store_shots/compose.py` because
`store_shots_test.dart` requires the pinned Flutter (step 1). The
compose output is store-sized and uses the correct accent + copy, but
it is not a screenshot of the real running app.

After step 1 completes, replace them with real shots:

```bash
cd apps/wash-quote

# iOS 6.9" = iPhone 17 Pro Max (App Store required)
xcrun simctl boot "iPhone 17 Pro Max"
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/store_shots_test.dart \
  -d "iPhone 17 Pro Max" \
  --dart-define=QA_DEVICE=iphone-17-pro-max

# Copy the five shots into the store dir at their exact size
for name in 01_jobs 02_quote_builder 03_job_detail 04_money 05_services; do
  clean="${name/_/-}"
  cp "qa/iphone-17-pro-max/store/${name}.png" \
     "store/ios/en-US/screenshots/${clean/_/-}.png"
done

# Android — needs Pixel 8 Pro emulator, 1080x2400 or higher.
# If `flutter emulators --launch Pixel_8_Pro_API_34` hits
# INSTALL_FAILED_INSUFFICIENT_STORAGE, blow the AVD away and recreate
# with a bigger data partition:
#   avdmanager delete avd -n Pixel_8_Pro_API_34
#   avdmanager create avd -n Pixel_8_Pro_API_34 -k 'system-images;android-34;google_apis;arm64-v8a' -d pixel_8_pro
#   # Then edit ~/.android/avd/Pixel_8_Pro_API_34.avd/config.ini:
#   #   disk.dataPartition.size=8G
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/store_shots_test.dart \
  -d emulator-5554 \
  --dart-define=QA_DEVICE=pixel-8-pro
for name in 01_jobs 02_quote_builder 03_job_detail 04_money 05_services; do
  cp "qa/pixel-8-pro/store/${name}.png" \
     "store/android/en-US/screenshots/${name//_/-}.png"
done

git add store/ && git commit -m "wash-quote: real store screenshots from Flutter 3.47.4"
```

---

## 3. Codemagic project setup

`~/AppFactory/codemagic.yaml` is aggregated at the repo root and already
contains `wash_quote_ios_testflight` + `wash_quote_android_internal`.

1. Sign in at https://codemagic.io with the GitHub account that owns
   the AppFactory repo.
2. Add application → GitHub → select `sratanjee/AppFactory` (or
   whatever the actual repo is once pushed).
3. On the app's Settings tab, confirm it detected `codemagic.yaml` at
   the repo root.
4. Both workflows will show up under **Workflows** — enable them.
5. Set the branch trigger to `app/wash-quote` and `main`. (The YAML
   already declares these; the UI just needs to know it should watch.)

---

## 4. Wire secrets to Codemagic env group `app-factory-secrets`

Team settings → **Environment variable groups** → create
`app-factory-secrets` if it doesn't exist. Add each of these; every
value marked _(secret)_ must be created as a **secret** variable
(encrypted at rest, masked in logs).

| Variable | Source | Type |
|---|---|---|
| `ASC_KEY_ID` | App Store Connect → Users and Access → Keys → your API key ID | plain |
| `ASC_ISSUER_ID` | Same page, issuer ID at top | plain |
| `ASC_KEY_P8` | Contents of the `AuthKey_XXXX.p8` file — paste the entire text including `-----BEGIN PRIVATE KEY-----` lines | secret |
| `PLAY_SERVICE_ACCOUNT_JSON` | Google Cloud → IAM → service account → JSON key → paste entire JSON | secret |
| `REVENUECAT_IOS_KEY_wash_quote` | RevenueCat → Projects → Wash Quote → API Keys → iOS App-Specific SDK Key | secret |
| `REVENUECAT_ANDROID_KEY_wash_quote` | Same page, Android App-Specific SDK Key | secret |
| `POSTHOG_KEY` | PostHog → Project settings → Project API Key | secret |

Verify with:

```bash
# In the Codemagic project UI, Environment variables tab, click "Test"
# on the group — it should show 7 defined vars, 5 of them secret.
```

If a variable name doesn't match exactly, the build fails at the
"Resolve per-slug RC key" step with `exit 2`.

---

## 5. Shorebird setup

The `pubspec.yaml` already bootstraps Shorebird in `main.dart`, but
`.shorebird/shorebird.yaml` still points at `TODO_SHOREBIRD_APP_ID`.

```bash
# Install the CLI (one-time)
curl --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh | bash
shorebird --version

# Log in — uses your Google/GitHub, opens a browser
shorebird login

# Create the Shorebird app record
cd ~/AppFactory/apps/wash-quote
shorebird apps create com.appfactory.washquote

# Copy the printed app_id into .shorebird/shorebird.yaml:
#   app_id: shorebird_00000000-0000-0000-0000-000000000000
$EDITOR .shorebird/shorebird.yaml

# Commit
git add .shorebird/shorebird.yaml
git commit -m "wash-quote: wire Shorebird app id"
```

Later, to push a code push to installed builds:

```bash
shorebird release ios --flavor prod
shorebird release android --flavor prod
# Then, for a code push (patch to an existing release):
shorebird patch ios --release-version 1.0.0+1
shorebird patch android --release-version 1.0.0+1
```

---

## 6. App Store Connect record

If `com.appfactory.washquote` isn't an app in ASC yet:

1. https://appstoreconnect.apple.com/apps → **+** → New App.
2. Platform: iOS. Name: `Wash Quote & Invoice`.
3. Primary language: English (U.S.). Bundle ID: `com.appfactory.washquote`
   (must already be registered in Apple Developer → Certificates,
   Identifiers & Profiles → Identifiers).
4. SKU: `wash-quote-2026`.
5. User Access: Full Access.

Then in ASC:
- **App Information** → set primary category to Business.
- **Pricing and Availability** → Free (auto-renewing IAP handles paid).
- **Subscriptions** → create subscription group `wash_quote_pro`. Add:
    - `wash_quote_pro_monthly` — $9.99 monthly.
    - `wash_quote_pro_annual` — $59.99 annual, 7-day intro free trial.
    - `wash_quote_pro_lifetime` — $79.99 one-time (as a non-consumable IAP,
      not part of the sub group).
- **App Privacy** → walk the questionnaire. Data collected: usage
  events (PostHog), purchase events (RevenueCat). No PII.
- **Prepare for Submission** → paste from `store/ios/en-US/*.txt` and
  upload the five PNGs from `store/ios/en-US/screenshots/`.

Verify RevenueCat sees the products at
https://app.revenuecat.com → Products.

---

## 7. Play Console record

If the app isn't in Play Console yet:

1. https://play.google.com/console → **Create app**.
2. App name: `Wash Quote & Invoice`. Language: English (United States).
3. App or game: App. Free or paid: Free (in-app subs).
4. Declarations: tick the required boxes.

Then in the console:
- **App content** → walk every card: Privacy policy, App access,
  Ads (no), Content rating, Target audience (18+), News app (no),
  Data safety.
- **Monetization → In-app products** and **Subscriptions** → mirror
  the ASC subscription group (same product IDs). Play uses base plans
  + offers; RevenueCat's Play dashboard walkthrough covers the
  translation.
- **Store listing** → paste from `store/android/en-US/*.txt`. Upload
  the five PNGs from `store/android/en-US/screenshots/`. Upload
  `store/android/feature.png` as the feature graphic and
  `store/android/icon_512.png` as the app icon.
- **Signing key** — upload the keystore (create with
  `keytool -genkeypair -v -keystore ~/.android/wash-quote.jks
   -keyalg RSA -keysize 2048 -validity 25000 -alias wash-quote`);
  store the keystore + passwords in 1Password. Codemagic reads it from
  the `CM_KEYSTORE` + `CM_KEYSTORE_PASSWORD` + `CM_KEY_ALIAS` +
  `CM_KEY_PASSWORD` env vars (see Codemagic's keystore docs; add them
  to `app-factory-secrets` when you set the keystore).

---

## 8. Trigger the first build

Once 3–7 are green:

```bash
cd ~/AppFactory
git switch app/wash-quote
git push -u origin app/wash-quote
```

The push fires both Codemagic workflows. Watch the run at
https://codemagic.io/apps → AppFactory → Builds. Expected duration:

- `wash-quote — iOS TestFlight` — ~15 min (Flutter build ipa + upload).
- `wash-quote — Play internal` — ~10 min (Flutter build appbundle + upload).

If a build fails:
- Check the `Resolve per-slug RC key` step — the most common failure is
  a misnamed env var. Vars are case-sensitive and use underscores, not
  dashes (`REVENUECAT_IOS_KEY_wash_quote`, not
  `REVENUECAT_IOS_KEY_wash-quote`).
- Check the upload step — App Store Connect will 409 if the build
  number `1.0.0+1` already exists on TestFlight; bump `pubspec.yaml`'s
  `+1` to `+2` and re-push.

---

## 9. Verify on device

- **iOS**: after ~10 min post-upload, TestFlight sends an email. Install
  from TestFlight, complete onboarding, tap the hero card, verify the
  paywall renders (needs step 4's RC keys to be live). Run through
  quote → PDF → convert to invoice → deposit link.
- **Android**: Play internal testing takes ~1 hour to propagate. Add
  yourself as a tester at Play Console → Testing → Internal testing →
  Testers → add your Google account. Install from the join link.

---

## 10. Confirm the open questions from REVIEW.md

- [ ] Shorebird `.shorebird/shorebird.yaml` `app_id` set to the id
      returned by `shorebird apps create` (§5).
- [ ] RevenueCat dashboard shows the three products (`wash_quote_pro_monthly`,
      `wash_quote_pro_annual`, `wash_quote_pro_lifetime`) tied to the
      `pro` entitlement, and the offering the paywall reads is named
      `default`.
- [ ] Terms and privacy pages at
      https://sratanjee.github.io/appfactory-site/wash-quote/{terms,privacy}
      return 200 (the ASO description and the Play `App content` card
      both link there; Play review rejects apps whose privacy URL 404s).

Only after all three are checked should you promote the TestFlight
build to external testers or start the Play production rollout.

---

## Not-in-scope for this checklist

- Store submission itself. This checklist stops at TestFlight and Play
  internal. Whoever submits to review does so from ASC's "Add for
  Review" and Play Console's "Publishing overview → Send to review".
- Widget extension targets (see REVIEW.md `Cut` — iOS Control Center
  control is deferred until `widgets_ios` extension scaffolder ships).
- iCloud Drive / Google Drive automatic backup (REVIEW.md `Cut`); the
  on-demand share-sheet export ships instead.

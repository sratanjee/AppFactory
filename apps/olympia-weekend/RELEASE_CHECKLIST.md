# Release checklist — Olympia Weekend v1.0.0+3

This runbook covers everything between "Codemagic builds green" and the app
being live in TestFlight and Play internal testing. All store submission steps
are yours to click — the pipeline stops at internal testing.

---

## Step 1: Create the App Store Connect app record

Go to https://appstoreconnect.apple.com/apps and click the + button.

| Field | Value |
|---|---|
| Platform | iOS |
| Bundle ID | com.appfactory.olympiaweekend |
| Bundle Name | Olympia Weekend |
| SKU | olympia-weekend |
| Primary Language | English (U.S.) |
| Full Name | Olympia Weekend |
| Category (Primary) | Sports |
| Category (Secondary) | (leave blank) |
| User Access | Full Access |

After creating the record, go to App Information and confirm:
- Privacy Policy URL: `https://olympia-weekend.vercel.app/privacy` (or wherever you host `store/privacy.html`)
- Subtitle: `Vegas 2026 unofficial guide` (30 chars)

Then go to the first version (1.0) and fill in:
- Description: copy from `store/ios/en-US/description.txt`
- Keywords: copy from `store/ios/en-US/keywords.txt`
- Promotional Text: copy from `store/ios/en-US/promotional_text.txt`
- Support URL: `https://olympia-weekend.vercel.app`
- App Review Notes: "This is an unofficial fan guide. No login, no paywall. Test with stub API keys — the app ships bundled JSON so all screens work without a network connection. To test the Supabase crowd confirmation: tap any athlete > tap 'I saw this'. The Mixpanel token is real but analytics are anonymous device events only."

Upload screenshots from `store/ios/en-US/screenshots/6.7-inch/` — all 6 PNGs.

---

## Step 2: Create the Google Play Console app record

Go to https://play.google.com/console and click Create app.

| Field | Value |
|---|---|
| App name | Olympia Weekend |
| Default language | English (United States) |
| App or game | App |
| Free or paid | Free |
| Declarations — Contains ads | No |
| Declarations — Primarily child-directed | No |

After creation, fill in the store listing:
- Short description: copy from `store/android/en-US/short_description.txt` (max 80 chars)
- Full description: copy from `store/android/en-US/description.txt`
- Phone screenshots: upload all 6 PNGs from `store/android/en-US/screenshots/phone/`
- App icon: use `store/ios/icon_1024.png` scaled to 512x512 (Play requires exactly 512x512 PNG)
- Feature graphic: 1024x500 PNG — create one with a dark `#0d0d0d` background + the Olympia Weekend wordmark + `#e2231a` accent dot. This is a manual step.
- Category: Sports
- Privacy policy URL: `https://olympia-weekend.vercel.app/privacy`
- Email address: sratanjee@gmail.com

Content rating: complete the questionnaire. Select "Informational" — no violence, no user-generated content concerns (crowd confirmations are anonymous booth reports, not open text).

---

## Step 3: Upload Codemagic secrets

In Codemagic > Teams > your team > Environment variables, open (or create) the
`app-factory-secrets` group and add the following vars. Mark all as "secret".

### Android keystore (upload key)

First, create the upload keystore if you do not have one:
```bash
keytool -genkey -v \
  -keystore ~/.keys/olympia-weekend-upload.jks \
  -alias olympia \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -dname "CN=Olympia Weekend, OU=AppFactory, O=AppFactory, L=Las Vegas, ST=NV, C=US"
```

Then:

| Codemagic env var | Value / source |
|---|---|
| `ANDROID_KEYSTORE_OLYMPIAWEEKEND` | `base64 -i ~/.keys/olympia-weekend-upload.jks` — paste the output |
| `ANDROID_KEYSTORE_PASSWORD_OLYMPIAWEEKEND` | The password you chose when running `keytool` above |
| `ANDROID_KEY_ALIAS_OLYMPIAWEEKEND` | `olympia` |
| `ANDROID_KEY_PASSWORD_OLYMPIAWEEKEND` | The key password (same as keystore password if you used the same) |

Important: once you publish an AAB signed with this keystore, you cannot change
it. Keep `~/.keys/olympia-weekend-upload.jks` and its password somewhere safe
(1Password, etc.).

After uploading the first AAB to Play, register the SHA-1 fingerprint of this
keystore with the Google Maps Android API key to unblock map rendering:
```bash
keytool -list -v -keystore ~/.keys/olympia-weekend-upload.jks -alias olympia \
  | grep "SHA1:"
```
Paste that fingerprint into Google Cloud Console > APIs & Services > Credentials >
your Android Maps key > Application restrictions > Add fingerprint.

### App Store Connect API key

| Codemagic env var | Value / source |
|---|---|
| `APP_STORE_CONNECT_KEY_OLYMPIAWEEKEND` | Contents of `~/.keys/AuthKey_3ARJ4A42XY.p8` — paste the raw text (including `-----BEGIN PRIVATE KEY-----` lines) |
| `APP_STORE_CONNECT_KEY_ID` | `3ARJ4A42XY` (already in factory.config) |
| `APP_STORE_CONNECT_ISSUER_ID` | `c13e39d5-5aa5-4947-8e27-77367f00ab1c` |

If you do not have `AuthKey_3ARJ4A42XY.p8` yet: App Store Connect > Users and
Access > Integrations > App Store Connect API > Generate API Key. Role: App
Manager. Download the .p8 once (you cannot re-download it).

### Play service account

| Codemagic env var | Value / source |
|---|---|
| `PLAY_SERVICE_ACCOUNT_JSON_OLYMPIAWEEKEND` | Contents of `~/.keys/play-factory.json` — paste the full JSON |

If `play-factory.json` does not exist: Google Play Console > Setup > API access >
Link to a Google Cloud project > Create a service account with "Release manager"
role > download JSON key.

---

## Step 4: Set up the GitHub remote and push

Codemagic needs to pull the code. The repo does not have a remote yet.

From the main AppFactory worktree (not this worktree):

```bash
# Option A: create a new private repo via gh CLI
gh repo create sratanjee/AppFactory --private --source=. --push

# Option B: add to an existing repo
git remote add origin git@github.com:sratanjee/AppFactory.git
git push -u origin app/olympia-weekend
git push origin olympia-weekend-v1.0.0+3
```

Branch to push: `app/olympia-weekend`
Tag to push: `olympia-weekend-v1.0.0+3`

---

## Step 5: Codemagic project setup

1. Go to https://codemagic.io and click Add application.
2. Connect to the GitHub repo `sratanjee/AppFactory` (or your org name).
3. In project settings, set:
   - Build configuration: Flutter
   - Configuration file: `apps/olympia-weekend/codemagic.yaml`
   - Branch pattern to watch: `app/*`
4. Under Environment variables, attach the `app-factory-secrets` group (created in Step 3) to the project.
5. Trigger a manual build of `ios-testflight` and `android-internal` workflows.

If you want automatic builds on push, add a webhook: Codemagic > Project > Webhooks > copy the URL, then GitHub > repo > Settings > Webhooks > Add webhook > paste URL, content type `application/json`, event "Push".

---

## Step 6: TestFlight beta info

After the `ios-testflight` Codemagic build succeeds, the IPA lands in App Store
Connect automatically. Go to TestFlight > your build:

| Field | Value |
|---|---|
| What to test | Browse the schedule (Wed–Sun day pills), save an event (bookmark icon on any event detail), tap an athlete to see their expo booth and meet-and-greet time, and confirm a sighting with "I saw this". Try the Expo tab: filter exhibitors by Supplements. Try Venues: tap any venue to get directions in Apple Maps. |
| Test information — Sign-in required | No |
| Test information — Privacy policy URL | https://olympia-weekend.vercel.app/privacy |

Enable external testing groups after at least one internal build round passes.

### Play internal testing setup

After the `android-internal` Codemagic build succeeds, the AAB lands in Play
Console automatically. Go to Testing > Internal testing:

1. Under Releases, confirm the uploaded build is on version 1.0.0 (3).
2. Under Testers, create an internal testing group (e.g., "App Factory internal") and add tester emails.
3. Share the opt-in URL with testers. Internal testing is available immediately after upload with no review.

---

## Step 7: Add testers

### TestFlight testers

Add internally under App Store Connect > TestFlight > Internal Testing > Add testers:
- sratanjee@gmail.com (the founder)

For external beta, create an External Group, add testers, and submit for Beta App Review (usually < 24h for a simple utility with no login).

### Play internal testers

Internal testing (up to 100 testers) requires no review. Add via Testing > Internal testing > Testers:
- sratanjee@gmail.com

---

## Post-checklist: things to do before the weekend

- [ ] Host `store/privacy.html` at a public URL (e.g., upload to Vercel as a static file at `/privacy`) and update the App Store Connect and Play Console privacy policy URL fields.
- [ ] Upload `assets/data/athletes.json` to the `olympia-live` Supabase bucket as `athletes.seed.json` so the edge function can start computing live athlete status.
- [ ] Register the Android upload keystore SHA-1 with the Google Maps Android API key (see Step 3 above).
- [ ] Set `WEB_DEPLOY_DOMAIN_olympiaweekend` in `factory.config` once the custom domain is decided.
- [ ] If using Shorebird for code push: run `shorebird apps create` and paste the app ID into `.shorebird/shorebird.yaml` (currently holds `TODO_SHOREBIRD_APP_ID`).

---

## Version reference

App: `olympia-weekend`
Version: `1.0.0+3`
Bundle ID: `com.appfactory.olympiaweekend`
Branch: `app/olympia-weekend`
Tag: `olympia-weekend-v1.0.0+3`
Reviewer sign-off: Pass. Ship this. (2026-09-22)

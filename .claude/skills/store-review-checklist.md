---
name: store-review-checklist
description: Pre-submission checklist for App Store Review Guidelines and Google Play policies. Use before the release step, and use during the reviewer step to catch common rejections.
---

# store-review-checklist

Ship-blockers only. Every item here has been a real rejection, either at Apple or Google. If any line fails, do not submit.

## Metadata

- [ ] App name (iOS) ≤ 30 chars; subtitle ≤ 30 chars.
- [ ] App name (Android) ≤ 30 chars; short description ≤ 80 chars.
- [ ] Description does not use "best", "top", "#1", competitor names, or references to other platforms ("also on Android").
- [ ] Keywords (iOS) are comma-separated, no spaces after commas, no repeat with the name, ≤ 100 chars total.
- [ ] Screenshots show the actual current UI. No "coming soon" overlays. No device frames added by the store — supply plain screenshots and let the store frame them.
- [ ] Age rating filled and consistent with content.
- [ ] Support URL, privacy URL, and marketing URL all resolve and match the app's brand.
- [ ] Encryption compliance answered (usually "no non-exempt encryption").

## Privacy

- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) present on iOS with every API-required-reason set.
- [ ] Play Data Safety form filled; declared data collection matches what the app actually collects.
- [ ] No SDK collects data that isn't declared. RevenueCat, analytics, and any AI proxy calls are declared.
- [ ] AppTrackingTransparency prompt appears only if the app actually tracks across other apps (usually: no; do not add ATT if not needed — Apple flags empty ATT usage).

## Permissions

- [ ] Every permission has an in-context explanation screen **before** the system prompt. One line explaining why.
- [ ] `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSMicrophoneUsageDescription`, `NSUserTrackingUsageDescription`, `NSHealthShareUsageDescription`, `NSCalendarsUsageDescription`, `NSContactsUsageDescription` — each populated with a real, specific sentence. Not generic "we need access to X".
- [ ] Android permissions declared in the manifest are minimal; no `READ_CONTACTS` unless actually used.
- [ ] Background location is not requested unless the app has a visible use for it.

## Subscription flow

- [ ] Paywall shows: price, period, free trial length (if any), and what auto-renews.
- [ ] "Restore purchases" is present and one tap from the paywall.
- [ ] Terms of Service and Privacy Policy links are present on the paywall.
- [ ] No hidden dismiss: on iOS, close control is reachable within 2 seconds. On Android, the system back gesture always closes the paywall.
- [ ] Prices display exactly what RevenueCat / StoreKit / Play Billing return — no client-side "$X.XX / year" strings.
- [ ] Free trial mention includes the length and mentions auto-renewal after trial ends.
- [ ] No dark patterns: no strikethrough fake prices, no "only $X" wording, no fake countdown.

## Functionality

- [ ] The app's core action from spec §2 works with no account and no network on first launch (unless spec §4 says a backend is required).
- [ ] The app opens and completes onboarding on airplane mode (unless the paywall requires network — that's fine).
- [ ] No demo, sample, test, or hidden dev screen ships in the production build.
- [ ] No web view that is essentially a wrapper of a website.
- [ ] Push notifications: token requested only after value shown; every notification path has an in-app control to disable.

## Content

- [ ] No user-generated content flow without a report/block button.
- [ ] No AI-generated content flow without a clear "content produced by AI" label and a report path.
- [ ] No text that looks like a review prompt written by the developer ("Loving the app? Leave 5 stars!").
- [ ] Icons don't include the word "App" or duplicate the app name.

## Native surfaces

- [ ] Widgets render real data on install (not stubs), work in StandBy and on the tinted home screen (iOS 26), and show a sensible state before data exists.
- [ ] Live Activities have a compact and expanded Dynamic Island design — no default fall-through.
- [ ] Glance widgets support at least two sizes and dynamic color.

## Build hygiene

- [ ] No log output from release builds that contains user data or keys.
- [ ] No debug menus, no `assert` messages surfacing to the UI.
- [ ] `flutter analyze` clean; `flutter test` and `integration_test` both green on both platforms.
- [ ] Bundle version and build number bumped since last submission.

## Placeholder sweep

Every one of these strings is a rejection or a factory pre-commit block. Check all shipped strings, ARB files, plist entries, manifest labels, store metadata:

- No `TODO`
- No `FIXME`
- No `lorem`
- No `John Doe`
- No the-string-literally-spelled-e-x-a-m-p-l-e-dot-com
- No the-word-p-l-a-c-e-h-o-l-d-e-r

## Human handoff

The pipeline stops at TestFlight and Play internal testing. The founder submits from there. This checklist is the last thing they read before pressing Submit.

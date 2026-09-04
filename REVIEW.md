# MY Vapp (lim_crm) — App Review

**Date:** September 2026  
**Version reviewed:** 1.0.0+3  
**Package:** `com.myVapp.app`  
**Stack:** Flutter · Provider · http · SharedPreferences

## Verdict

Solid loyalty-CRM feature surface and clear folder structure, but **auth/session/logging need hardening** before production trust. Tests and localization catalogs lag far behind the UI.

| Severity | Count |
|----------|------:|
| Critical | 2 |
| High     | 4 |
| Medium   | 4 |

---

## Top findings

### 1. Critical — Tokens & OTP logged

**Where:** `lib/data/network/network_api_service.dart`, `lib/view_models/auth_view_model/auth_view_model.dart`

Bearer tokens, login response bodies, and OTP payloads are printed via `debugPrint`. Risk of leakage via logcat, shared devices, and crash reporters.

**Fix:** Remove secret logging; redact remaining logs; gate with `kDebugMode` only.

---

### 2. Critical — Password reset unbound from OTP

**Where:** `lib/screens/auth_screens/reset_password_screen/reset_password_screen.dart`

Reset sends only `email` + `password` — no OTP or reset token. If the API mirrors this, anyone who knows an email could set a new password.

**Fix:** Require a server-issued reset token (or re-verify OTP) on reset; confirm backend binding.

---

### 3. High — Auth token in SharedPreferences

**Where:** `lib/data/network/network_api_service.dart`

Bearer token and PII are stored in plain SharedPreferences, not Keychain/Keystore.

**Fix:** Move the token to `flutter_secure_storage`; stop persisting OTP / Stripe-related fields.

---

### 4. High — OTP persisted in user JSON

**Where:** `lib/models/login_model/login_model.dart`, `lib/view_models/auth_view_model/auth_view_model.dart`

`User` includes `otp` / `otp_expires_at`, and `saveUserData` writes them to prefs.

**Fix:** Strip verification and payment-sensitive fields from client persistence.

---

### 5. High — No 401 → logout path

**Where:** `lib/data/network/network_api_service.dart`, `lib/view_models/auth_view_model/auth_view_model.dart`

Unauthorized throws but never clears the session. Splash treats any non-empty token as logged in.

**Fix:** Central interceptor: on 401 clear session and route to login; validate profile on splash.

---

### 6. High — Incomplete logout

**Where:** `lib/view_models/auth_view_model/auth_view_model.dart`

Clears token/user only when API `status == 1`; leaves `userId` / `email` / `phone`. Failed logout keeps the session.

**Fix:** Always clear local session keys, then navigate — even if the logout API fails.

---

### 7. Medium — Localization catalogs thin

**Where:** `assets/lang/*.json`

~50 keys per locale vs ~293 unique `translate()` calls. OTP UI hard-coded English; French falls back heavily.

**Fix:** Expand EN/FR catalogs; localize auth strings; add a missing-key CI check.

---

### 8. Medium — Broken boilerplate test only

**Where:** `test/widget_test.dart`

Default counter test against `MyApp` — will fail and covers none of the CRM logic.

**Fix:** Smoke + unit tests for `JsonCast`, vape engine, and session clear.

---

### 9. Medium — Controller leak & VM navigation

**Where:** `lib/screens/auth_screens/verify_otp_screen/verify_otp_screen.dart`, `lib/view_models/auth_view_model/auth_view_model.dart`

OTP controllers never disposed. ViewModels own `Navigator` and miss `context.mounted` after awaits.

**Fix:** Dispose controllers; move navigation to UI/router; check `mounted` after async work.

---

### 10. Medium — Config & branding drift

**Where:** `pubspec.yaml`, iOS `Info.plist`, `AdModel`

Unpinned deps; `flutter_icons` YAML clutter; iOS display name still “Lim Crm”; unsafe ad JSON casts; unrestricted WebView JS.

**Fix:** Pin versions; rename iOS display name; use `JsonCast` for ads; restrict WebView / URL schemes.

---

## Architecture scorecard

| Aspect | Current | Grade |
|--------|---------|-------|
| Layering | screens → view_models → repository → NetworkApiService | Good |
| State | Provider ChangeNotifiers (6 VMs) | OK |
| Endpoints | Centralized `AppUrl` + `API_BASE_URL` dart-define | Good |
| DI | `new NetworkApiService()` / repos inside VMs | Weak |
| Navigation | Imperative routes inside ViewModels | Weak |
| API status | Ad-hoc `status == "1"`; `ApiResponse` unused | Weak |
| Parsing | `JsonCast` on newer models (dashboard) | Good |

---

## Feature map

| Area | Coverage |
|------|----------|
| Auth | Login, OTP reset, profile, settings, logout |
| Home / loyalty | Dashboard, cashback, redeem, charts |
| Promotions | Coupons, offers, birthday popup |
| Orders | Order history |
| Vape calculator | Savings calc, slips, history |
| Content | Newsletters, ads carousel |
| i18n | EN / FR plumbing (catalog incomplete) |

---

## Security snapshot

| Area | Status | Notes |
|------|--------|-------|
| Transport | OK | HTTPS default (`myvapp.app`). No cleartext flag. ATS defaults OK. No cert pinning. |
| Secrets | Risk | Token + OTP in prefs/logs. Password reset not bound to OTP on the client. |
| Session | Gap | No global 401 handler. Splash trusts any token string. Logout incomplete on API failure. |

---

## Quality & product gaps

### Code quality

- `getRequest` has no timeout; `postJsonRequest` ignores HTTP status
- Large widgets (e.g. `savings_animation.dart` ~967 lines)
- `IndexedStack` keeps five tabs alive
- Dead `ApiResponse` scaffolding
- Desktop package leftovers (`com.example`)

### UX / product

- Little `Semantics` usage
- Mixed empty/error states
- Android “My Vapp” vs iOS “Lim Crm”
- Imperative navigation only

### Localization debt

| Metric | Value |
|--------|------:|
| EN/FR catalog keys | ~50 |
| Unique `translate()` calls | ~293 |

Roughly 1 in 6 strings has a catalog entry — French mode still shows mostly English fallbacks.

---

## What works well

- Coherent product surface: auth, dashboard, coupons/offers/birthday, cashback, orders, vape savings, newsletters, ads
- HTTPS + `API_BASE_URL` dart-define for environments
- Shared UI (`PortalUi`, `AppTheme`), remember-me, pull-to-refresh, chart empty states, birthday popup
- Newer domain models with defensive `JsonCast` parsing
- Production-style Android applicationId (`com.myVapp.app`)

---

## Recommended order of work

1. Stop logging secrets  
2. Bind password reset to OTP/token  
3. Secure token storage  
4. 401 interceptor + always-clear logout  
5. Strip OTP from persisted `User`  
6. Replace `widget_test` + add engine unit tests  
7. Expand locale catalogs  
8. Align iOS display name / pin deps  

---

*Source: static review of `lib/`, `android/`, `ios/`, `test/`, `pubspec.yaml` · September 2026*

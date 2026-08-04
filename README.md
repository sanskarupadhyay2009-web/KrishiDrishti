# KrishiDrishti – AI Powered Smart Farming Assistant

A Flutter MVP that helps small and marginal farmers understand their soil
and crops with simple, actionable advice — no lab visit or agricultural
expert required to get started.

This build implements **Phases 1–4** of the project roadmap end-to-end
(app, simulated sensor pipeline, rule-based recommendation engine) plus a
lightweight, fully offline piece of Phase 5 (a text chat assistant), so the
whole thing runs and is deployable **with zero backend, zero API keys, and
zero internet connection required**.

## What's in this MVP

| Screen | What it does |
|---|---|
| Splash | Loads saved language + scan history |
| Language | Choose English or Hindi (saved, editable later in Settings) |
| Home | Device status, Start Scan, Ask the Assistant, last scan summary |
| Scan | Simulates the ESP32 soil analyzer reading moisture / pH / temperature |
| Result | Health status + plain-language recommendations, auto-saved to history |
| History | Every past scan, with a moisture trend chart |
| Chat Assistant | Offline keyword-based Q&A on irrigation, pests, fertilizer, pH, crops |
| Settings | Switch language, About |

### Why the sensor readings are simulated

There's no paired ESP32 device to test against yet, so `ScanPage` generates
plausible sensor values instead of reading Bluetooth. Everything downstream
— the recommendation engine, the result screen, and scan history — already
works off a single `SoilScan` object (see `lib/models/soil_scan.dart`), so
wiring up real Bluetooth later (Phase 3 hardware/BLE) only means replacing
the body of `ScanPage._runScan()`. No other file needs to change.

### Why the chat assistant is offline

Phase 5 of the roadmap calls for a real AI backend eventually. For this
MVP, `lib/services/chat_assistant.dart` uses simple keyword matching
instead — so the app is fully usable in low-connectivity rural areas from
day one, and swapping in a real AI API later is a one-file change.

## Project structure

```
lib/
  main.dart                     App entry, theme, Provider setup
  splash_page.dart
  language_page.dart
  home_page.dart
  scan_page.dart
  result_page.dart
  history_page.dart
  chat_page.dart
  settings_page.dart
  models/soil_scan.dart         Data model + JSON (de)serialization
  providers/app_provider.dart   App-wide state (language, device, history)
  services/
    recommendation_engine.dart  Rule-based soil advice (Phase 4)
    chat_assistant.dart         Offline keyword-based Q&A
  utils/app_strings.dart        All English/Hindi text in one place
  widgets/primary_button.dart   Shared button style
```

## Running it

```bash
flutter pub get
flutter run
```

## Building a release APK

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`,
ready to install on an Android device or distribute to testers.

## Roadmap: what's next

- **Phase 3 (hardware):** replace the simulator in `ScanPage._runScan()`
  with real `flutter_blue_plus` reads from the ESP32.
- **NPK / EC sensors:** extend `SoilScan` and `RecommendationEngine` with
  the new fields — both are designed to make this a small, additive change.
- **Image-based crop diagnosis:** add a new screen using the device camera
  and an image-classification API.
- **Voice assistant:** add speech-to-text ahead of the existing
  `ChatAssistant`, so the same offline reply logic can be reused, then
  later swap in a text-to-speech response.
- **Real AI chat:** replace `ChatAssistant.reply()` with a call to a
  hosted LLM once connectivity and a backend are available; the chat UI
  itself does not need to change.
- **Weather integration:** fetch a forecast and factor it into
  `RecommendationEngine` (e.g. postpone irrigation if rain is expected).
  

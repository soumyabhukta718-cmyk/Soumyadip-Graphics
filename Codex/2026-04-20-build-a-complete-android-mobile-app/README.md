# Shindhu - AI Study Companion

Shindhu is an offline-first Flutter study app for SSC and competitive exam preparation. It includes a hybrid AI tutor, routine planner, reminders, goal tracking, Pomodoro sessions, notes, analytics, motivation, streaks, and a future-ready group study surface.

## Run

```bash
flutter pub get
flutter run
```

## Optional AI API Setup

Shindhu works offline by default. To enable online AI:

1. Open the app.
2. Go to `Reports` -> `Tutor & Sync Settings`.
3. Add your API endpoint URL and API key.
4. Turn on `Online tutor`.

The online tutor sends a generic JSON payload so you can connect any compatible backend. The service reads common response fields such as `reply`, `answer`, `content`, `output_text`, or `choices[0].message.content`.

## Firebase Sync

Cloud sync is optional and intentionally stubbed by default so the project stays lightweight and runnable without Firebase setup.

To add Firebase later:

1. Add Firebase packages to `pubspec.yaml`.
2. Place `google-services.json` inside `android/app/`.
3. Replace the placeholder implementation in `lib/services/sync_service.dart`.

## Alarm Sound

Android alarms use `android/app/src/main/res/raw/alarm_tone.wav`. Replace that file with your own sound if needed.

## Identity Memory

The tutor always remembers:

- App Name: Shindhu
- Developer: Soumyadip Bhukta
- Designer: Soumyadip Bhukta
- Logo Creator: Debashrita Goswami

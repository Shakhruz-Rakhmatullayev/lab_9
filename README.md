# HabitFlow

HabitFlow is a Flutter app for tracking habits and fitness. It has a glass-style interface, light and dark themes, and five screens in a floating bottom navigation bar.

## Features

- **Home**: a greeting, a search bar, today's stats (steps, calories burnt and more) with progress indicators, quick-toggle chips for today's habits, and a featured workout card.
- **Habits**: a scrollable date strip, a summary card with a progress ring, and the habit list. You can mark habits done, which updates their streaks, add new habits with a custom icon, color and time of day, or remove them.
- **Statistics**: recent workout charts for calories and duration, plus a habit-consistency heatmap.
- **Catalog**: a wellness-gear catalog you can switch between a list feed and a 2-column grid. Pull down to load a new item at the top, swipe left to delete an item (with Undo), and restore the starter items when the catalog is empty.
- **Profile**: personal metrics (age, height, weight) and an editable profile. Settings cover reminder time, sound, notifications, appearance (system, light or dark), experience level, caution areas and units.
- **Saved settings**: the theme, sound, notification, experience, reminder and caution-area settings are stored with `shared_preferences`, so they stay the same between launches.

## Tech stack

- Flutter (Dart SDK `^3.13.2`)
- State management with `ChangeNotifier` and an `InheritedNotifier` scope (`AppScope`)
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) for storage
- Custom painters for the progress rings, pill bar charts and wave graphics

## Project structure

```
lib/
├── main.dart                # App entry point, theme setup
├── data/sample_data.dart    # Demo stats, workout and catalog data
├── state/app_state.dart     # Habit model and AppState (ChangeNotifier)
├── screens/
│   ├── shell.dart           # App shell + floating nav bar
│   ├── home_screen.dart
│   ├── habits_screen.dart
│   ├── statistic_screen.dart
│   ├── catalog_screen.dart
│   └── profile_screen.dart
├── theme/app_theme.dart     # Colors, text styles, light/dark themes
├── utils/format.dart        # Formatting helpers
└── widgets/
    ├── charts.dart          # ProgressRing, PillBarChart, WavePainter
    ├── glass.dart           # Glass cards, buttons, background, headers
    └── sheet.dart           # Bottom sheets
```

## Getting started

Prerequisites: the [Flutter SDK](https://docs.flutter.dev/get-started/install), plus Xcode for iOS/macOS or Android Studio for Android.

```bash
git clone https://github.com/Shakhruz-Rakhmatullayev/lab_8.git
cd lab_8
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Platforms

iOS, Android, macOS and Web.

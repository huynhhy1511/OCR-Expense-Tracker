# OCR Expense Tracker

## Project Overview
OCR Expense Tracker is a complete offline-first Android Flutter application for scanning receipts, extracting merchants, amounts, and dates using Google ML Kit on-device text recognition, and saving expenses into a local SQLite database.

## Features
- **Dashboard**: View total spending, recent expenses, pie charts, and bar charts.
- **Camera Scanner**: Built-in camera with flash toggle and tap-to-focus for capturing receipts.
- **Crop**: Crop the receipt to maximize OCR accuracy.
- **OCR Processing**: Fully offline on-device text recognition.
- **Receipt Parsing**: Regex and heuristics for finding merchants, total amounts, and dates.
- **Review**: Manual adjustment of detected fields before saving.
- **History & Details**: View all past expenses and their original receipt thumbnails.
- **Custom Charts**: Uses `CustomPainter` for rendering Donut and Bar charts with animations (no 3rd-party libraries).

## Tech Stack
- Flutter, Dart
- `google_mlkit_text_recognition` for OCR
- `sqflite` & `path_provider` for persistence
- `provider` for state management

## Getting Started
```bash
flutter pub get
flutter run
```

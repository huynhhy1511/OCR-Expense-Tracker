# Technical Report: OCR Expense Tracker

## 1. Introduction
Physical receipts often require manual data entry, which is tedious and prone to errors. This project, **OCR Expense Tracker & Receipt Parser**, aims to solve this by providing an offline-first, Flutter-based Android application that scans physical receipts, extracts key information using on-device Machine Learning, and allows users to manage their expenses with interactive data visualizations.

## 2. Objectives
- **OCR**: Implement on-device text recognition using Google ML Kit.
- **Parsing**: Automatically extract merchant names, total amounts, and transaction dates via heuristics and regular expressions.
- **Local Storage**: Save parsed data in an SQLite database and store cropped receipt images locally.
- **Visualization**: Build custom animated Donut and Weekly Bar charts using `CustomPainter` without relying on third-party charting libraries.

## 3. Technologies
- **Flutter & Dart**: For building the cross-platform UI and business logic.
- **Google ML Kit**: For fast, offline, on-device OCR.
- **SQLite**: For persistent, structured local data storage.
- **CustomPainter**: For rendering custom, animated charts.
- **Provider**: For clean, scalable state management.

## 4. System Architecture
The application follows a clean architecture pattern with clear separation of concerns:
1. **UI Layer (Screens & Widgets)**: Handles user interaction and rendering.
2. **State Management (Providers)**: Connects UI to Repositories.
3. **Services**: Contains core business logic (OCR processing, Text Parsing, File Storage, Camera).
4. **Repositories**: Abstracts data access.
5. **Data Layer (DAOs & SQLite)**: Manages persistence.

## 5. OCR Pipeline
1. **Camera**: User frames the receipt and captures an image.
2. **Crop**: User refines the boundaries of the receipt to remove background noise.
3. **ML Kit**: Extracts raw text blocks from the cropped image completely offline.
4. **Raw Text**: Passed to the internal Receipt Parser.
5. **Parser**: Identifies specific fields (Merchant, Date, Amount).
6. **Review**: User validates or corrects the data before it is saved.
7. **Save**: The validated expense and image thumbnail are persisted locally.

## 6. Parsing Strategy
The parser uses a combination of techniques to ensure accuracy across various receipt formats:
- **Normalization**: Removing special characters, standardizing date formats, and cleaning currency symbols (VND/đ).
- **Keyword Matching**: Looking for terms like "Tổng", "Total", "Amount" to locate the final price.
- **Regex**: Matching date patterns (DD/MM/YYYY, DD-MM-YYYY).
- **Heuristics**: Assuming the first valid non-metadata string at the top of the receipt is the merchant name, and picking the largest monetary value near a "Total" keyword as the amount.

## 7. Database
The app uses an SQLite table named `expenses`:
```sql
CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    merchant TEXT NOT NULL,
    amount INTEGER NOT NULL,
    transaction_date TEXT NOT NULL,
    category TEXT NOT NULL,
    receipt_image_path TEXT,
    ocr_text TEXT,
    created_at TEXT NOT NULL
);
```

## 8. Visualization
- **Donut Chart**: Uses `CustomPainter` to draw arcs based on category percentages. It includes an entrance animation using `AnimationController`.
- **Weekly Bar Chart**: Uses `CustomPainter` to draw rounded rectangles representing daily spending over the last 7 days. It animates from the baseline upon rendering.

## 9. Testing / Results
Unit tests verify the parsing accuracy. For example, testing `ReceiptParser` with:
```
VINMART
05/10/2026
Milk 30.000
TONG CONG 150.000 đ
```
Properly yields: Amount: 150000, Merchant: VINMART, Date: 2026-10-05.

## 10. Limitations
- **Image Quality**: OCR accuracy is heavily dependent on the lighting and focus of the captured image.
- **Heuristic Parsing**: While effective for many common layouts, highly non-standard receipts may require manual correction.

## 11. Conclusion
The OCR Expense Tracker successfully demonstrates a robust, privacy-first (offline) approach to expense management, leveraging powerful on-device ML and efficient custom rendering in Flutter.

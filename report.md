# MINI-PROJECT SHORT TECHNICAL REPORT
**Course:** Cross-Platform Mobile App Development (VKU)  
**Mini-Project Title:** OCR Expense Tracker  
**Team / Student Name:** Huỳnh Ngọc Huy  
**Submission Date:** 07/10/2026

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members:**
  1. Huỳnh Ngọc Huy — Student ID: 23IT.EB043 — Role: Developer — Contribution: 100%
* **🔗 Live Demo URL:** [Local APK build available]
* **💻 GitHub Repository:** https://github.com/huynhhy1511/OCR-Expense-Tracker.git
* **🎥 Video Demo (Optional):** None

---

## 2. FEATURE IMPLEMENTATION CHECKLIST
| # | Required Feature | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| 1 | Database Persistence | ✅ Complete | Uses SQLite (sqflite) for local offline persistence of expenses. |
| 2 | OCR Scanning | ✅ Complete | Uses Google ML Kit on-device Text Recognition (offline) to scan receipts. |
| 3 | Automatic Parsing | ✅ Complete | Uses Regex and Heuristics to parse Merchant, Total Amount, and Date. |
| 4 | Custom Charts | ✅ Complete | Uses CustomPainter to render Donut and Bar charts natively without third-party libraries. |
| 5 | Expense Review | ✅ Complete | Manual adjustment of detected fields and category selection before saving. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE
* **Directory Structure**: Layered architecture with `models/`, `database/`, `repositories/`, `services/`, `providers/`, `screens/`, and `widgets/`.
* **State Management**: Uses `Provider` pattern for reactive state updates across the app.
* **Exception Handling**: Implements `try-catch` blocks in OCR processing, parsing, and SQLite operations. Fallbacks like `DateTime.now()` are used when data extraction fails. Custom R8 Proguard rules ensure Google ML Kit doesn't crash on release builds.

---

## 4. EMPIRICAL EVIDENCE & SCREENSHOTS
*(Vui lòng tự chèn 3-4 ảnh chụp màn hình app (Dashboard, Camera, Processing, History) của bạn tại đây trước khi nộp)*

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS
* **Challenge 1: Google ML Kit R8 Obfuscation Bug:** On release build, R8 stripped essential optional language classes in ML Kit, causing a `NullPointerException` during image processing. 
  * **Resolution:** Created a custom `proguard-rules.pro` file with `-keep` and `-dontwarn` rules for `com.google.mlkit.**` to preserve the classes and applied it to the release build configuration.
* **Challenge 2: Inaccurate OCR Data Formatting:** Receipts often use various formats like `3.976.000` or `11.02.16` instead of standardized text, leading to parse errors.
  * **Resolution:** Developed a robust parsing heuristic using Regex. Added sanitization logic (`replaceAll(RegExp(r'[^\d]'), '')`) to clean up currencies, and added intelligent fallbacks for parsing non-standard dates.
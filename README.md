# TargetJournal 🇨🇳 ✍️

A modern, native iOS app engineered in **SwiftUI**, **SwiftData**, and **Swift 6** designed specifically for journaling in your target language (**Simplified Chinese** / HSK 1–9) with AI-powered language evaluation via **DeepSeek API**.

---

## ✨ Features

- 🇨🇳 **Simplified Chinese & HSK Calibration**: Configure proficiency levels from **HSK 1 (Beginner)** through **HSK 9 (Mastery)**.
- 📝 **Hybrid Markdown & WYSIWYG Editor**:
  - Live preview with CJK line-height formatting.
  - One-tap Chinese punctuation accessory bar (`，`, `。`, `！`, `？`, `“”`, `《》`, `「」`, `——`).
  - Standard Markdown quick-insert bar (headings, bold, lists, quotes, checkboxes).
- 🤖 **AI Language Critique (DeepSeek)**:
  - Supports `deepseek-chat` (fast) and `deepseek-reasoner` (deep chain-of-thought analysis).
  - Fluency and grammar scoring calibrated to the user's selected HSK level.
  - Detailed grammar corrections with categorized badges and explanations.
  - Level-up vocabulary recommendations with Pinyin, English translations, and example sentences.
  - Side-by-side original vs. polished native version comparison with one-tap clipboard copy.
- 🔒 **Local & Secure**:
  - DeepSeek API key stored securely in **Apple Keychain**.
  - All journal entries persisted on-device using **SwiftData**.
- 🧩 **Pluggable LLM Architecture**:
  - Conforms to the `LLMService` protocol to easily drop in additional models (Claude, OpenAI, Gemini, Local LLMs) in the future.

---

## 📱 Screenshots

<div align="center">

| Home Timeline | Markdown & WYSIWYG Editor | AI Tutor Analysis |
| :---: | :---: | :---: |
| <img src="docs/screenshots/home-screen.png" width="280" alt="Home Screen" /> | <img src="docs/screenshots/note-edit-screen.png" width="280" alt="Note Edit Screen" /> | <img src="docs/screenshots/feedback.png" width="280" alt="AI Feedback" /> |

</div>

---

## 🚀 Getting Started

### 1. Open the Project in Xcode
Open `TargetJournal.xcodeproj` in Xcode (or regenerate using `xcodegen generate`):
```bash
open TargetJournal.xcodeproj
```

### 2. Configure DeepSeek API Key
1. Run the app in the Simulator or on your device.
2. Complete the initial onboarding flow (select Simplified Chinese, choose your HSK level, and enter your DeepSeek API key starting with `sk-...`).
3. You can also modify or test your API key anytime in **Settings (`⚙️`)**.

### 3. Run Tests
Run the test suite using Swift PM or Xcode:
```bash
swift test
```

---

## 🛠️ Requirements
- **iOS 18+** / **iOS 26+** (designed for modern iPhone displays including iPhone 17 Pro Max)
- **Xcode 16+ / 26+**
- **Swift 6**

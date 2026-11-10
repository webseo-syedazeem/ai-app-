# AI Daily Helper — Full-Stack Flutter + Vercel + MongoDB + Gemini App

> **You talk. It remembers. It reminds. It helps you get your day done.**

## 1. Architecture & Database Choice

1. **Mobile App (`mobile/`) — Flutter + Local SQLite (`sqflite`) + Motion System**
   - Pixel-faithful implementation of **all 22 screens** from the design package (`01_Splash` through `22_Empty_States`), custom vector brand mark & 1.8px rounded stroke icons.
   - **Full Professional Motion Choreography (`lib/core/widgets/app_animations.dart`):** Staggered fade-slide card entrances, tactile spring press scaling (`BouncyTap`), animated screen/tab transitions (`AnimatedSwitcher`), sweeping progress rings & rising chart bars, animated checkboxes, floating welcome cards, and pulsing live voice waveforms.
   - **Offline-first Local Persistence:** Uses SQLite (`sqflite`) on Android/iOS with a `SharedPreferences` JSON snapshot bridge (also works cleanly on Flutter Web).

2. **Cloud Database — MongoDB Atlas (`mongodb/schema_and_indexes.js` & `backend/src/db/`)**
   - Uses official `mongodb` Node.js driver across **15 collections** (`users`, `tasks`, `reminders`, `shopping_items`, `memories`, `keep_for_later`, `conversations`, `conversation_messages`, `brain_dump_drafts`, `goals`, `affirmations`, `usage_logs`, `budgets`, `expenses`, `email_report_preferences`) with cached client reuse for serverless cold starts.

3. **Serverless Backend API (`backend/`) — Node.js + TypeScript + Vercel + Gemini API**
   - **Vercel Ready (`backend/vercel.json` & `backend/api/index.ts`):** Deploy directly with `vercel` and set `MONGODB_URI`, `MONGODB_DB_NAME`, and `GEMINI_API_KEY`.
   - **Intent Router (`src/ai/intentRouter.ts`):** Routes simple commands to **Gemini 2.5 Flash-Lite** and Brain Dumps / complex planning / `"What am I forgetting?"` to **Gemini 2.5 Flash**.
   - **Zero-config Local Dev Mode:** Runs immediately with `.data/dev-store.json` and local NLU fallback until you add your MongoDB & Gemini credentials.

---

## 2. Quick Start

### A. MongoDB Setup
1. Create a free MongoDB Atlas cluster at https://www.mongodb.com/atlas (or run local MongoDB).
2. Optional: initialize collections/indexes via `mongosh "<MONGODB_URI>" mongodb/schema_and_indexes.js` (the backend also creates indexes automatically on first connection).

### B. Vercel + Backend Setup (`backend/`)
```bash
cd backend
cp .env.example .env
# Set GEMINI_API_KEY, MONGODB_URI, MONGODB_DB_NAME=ai_daily_helper
npm install
npm run dev
```
Deploy to Vercel:
```bash
cd backend
vercel --prod
```
Run backend tests:
```bash
npm test
```

### C. Flutter App (`mobile/`)
```bash
cd mobile
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=https://your-app.vercel.app/api
```
*(You can also set/change your Vercel API URL directly inside the app under **Settings -> Account details**.)*


# OmAstro: Vendor Portal Astrologer Registration Guide

> **Audience**: Backend & Full-Stack Developers building the Vendor / Admin Web Portal.  
> **Purpose**: Guide to registering astrologers via a simple form (Email + Password) so they can log into the OmAstro mobile app and complete their profile during in-app onboarding.

---

## 1. Architecture Overview

OmAstro utilizes a **dual-auth architecture**:
- **Firebase Auth**: Used for primary client/astrologer mobile login, real-time consultation notifications, and Zego audio/video signaling (`firebase_uid`).
- **Supabase (PostgreSQL)**: Serves as the primary operational database (`auth.users`, `public.profiles`, `public.astrologers`).

```mermaid
flowchart TD
    subgraph VendorPortal["Vendor Web Portal"]
        Form["Vendor Form\n(Email + Password + Optional Name)"]
    end

    subgraph BackendAPI["Backend API / Server Function"]
        CreateFirebase["1. Create Firebase Auth User\n(email, password) -> firebase_uid"]
        CreateSupabase["2. Create Supabase Auth User\n(admin.createUser) -> supabase_uuid"]
        CreateProfile["3. Insert public.profiles\n(id = supabase_uuid, email)"]
        CreateAstrologer["4. Insert public.astrologers\n(id = supabase_uuid, email,\nbio = '', rates = 0)"]
    end

    subgraph MobileApp["OmAstro Mobile App"]
        Login["Astrologer Login Screen\n('I\\'m an Astrologer')"]
        AuthCheck{"Check Astrologer Record\nbio.isEmpty && rates <= 0 ?"}
        Onboarding["/astrologer-onboarding\n(Astrologer sets Bio, Experience,\nLanguages, Skills, Rates)"]
        Dashboard["/astrologer-home\n(Active Astrologer Dashboard)"]
    end

    Form -->|POST credentials| BackendAPI
    CreateFirebase --> CreateSupabase --> CreateProfile --> CreateAstrologer
    CreateAstrologer -.->|Credentials shared with Astrologer| Login
    Login --> AuthCheck
    AuthCheck -- Yes (Fresh Account) --> Onboarding
    Onboarding -->|Submits Profile| Dashboard
    AuthCheck -- No (Already Set) --> Dashboard
```

---

## 2. The "Zero-State" Onboarding Mechanism

You **do not** need to collect phone numbers, bio, rates, languages, or profile images on the vendor web form.

The OmAstro mobile app (`AuthBloc` and `GoRouter`) has a built-in detection check:
```dart
// lib/features/auth/bloc/auth_bloc.dart
if (bio.isEmpty && chatRate <= 0 && callRate <= 0 && videoRate <= 0) {
  emit(AstrologerOnboardingRequired(...));
}
```

When an account is created with **`bio = ''`** and **`chat_rate = 0, call_rate = 0, video_rate = 0`**:
1. The mobile app signs in the astrologer.
2. It detects the empty zero-state.
3. The app router intercepts the session and locks them on **`/astrologer-onboarding`**.
4. The astrologer is required to fill in their own:
   - Full Name
   - Bio / Description
   - Years of Experience
   - Languages Spoken (Hindi, English, etc.)
   - Specialization Skills (Vedic, Tarot, Numerology, etc.)
   - Consultation Categories (Love, Career, Marriage, etc.)
   - Per-minute Consultation Rates (Chat, Audio Call, Video Call)
5. Once they hit **"Complete Onboarding"**, the app saves their details, synchronizes their presence to Firestore, and unlocks their dashboard (`/astrologer-home`).

---

## 3. Database Schema & Tables

### A. `auth.users` (Supabase Auth)
Generated automatically by Supabase Auth Admin API.
- Generates a UUID `id`.

### B. `public.profiles`
Foreign key requirement: `astrologers.id` references `profiles.id`. A profile record **must** exist first.

| Column | Type | Nullable | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | No | - | Foreign Key to `auth.users(id)` |
| `email` | `TEXT` | No | - | Astrologer's email |
| `full_name` | `TEXT` | Yes | `''` | Astrologer's name |
| `avatar_url` | `TEXT` | Yes | `null` | Photo URL |
| `created_at` | `TIMESTAMPTZ` | No | `now()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | No | `now()` | Update timestamp |

### C. `public.astrologers`
Holds the operational data for consultations and listings.

| Column | Type | Required for Initial Seed | Notes / Behavior |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | **Yes** | Primary key. Must equal `profiles.id` |
| `email` | `TEXT` | **Yes** | Astrologer's email address |
| `firebase_uid` | `TEXT` | **Yes** (or empty) | Firebase user UID (used for calls & presence) |
| `name` | `TEXT` | **Yes** | Display name (or email prefix) |
| `bio` | `TEXT` | **Yes: set to `''`** | **Must be empty string** to trigger onboarding |
| `experience_years`| `INT` | `0` | Default 0 |
| `languages` | `TEXT[]` | `'{}'` | Empty array: `[]` |
| `skills` | `TEXT[]` | `'{}'` | Empty array: `[]` |
| `categories` | `TEXT[]` | `'{}'` | Empty array: `[]` |
| `chat_rate` | `NUMERIC` | `0` | **Must be 0** to trigger onboarding |
| `call_rate` | `NUMERIC` | `0` | **Must be 0** to trigger onboarding |
| `video_rate` | `NUMERIC` | `0` | **Must be 0** to trigger onboarding |
| `price_per_minute`| `NUMERIC` | `0` | Legacy fallback (matches `call_rate`) |
| `rating` | `NUMERIC` | `5.0` | Default rating |
| `reviews_count` | `INT` | `0` | Initial review count |
| `total_minutes_consulted` | `INT` | `0` | Initial consulted minutes |
| `is_online` | `BOOLEAN` | `false` | Astrologer is offline initially |

> [!NOTE]
> Row Level Security (RLS) on `public.astrologers` and `public.profiles` has been disabled in migration `008_disable_rls_astrologers.sql` to allow profile updates directly from the mobile app once authenticated.

---

## 4. Backend Implementation (Node.js / TypeScript / Next.js)

### Dependencies
```bash
npm install firebase-admin @supabase/supabase-js
```

### Environment Variables
```env
SUPABASE_URL=https://ptuzewebbzvxlibtrvth.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_secret_key
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_CLIENT_EMAIL=your_firebase_service_account_email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
```

### Complete API Handler
```typescript
import { NextRequest, NextResponse } from 'next/server';
import admin from 'firebase-admin';
import { createClient } from '@supabase/supabase-js';

// 1. Initialize Firebase Admin SDK (Singleton)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

// 2. Initialize Supabase Admin Client with Service Role Key
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { auth: { autoRefreshToken: false, persistSession: false } }
);

export async function POST(req: NextRequest) {
  try {
    const { email, password, name } = await req.json();

    if (!email || !password) {
      return NextResponse.json(
        { error: 'Email and password are required.' },
        { status: 400 }
      );
    }

    if (password.length < 6) {
      return NextResponse.json(
        { error: 'Password must be at least 6 characters long.' },
        { status: 400 }
      );
    }

    const displayName = name?.trim() || email.split('@')[0];

    // Step 1: Create user in Firebase Auth
    const firebaseUser = await admin.auth().createUser({
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName,
    });

    // Step 2: Create user in Supabase Auth (admin API bypasses rate limits & auto-confirms email)
    const { data: supaUser, error: supaAuthError } = await supabaseAdmin.auth.admin.createUser({
      email: email.trim().toLowerCase(),
      password: password,
      email_confirm: true,
      user_metadata: {
        full_name: displayName,
        role: 'astrologer',
      },
    });

    if (supaAuthError) {
      // Rollback Firebase user if Supabase Auth creation fails
      await admin.auth().deleteUser(firebaseUser.uid);
      return NextResponse.json({ error: supaAuthError.message }, { status: 400 });
    }

    const userId = supaUser.user.id;

    // Step 3: Insert into public.profiles
    const { error: profileError } = await supabaseAdmin.from('profiles').upsert({
      id: userId,
      email: email.trim().toLowerCase(),
      full_name: displayName,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });

    if (profileError) {
      throw new Error(`Profile creation failed: ${profileError.message}`);
    }

    // Step 4: Insert seed record in public.astrologers
    // Empty bio and 0 rates intentionally trigger in-app onboarding!
    const { error: astroError } = await supabaseAdmin.from('astrologers').insert({
      id: userId,
      email: email.trim().toLowerCase(),
      firebase_uid: firebaseUser.uid,
      name: displayName,
      bio: '',
      experience_years: 0,
      languages: [],
      skills: [],
      categories: [],
      chat_rate: 0,
      call_rate: 0,
      video_rate: 0,
      price_per_minute: 0,
      rating: 5.0,
      reviews_count: 0,
      total_minutes_consulted: 0,
      is_online: false,
    });

    if (astroError) {
      throw new Error(`Astrologer table insert failed: ${astroError.message}`);
    }

    return NextResponse.json(
      {
        success: true,
        message: 'Astrologer successfully registered!',
        data: {
          astrologerId: userId,
          firebaseUid: firebaseUser.uid,
          email: email.trim().toLowerCase(),
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error('[VendorRegister] Error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    );
  }
}
```

---

## 5. Python / FastAPI Implementation (Alternative)

If your vendor backend is built with Python:

```python
import os
import firebase_admin
from firebase_admin import credentials, auth as fb_auth
from supabase import create_client, Client
from pydantic import BaseModel, EmailStr
from fastapi import FastAPI, HTTPException

app = FastAPI()

# 1. Firebase Admin init
cred = credentials.Certificate("path/to/firebase-service-account.json")
firebase_admin.initialize_app(cred)

# 2. Supabase Admin client
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_ROLE_KEY")
)

class AstrologerRegisterRequest(BaseModel):
    email: EmailStr
    password: str
    name: str = ""

@app.post("/api/vendor/astrologers/register")
def register_astrologer(payload: AstrologerRegisterRequest):
    email = payload.email.lower()
    display_name = payload.name.strip() or email.split("@")[0]

    # Step 1: Firebase Auth
    try:
        fb_user = fb_auth.create_user(
            email=email,
            password=payload.password,
            display_name=display_name
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Firebase user creation failed: {str(e)}")

    # Step 2: Supabase Auth
    try:
        supa_user_res = supabase.auth.admin.create_user({
            "email": email,
            "password": payload.password,
            "email_confirm": True,
            "user_metadata": {"full_name": display_name, "role": "astrologer"}
        })
        user_id = supa_user_res.user.id
    except Exception as e:
        fb_auth.delete_user(fb_user.uid)  # Rollback
        raise HTTPException(status_code=400, detail=f"Supabase auth failed: {str(e)}")

    # Step 3: Insert into public.profiles
    supabase.table("profiles").upsert({
        "id": user_id,
        "email": email,
        "full_name": display_name,
    }).execute()

    # Step 4: Insert into public.astrologers (rates=0, bio='' triggers onboarding)
    supabase.table("astrologers").insert({
        "id": user_id,
        "email": email,
        "firebase_uid": fb_user.uid,
        "name": display_name,
        "bio": "",
        "experience_years": 0,
        "languages": [],
        "skills": [],
        "categories": [],
        "chat_rate": 0,
        "call_rate": 0,
        "video_rate": 0,
        "price_per_minute": 0,
        "rating": 5.0,
        "reviews_count": 0,
        "is_online": False,
    }).execute()

    return {
        "success": True,
        "astrologer_id": user_id,
        "firebase_uid": fb_user.uid,
        "email": email
    }
```

---

## 6. Testing & Handover Checklist

### Testing the Registration API
1. Send a POST request to your endpoint with:
   ```json
   {
     "email": "astrologer.test@omastro.com",
     "password": "Password123!",
     "name": "Acharya Raman"
   }
   ```
2. Verify the response returns HTTP `201` with `astrologerId` and `firebaseUid`.
3. Check Supabase Dashboard:
   - `auth.users` has the user with `email_confirmed_at` populated.
   - `public.profiles` has a row matching the `id`.
   - `public.astrologers` has a row with `bio = ''` and `chat_rate = 0`.

### Testing on the OmAstro Mobile App
1. Open the OmAstro app on an Android/iOS device or emulator.
2. On the Sign In screen, toggle to **"I'm an Astrologer"**.
3. Enter `astrologer.test@omastro.com` and `Password123!`.
4. Tap **"Sign In as Astrologer"**.
5. **Expected result**:
   - The app signs in successfully.
   - The app router automatically redirects to **`/astrologer-onboarding`**.
   - The onboarding form is displayed asking for bio, skills, categories, languages, and pricing.
   - Upon submitting the form, the astrologer lands on the **Astrologer Dashboard** (`/astrologer-home`).

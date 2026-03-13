# LM Merchant Portal

**Payment Processing Marketplace for Lucrative Merchants**

A web app where merchants create profiles, get matched to payment processors, upload documents, e-sign applications, and track onboarding status in real-time.

## 🚀 Tech Stack

- **Frontend**: React + Vite
- **Routing**: React Router v6
- **Styling**: Tailwind CSS (LM brand colors: Gold #C59F00, Green #396422, Gray #4B4646)
- **Backend/Auth/DB**: Supabase (PostgreSQL + Auth + Storage)
- **E-Signature**: SignWell API
- **Hosting**: Netlify → `app.lucrativemerchants.com`
- **Mobile**: PWA (installable from browser)

## 📁 Project Structure

```
lm-merchant-portal/
├── src/
│   ├── components/
│   │   ├── Layout.jsx           # Main layout with header/nav/footer
│   │   └── ProtectedRoute.jsx   # Route guard for authenticated users
│   ├── pages/
│   │   ├── Landing.jsx          # Public landing page
│   │   ├── Login.jsx            # Sign in page
│   │   ├── SignUp.jsx           # Sign up page
│   │   ├── Dashboard.jsx        # Merchant dashboard (protected)
│   │   ├── Profile.jsx          # Business profile form (protected)
│   │   ├── Matches.jsx          # Processor match results (protected)
│   │   ├── Documents.jsx        # Document upload (protected)
│   │   ├── Applications.jsx     # Application tracking (protected)
│   │   └── Status.jsx           # Status timeline (protected)
│   ├── lib/
│   │   ├── supabase.js          # Supabase client + helpers
│   │   └── matchingEngine.js    # Processor matching logic
│   ├── App.jsx                  # Main app component with routing
│   └── index.css                # Tailwind base + custom styles
├── supabase/
│   └── migrations/
│       └── 20260313_initial_schema.sql  # Complete database schema
├── .env.example                 # Environment variables template
└── README.md                    # This file
```

## 🗄️ Database Schema

**5 Core Tables:**
1. `merchants` - Business profiles and matching data
2. `processors` - Payment processor partners
3. `merchant_applications` - Applications per processor
4. `merchant_documents` - Uploaded documents
5. `status_history` - Audit trail of status changes

**Supporting Table:**
- `high_risk_industries` - Configurable high-risk industry list

## 🧠 Matching Engine

Rule-based scoring system (0-100) that evaluates:
1. **Industry Support** (REQUIRED) - Must be in processor's supported industries
2. **Monthly Volume Range** (REQUIRED) - Must fall within min/max
3. **Card Present/CNP** (REQUIRED) - Must support merchant's transaction type
4. **High-Risk Flag** (REQUIRED) - Processor must accept if merchant is high-risk
5. **Business Age** (REQUIRED) - Processor must accept new businesses if < 3 months

All logic is in `src/lib/matchingEngine.js`.

## 📋 Application Status Flow

1. `profile_complete` → Profile finished
2. `matched` → Processor matched
3. `docs_uploaded` → All required docs uploaded
4. `app_sent` → SignWell document sent
5. `app_signed` → Merchant signed
6. `submitted` → LM admin submitted to processor
7. `approved` or `declined`

## 📄 Document Upload Routing

**Standard Merchant (3+ months in business):**
- 3 most recent processing statements
- Voided check
- Government-issued photo ID
- Business license (if applicable)

**New Business (< 3 months) - Auto-Detected:**
- 3 most recent **bank statements** (NOT processing statements)
- Voided check
- Government-issued photo ID
- Business license/formation docs

Logic automatically switches based on `months_in_business` field.

## 🔐 Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Supabase
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# SignWell (backend only - set in Netlify)
SIGNWELL_API_KEY=your_signwell_api_key
SIGNWELL_WEBHOOK_SECRET=your_signwell_webhook_secret

# Email (backend only - set in Netlify)
RESEND_API_KEY=your_resend_api_key

# Admin
LM_ADMIN_EMAIL=kingsley@lucrativemerchants.com
```

## 🚧 Getting Started

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Supabase

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Create `.env` file with your Supabase credentials
4. Run the migration:
   ```bash
   # In Supabase SQL Editor, run:
   # supabase/migrations/20260313_initial_schema.sql
   ```

### 3. Create Storage Buckets

In Supabase Storage, create these buckets:
- `merchant-documents` (private) - For uploaded merchant docs
- `applications` (private) - For generated/signed application PDFs

### 4. Run Development Server

```bash
npm run dev
```

App will be available at `http://localhost:5173`

### 5. Build for Production

```bash
npm run build
```

Deploy the `dist/` folder to Netlify.

## 🎨 Brand Colors

```css
--lm-gold: #C59F00
--lm-green: #396422
--lm-gray: #4B4646
```

## 📦 Phase 1 MVP Checklist

**✅ Completed:**
- [x] React + Vite project setup
- [x] Tailwind CSS configured
- [x] Supabase client setup
- [x] React Router configured
- [x] Database schema (SQL migration)
- [x] Matching engine logic
- [x] Landing page
- [x] Login/SignUp pages
- [x] Protected route guard
- [x] Layout component
- [x] Page placeholders (Dashboard, Profile, Matches, Documents, Applications, Status)

**🚧 In Progress:**
- [ ] Business Profile form (multi-step)
- [ ] Processor matching UI
- [ ] Document upload UI + Supabase Storage integration
- [ ] SignWell e-signature integration
- [ ] Status timeline component
- [ ] LM Admin panel
- [ ] Email notifications
- [ ] PWA configuration (manifest.json, service worker)

**📅 Next Steps:**
1. Complete Business Profile form
2. Build Processor Matches UI
3. Implement Document Upload
4. Integrate SignWell API
5. Build Admin Panel
6. Set up Netlify deployment

## 🔗 Links

- **Marketing Site**: [lucrativemerchants.com](https://lucrativemerchants.com)
- **Portal**: app.lucrativemerchants.com (after deployment)
- **Supabase**: [app.supabase.com](https://app.supabase.com)
- **SignWell**: [signwell.com](https://signwell.com)

## 📞 Contact

**Lucrative Merchants**  
Bothell, WA  
kingsley@lucrativemerchants.com  
Office: 425-780-4405  
Direct: 206-719-6821

---

**Build Brief v1.0** — Confidential

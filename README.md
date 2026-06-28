# Honey Layne 🐝🌸

A romantic boutique storefront built with **React + Vite + Tailwind CSS**. It has
two faces:

| Page | Link (custom domain) | Link (GitHub Pages) | Who it's for |
| --- | --- | --- | --- |
| **Storefront** | `https://honeylayne.shop/` | `https://aheiner2001.github.io/honeylayne/` | Customers |
| **Manager Studio** | `https://honeylayne.shop/manage` | `https://aheiner2001.github.io/honeylayne/manage` | Your sister |

It's one site with a `/manage` route — only one thing to deploy, but two clean
links to share. The app uses path-style URLs (no `#`), which works as long as
the host rewrites unknown paths back to the app (configured below).

---

## What the manager can do

Open `/manage`, log in with the access code, then:

- **Turn top-bar menu links on/off** (Dresses, Tops, Bottoms, Accessories,
  About, Contact). *Home* and *Shop All* always stay on.
- **Show/hide whole page sections** (hero, favorites, about story, etc.).
- **Edit the words + photos** on the home, about, contact, and footer.
- **Add / edit / remove products** — pick a photo, type a price, choose a
  category, and paste an Instagram link. Each product card on the storefront
  opens that Instagram link when tapped.
- **Upload header art** (top-left, top-right, shop icon) as transparent PNGs.
- **Change the access code** from inside the studio.

### Manager access code

The starting code is `honeybee`. Change it anytime from the **Access code** card
in the studio — it's stored with the rest of your site settings. For a small
shop this simple gate is plenty; when Firebase is connected, unlocking the
studio also signs the browser in anonymously so it's allowed to save changes.

---

## Run it locally

```bash
npm install
npm run dev
```

- Storefront: the page that opens (default `http://localhost:5173`).
- Manager: add `/manage` to the URL.

Useful scripts:

| Command | What it does |
| --- | --- |
| `npm run dev` | Start the Vite dev server with hot reload. |
| `npm run build` | Type-check-free production build into `dist/`. |
| `npm run preview` | Serve the built `dist/` locally to sanity-check a release. |
| `npm run typecheck` | Run `tsc --noEmit` to catch type errors. |

By default the app stores products + settings **in your browser only**
(`localStorage`, no setup required). To make changes show up for everyone and
store photos in the cloud, connect Firebase below.

---

## Environment variables

Copy `.env.example` to `.env` and fill in real values. Vite only exposes
variables prefixed with `VITE_` to the bundle.

```bash
cp .env.example .env
```

| Variable | Purpose |
| --- | --- |
| `VITE_FIREBASE_*` | Firebase web config. When `VITE_FIREBASE_API_KEY` is present the app uses Firestore + Storage; otherwise it falls back to `localStorage`. |
| `VITE_MANAGER_PASSWORD` | Optional starting access code (the code is also editable in-app and persisted with settings). |

`.env` is gitignored. In CI these come from GitHub repo Secrets (see
`.github/workflows/deploy.yml`).

---

## Deploy

### Option A — Firebase Hosting (custom domain + clean `/manage`)

Firebase Hosting rewrites every path back to the app (so `/manage` loads
directly and on refresh) and connects a custom domain in a few clicks. It also
lives in the same Firebase project as your photos.

```bash
# one time
npm install -g firebase-tools
firebase login
firebase use --add          # pick your Firebase project (updates .firebaserc)

# each release
npm run build
firebase deploy --only hosting
```

`firebase.json` already serves the Vite output and has the SPA rewrite:

```json
"hosting": {
  "public": "dist",
  "rewrites": [{ "source": "**", "destination": "/index.html" }]
}
```

**Connect the domain:** Firebase console → **Hosting → Add custom domain** →
enter `honeylayne.shop`, add the DNS records it shows you at your registrar.
SSL is automatic.

### Option B — GitHub Pages

The workflow at `.github/workflows/deploy.yml` builds with Node + Vite and
publishes on every push to `main`. One-time setup:

1. Push this repo to GitHub.
2. **Settings → Pages → Build and deployment → Source = GitHub Actions**.
3. Add your `FIREBASE_*` / `MANAGER_PASSWORD` values under
   **Settings → Secrets and variables → Actions**.
4. Push to `main` (or run the workflow manually).

The workflow copies `dist/index.html` to `dist/404.html` so the clean `/manage`
path also works on Pages. The site is served at the apex domain, so
`base` in `vite.config.ts` is `"/"`. If you drop the custom domain and use
`aheiner2001.github.io/honeylayne/` instead, set `base` to `"/honeylayne/"`.

---

## Connect Firebase (data + photos in the cloud)

Right now everything can run from the browser's `localStorage`. To share edits
across devices and store uploaded photos in the cloud, connect Firebase.

1. **Create the project** at <https://console.firebase.google.com> and enable
   **Firestore Database**, **Storage**, and **Authentication → Anonymous**.
2. **Add a Web app** (Project settings → Your apps) and copy its config into
   `.env` as the `VITE_FIREBASE_*` values above.
3. **Deploy the security rules** in this repo:

```bash
firebase deploy --only firestore:rules,storage
```

   `firestore.rules` and `storage.rules` allow public read and writes only by a
   signed-in manager (`if request.auth != null`). Unlocking the studio signs the
   browser in anonymously so saves are allowed.

4. **(If photo uploads are CORS-blocked)** apply `cors.json` to the Storage
   bucket:

```bash
gsutil cors set cors.json gs://<your-bucket>
```

### What gets stored where
- `products/{id}` documents in **Firestore** — name, price, category, links.
- `site/settings` document — menu/section toggles + all editable copy/images.
- product photos in **Storage** (`products/…`), header art in `header/…`.

---

## Project layout

```
index.html                 Vite entry HTML
vite.config.ts             Vite config (base, build outDir = dist)
tailwind.config.js         brand colors + fonts
postcss.config.js          Tailwind + autoprefixer
src/
  main.tsx                 app bootstrap (Router + store provider)
  App.tsx                  routes (/, /shop, /about, /contact, /manage)
  index.css                Tailwind layers + brand type helpers
  types.ts                 data models + SiteSettings + (de)serialization
  seed.ts                  starter products
  store/HoneyStore.tsx     app state, backend wiring, manager auth
  data/
    firebase.ts            Firebase init (reads VITE_FIREBASE_* env)
    backend.ts             storage interface + LocalBackend + FirebaseBackend
  lib/util.ts              small helpers (image src resolve, open link, cx)
  components/              header, footer, product card/image, icons
    manager/ui.tsx         studio UI primitives (fields, switches, toasts)
  pages/                   home, shop, about, contact, manager
public/
  assets/images/           florals, bees, hero + product photos
  icons/                   PWA icons
  manifest.json, favicon.png, CNAME
tool/make_transparent.py   helper to knock white backgrounds out of PNG art
```

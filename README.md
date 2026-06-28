# Honey Layne 🐝🌸

A romantic boutique storefront built with **Flutter Web**. It has two faces:

| Page | Link (custom domain) | Link (GitHub Pages) | Who it's for |
| --- | --- | --- | --- |
| **Storefront** | `https://honeylayne.com/` | `https://aheiner2001.github.io/honeylayne/` | Customers |
| **Manager Studio** | `https://honeylayne.com/manage` | `https://aheiner2001.github.io/honeylayne/manage` | Your sister |

It's one site with a `/manage` route — only one thing to deploy, but two clean
links to share. The app uses path-style URLs (no `#`), which works as long as
the host rewrites unknown paths back to the app (configured below).

---

## What the manager can do

Log in with the manager password, then:

- **Turn top-bar menu links on/off** (Dresses, Tops, Bottoms, Accessories,
  About, Contact). *Home* and *Shop All* always stay on.
- **Edit the homepage words** — the big hero headline and welcome text.
- **Add / edit / remove products** — pick a photo from the phone, type a price,
  choose a category, and paste an Instagram link. Each product card on the
  storefront opens that Instagram link when tapped.

### Manager password

The password lives in `lib/data/store.dart`:

```dart
const kManagerPassword = 'honeybee';
```

Change it to whatever you want to give your sister, then rebuild/redeploy.
(For a small shop this simple gate is plenty. If you want a "real" login later,
Firebase Auth can be added.)

---

## Run it locally

```bash
flutter pub get
flutter run -d chrome
```

- Storefront: the page that opens.
- Manager: add `#/manager` to the URL.

By default the app stores products + settings **in your browser only**
(no setup required). To make changes show up for everyone and store photos in
the cloud, set up Firebase below.

---

## Custom domain with a clean `/manage` URL (recommended: Firebase Hosting)

To get `honeylayne.com` and `honeylayne.com/manage`, use **Firebase Hosting**.
It rewrites every path back to the app (so `/manage` loads directly and on
refresh) and connects a custom domain in a few clicks. It also lives in the same
Firebase project as your photos, so everything is in one place.

```bash
# one time
npm install -g firebase-tools
firebase login
firebase use --add          # pick your Firebase project (updates .firebaserc)

# each release
flutter build web --release --no-tree-shake-icons   # base-href defaults to "/"
firebase deploy --only hosting
```

`firebase.json` in this repo already has the SPA rewrite:

```json
"rewrites": [{ "source": "**", "destination": "/index.html" }]
```

### Connect the domain
1. Buy `honeylayne.com` (Namecheap, Google Domains, Cloudflare, etc.).
2. Firebase console → **Hosting → Add custom domain** → enter `honeylayne.com`.
3. Add the DNS records Firebase shows you at your registrar. SSL is automatic.
4. Done: storefront at `honeylayne.com`, manager at `honeylayne.com/manage`.

## Deploy (GitHub Pages — also works)

A workflow at `.github/workflows/deploy.yml` builds and publishes on every push
to `main`. One-time setup:

1. Push this repo to GitHub.
2. In the repo: **Settings → Pages → Build and deployment → Source = GitHub Actions**.
3. Push to `main` (or run the workflow manually). Both links go live.

The workflow copies `index.html` to `404.html` so the clean `/manage` path also
works here. You can point `honeylayne.com` at GitHub Pages too
(**Settings → Pages → Custom domain**); if you do, change the workflow's
`--base-href "/honeylayne/"` to `--base-href "/"`.

> If you rename the repo, update `--base-href "/<repo-name>/"` in the workflow.

---

## Optional: store data & photos in Firebase

Right now everything is saved in the browser. To share edits across devices and
store uploaded photos in the cloud, connect Firebase. **You only need to do this
when you're ready — the site works without it.**

### 1. Create the Firebase project
- Go to <https://console.firebase.google.com> → **Add project** (name it e.g. `honey-layne`).
- In the project, enable:
  - **Firestore Database** (Start in *production* or *test* mode).
  - **Storage**.

### 2. Connect it to this app
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Pick your Firebase project and **Web** as the platform. This overwrites
`lib/firebase_options.dart` with your real keys (these web keys are safe to commit).

### 3. Turn it on
In `lib/data/firebase_config.dart`:
```dart
const bool kUseFirebase = true;
```

### 4. Security rules (so only the site can read, edits stay controlled)
In the Firebase console, set Firestore + Storage rules. A simple starting point
(public read, writes allowed — fine for a tiny shop where only your sister has
the manager password):

```
// Firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /{document=**} { allow read: if true; allow write: if true; }
  }
}
```
```
// Storage
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} { allow read: if true; allow write: if true; }
  }
}
```

> Want it locked down properly later? Add **Firebase Auth** and change `write`
> rules to `if request.auth != null`. Ask and this can be wired up.

### What gets stored where
- `products/{id}` documents in **Firestore** — name, price, category, Instagram link.
- `site/settings` document — menu toggles + homepage words.
- `products/{id}.jpg` in **Storage** — the uploaded photos.

---

## Project layout

```
lib/
  main.dart                 app entry + routing (/ and /manager)
  theme/honey_theme.dart    colors + fonts
  models/                   Product, SiteSettings
  data/
    store.dart              app state + manager password
    backend.dart            storage interface + LocalBackend
    firebase_backend.dart   Firestore + Storage backend
    firebase_config.dart    kUseFirebase flag
    seed.dart               starter products
  widgets/                  header, footer, product card, image helper
  pages/                    home_page (storefront), manager_page (studio)
assets/images/              florals, bees, hero + product photos
```

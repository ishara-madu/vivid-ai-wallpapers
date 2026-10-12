# Vivid Studio • Wallpaper & Cutout Publisher

A modern web dashboard to manually curate, preview, and publish ultra-high-definition wallpapers with tailored camera notch and punch-hole cutouts directly into the Vivid Notch AI repository and mobile app.

---

## 🌟 Key Features

1. **Direct GitHub REST API Integration**:
   - Commits original master wallpapers (`wallpapers/categories/...`).
   - Generates and uploads compressed mobile WebP thumbnails (`wallpapers/thumbnails/...`).
   - Automatically updates and commits `wallpapers/metadata/catalog.json` on the `main` branch.
   - Completely client-side: Zero backend or server required.

2. **Live Smartphone Notch Cutout Inspector**:
   - Real-time interactive mobile phone mockup preview.
   - Switchable camera cutouts: **Center Hole**, **Dynamic Island**, **Left Hole**, and **Full Screen**.
   - Inspect alignment of cutouts before publishing to users.

3. **In-Browser Processing**:
   - Automatic dominant & accent color extraction for smooth gradient loading fallbacks in the Flutter app.
   - Real-time WebP thumbnail compression (360 × 640) directly in the browser via Canvas API.
   - Dimension and resolution detection (4K Ultra HD, QHD+, Full HD+).

4. **Live Catalog Manager**:
   - Browse all currently published wallpapers directly from the repository.
   - Filter by category or search by title.
   - Delete/prune wallpapers directly with one click.

---

## 🚀 How to Run Locally

Simply open `admin/index.html` in any web browser:

```bash
# On macOS
open admin/index.html
```

Or serve with any static web server:

```bash
npx serve admin
```

---

## 🌐 Hosted on GitHub Pages (`gh-pages`)

This studio is published on the `gh-pages` branch and accessible online at:
**`https://ishara-madu.github.io/vivid-ai-wallpapers/`**

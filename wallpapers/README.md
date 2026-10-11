# Vivid AI Wallpapers Storage & Generator Structure

This directory contains the image storage hierarchy, categorization structure, and metadata for Vivid AI Wallpapers.

---

## 📁 Directory Structure

```
wallpapers/
├── categories/                   # Full-resolution wallpaper files
│   ├── amoled/                   # True-black OLED (9:16 high contrast)
│   ├── vibrant_flows/            # Liquid gradients & fluid dynamics
│   ├── abstract/                 # Refractive glass & geometric origami
│   ├── landscapes/               # Scenic mountain vistas & serene horizons
│   ├── minimal/                  # Subtle brutalism & serene negative space
│   └── 3d/                       # Ray-traced floating chrome & crystal shapes
│
├── thumbnails/                   # Optimized WebP previews (fast app loading)
│
└── metadata/
    ├── catalog.json              # Main JSON database consumed by the mobile app
    └── categories.json           # Categories index and metadata
```

---

## 🤖 GitHub Worker (Automated Image Generation)

The automated worker runs via GitHub Actions located at `.github/workflows/generate_wallpapers.yml`.

### Schedule
- **Runs twice every day**: Automatically at `00:00 UTC` and `12:00 UTC` (every 12 hours).
- **Manual Trigger**: Can also be triggered anytime on demand from the GitHub **Actions** tab (`Run workflow`).

### How to Configure API Key

1. Go to your GitHub repository in your browser.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Name: `AI_IMAGE_API_KEY` (or `OPENAI_API_KEY`).
5. Value: *Paste your AI Image Generation API key here (e.g. OpenAI DALL-E 3 key)*.
6. Click **Add secret**.

> **Note**: If the secret is not yet set, the worker gracefully generates test procedural artwork without failing the build pipeline!

---

## 🧪 Local Testing

You can run the script manually on your machine at any time:

```bash
# 1. Install dependencies
pip install -r scripts/requirements.txt

# 2. Run generator (uses test mode or pass your key)
AI_IMAGE_API_KEY="your_api_key_here" python scripts/generate_wallpapers.py --count 2 --category random
```

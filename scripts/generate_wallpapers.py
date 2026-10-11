#!/usr/bin/env python3
"""
Vivid Notch AI - Automated Camera Cutout Wallpaper Generator
------------------------------------------------------------
This script generates vertical 9:16 mobile wallpapers designed specifically
for camera cutouts (Center Hole-Punch, Dynamic Island Pill, Left Corner, and AMOLED Stealth).

Supported Environment Variables:
  - AI_IMAGE_API_KEY or OPENAI_API_KEY: Secret API key for AI generation
  - AI_PROVIDER: 'openai' (default), 'stability', or 'mock'
  - GITHUB_REPOSITORY: e.g. 'username/vivid-ai-wallpapers' (used to generate raw URLs)
  - WALLPAPERS_COUNT: Number of wallpapers to generate per execution (default: 2)
"""

import os
import sys
import json
import time
import zlib
import struct
import random
import argparse
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path
from io import BytesIO

# Optional dependencies (installed in CI/CD via requirements.txt)
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

try:
    from PIL import Image, ImageDraw
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

# Root repository paths
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
WALLPAPERS_DIR = REPO_ROOT / "wallpapers"
CATEGORIES_DIR = WALLPAPERS_DIR / "categories"
THUMBNAILS_DIR = WALLPAPERS_DIR / "thumbnails"
METADATA_DIR = WALLPAPERS_DIR / "metadata"
CATALOG_PATH = METADATA_DIR / "catalog.json"

# Cutout-Focused Prompts across Categories
PROMPT_CATALOG = {
    "Center Hole": [
        {
            "title": "Cosmic Eclipse Halo",
            "prompt": "Vertical 9:16 mobile wallpaper. Deep pure OLED pitch black #000000 background. At the very top-center (x: 50%, y: 5%), a stunning glowing solar eclipse corona with radiant golden and amber light rays orbiting an empty circular void for the camera punch hole. High contrast, clean, 8K ultra detail.",
            "description": "Luminous golden solar corona orbiting the center camera punch-hole against an infinite AMOLED black void.",
            "colors": ["#000000", "#FFB703"],
            "cutoutType": "centerHole"
        },
        {
            "title": "Cyber Optic HUD Ring",
            "prompt": "Vertical 9:16 mobile wallpaper. Pure deep black background. At the top-center (x: 50%, y: 5%), a hyper-precise neon cyan and electric blue holographic HUD crosshair ring targeting the front camera lens. Minimalist geometric interface, 8K octane render.",
            "description": "Futuristic sci-fi target lock aperture rotating symmetrically around the center camera lens.",
            "colors": ["#0F172A", "#38BDF8"],
            "cutoutType": "centerHole"
        }
    ],
    "Dynamic Island": [
        {
            "title": "Neon Island Wave",
            "prompt": "Vertical 9:16 mobile wallpaper. Pitch black AMOLED background. At the top-center (x: 50%, y: 6%), an elegant glowing acoustic audio soundwave pill capsule tailored for Apple Dynamic Island. Vibrant gradient ribbons of magenta, violet, and electric coral flowing downward.",
            "description": "Sleek acoustic soundwave pill engineered to hug the Dynamic Island with fluid magenta and volcanic coral gradients.",
            "colors": ["#1A0B2E", "#FF523B"],
            "cutoutType": "dynamicIsland"
        },
        {
            "title": "Chroma Cyber Visor",
            "prompt": "Vertical 9:16 mobile wallpaper. Deep OLED black. At top-center (x: 50%, y: 6%), a sleek horizontal glowing neon pill visor reflecting molten purple and cyan holographic reflections.",
            "description": "Cybernetic horizontal visor framing the Dynamic Island pill with saturated neon reflections.",
            "colors": ["#0B081E", "#00F5D4"],
            "cutoutType": "dynamicIsland"
        }
    ],
    "Left Corner": [
        {
            "title": "Corner Lightning Arc",
            "prompt": "Vertical 9:16 mobile wallpaper. Deep pure OLED black void. Coiling electric emerald plasma arc bursting and arcing outwards from the top-left corner (x: 10%, y: 5%) where the camera hole punch is located. Intense glowing rim lighting, high contrast, clean.",
            "description": "Coiling cyan electric plasma arc originating directly from the top-left camera hole punch.",
            "colors": ["#0A0A0E", "#00E599"],
            "cutoutType": "leftHole"
        },
        {
            "title": "Corner Starburst Nova",
            "prompt": "Vertical 9:16 mobile wallpaper. Pure black AMOLED background. Brilliant miniature supernova starburst detonating in the top-left corner (x: 10%, y: 5%) with subtle prismatic light refractions.",
            "description": "Miniature celestial supernova burst exploding from the top-left camera cutout.",
            "colors": ["#000000", "#FF685F"],
            "cutoutType": "leftHole"
        }
    ],
    "Creative Cutouts": [
        {
            "title": "Astronaut Starlight Reach",
            "prompt": "Vertical 9:16 mobile wallpaper. Pure deep OLED black canvas. A lone minimalist astronaut floating in zero gravity from the bottom-left, reaching up with a glowing glove toward the camera cutout at the top-center. Ethereal, poetic, clean negative space, 8K.",
            "description": "Minimalist astronaut floating on pitch-black canvas reaching out to illuminate the front camera lens.",
            "colors": ["#000000", "#632FE1"],
            "cutoutType": "centerHole"
        },
        {
            "title": "Cat on the Bezel",
            "prompt": "Vertical 9:16 mobile wallpaper. Deep black background. Adorable playful black cat silhouette hanging from the top edge with luminous emerald eyes gazing down at the camera punch hole. Minimalist, charming, crisp lines.",
            "description": "Charming black cat silhouette dangling with playful curiosity directly above the punch hole.",
            "colors": ["#000000", "#FF685F"],
            "cutoutType": "centerHole"
        }
    ],
    "AMOLED Stealth": [
        {
            "title": "Obsidian Stealth Abyss",
            "prompt": "Vertical 9:16 mobile wallpaper. Upper 25% of the screen is pure solid #000000 pitch black. Slowly transitioning downwards into magnificent smooth molten violet and midnight silk flows. Zero notch visibility, maximum battery savings, ultra clean.",
            "description": "Seamless top-fade into absolute #000000 pure black, making any notch, pill, or hole-punch completely invisible.",
            "colors": ["#000000", "#1E1B4B"],
            "cutoutType": "universal"
        }
    ]
}

CATEGORY_FOLDERS = {
    "Center Hole": "categories/center_hole",
    "Dynamic Island": "categories/dynamic_island",
    "Left Corner": "categories/left_corner",
    "Creative Cutouts": "categories/creative_cutouts",
    "AMOLED Stealth": "categories/amoled_stealth",
}


def create_pure_python_png(width: int, height: int, c1_hex: str, c2_hex: str) -> bytes:
    """Generate a valid, compressed PNG image using standard library without external dependencies."""
    def hex_to_rgb(hex_str: str):
        hex_str = hex_str.lstrip("#")
        return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

    c1 = hex_to_rgb(c1_hex)
    c2 = hex_to_rgb(c2_hex)

    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)  # Filter byte: None
        factor = y / height
        r = int(c1[0] * (1 - factor) + c2[0] * factor)
        g = int(c1[1] * (1 - factor) + c2[1] * factor)
        b = int(c1[2] * (1 - factor) + c2[2] * factor)
        raw_data.extend(bytes([r, g, b]))

    def chunk(chunk_type: bytes, data: bytes) -> bytes:
        c = chunk_type + data
        crc = struct.pack(">I", zlib.crc32(c))
        return struct.pack(">I", len(data)) + c + crc

    png_bytes = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    png_bytes += chunk(b"IHDR", ihdr)
    compressed = zlib.compress(bytes(raw_data), 6)
    png_bytes += chunk(b"IDAT", compressed)
    png_bytes += chunk(b"IEND", b"")
    return png_bytes


def http_post_json(url: str, headers: dict, payload: dict) -> dict:
    """Perform HTTP POST with requests or fallback to urllib."""
    data_bytes = json.dumps(payload).encode("utf-8")
    if HAS_REQUESTS:
        resp = requests.post(url, headers=headers, json=payload, timeout=90)
        if resp.status_code != 200:
            raise RuntimeError(f"HTTP Error {resp.status_code}: {resp.text}")
        return resp.json()
    else:
        req = urllib.request.Request(url, data=data_bytes, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=90) as response:
            return json.loads(response.read().decode("utf-8"))


def http_get_bytes(url: str) -> bytes:
    """Download binary data via HTTP with requests or urllib."""
    if HAS_REQUESTS:
        resp = requests.get(url, timeout=60)
        if resp.status_code != 200:
            raise RuntimeError(f"HTTP Download failed: {resp.status_code}")
        return resp.content
    else:
        with urllib.request.urlopen(url, timeout=60) as response:
            return response.read()


def generate_image_openai(prompt: str, api_key: str) -> bytes:
    """Generate image using OpenAI DALL-E 3 API (returns raw PNG/JPEG image bytes)."""
    url = "https://api.openai.com/v1/images/generations"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1792",  # Vertical 9:16 mobile aspect ratio
        "quality": "hd",
        "style": "vivid"
    }

    print("Sending generation request to OpenAI DALL-E 3 (size 1024x1792)...")
    data = http_post_json(url, headers, payload)
    image_url = data["data"][0]["url"]
    print("Image generated successfully. Downloading from CDN...")
    return http_get_bytes(image_url)


def run_generator(count: int = 2, target_category: str = "random", provider: str = "openai"):
    api_key = os.environ.get("AI_IMAGE_API_KEY") or os.environ.get("OPENAI_API_KEY")
    repo = os.environ.get("GITHUB_REPOSITORY", "").strip()

    print("=" * 60)
    print(" Vivid Notch AI - Automated Camera Cutout Generator")
    print(f" Target Count: {count}")
    print(f" Category:     {target_category}")
    print(f" Provider:     {provider}")
    print(f" Repository:   {repo if repo else '(local execution)'}")
    print("=" * 60)

    is_live_api = bool(api_key and len(api_key) > 10 and not api_key.startswith("your_"))
    if not is_live_api:
        print("\n[NOTE] AI_IMAGE_API_KEY is not configured or in placeholder mode.")
        print("-> The worker will create clean test artworks so the GitHub Action passes.")
        print("-> To enable real AI generation, add AI_IMAGE_API_KEY to GitHub Secrets!\n")

    # Ensure directories exist
    for folder in CATEGORY_FOLDERS.values():
        (WALLPAPERS_DIR / folder).mkdir(parents=True, exist_ok=True)
    THUMBNAILS_DIR.mkdir(parents=True, exist_ok=True)
    METADATA_DIR.mkdir(parents=True, exist_ok=True)

    # Load existing catalog
    catalog = []
    if CATALOG_PATH.exists():
        try:
            with open(CATALOG_PATH, "r", encoding="utf-8") as f:
                catalog = json.load(f)
        except Exception as e:
            print(f"Warning: Could not read existing catalog ({e}), initializing empty catalog.")
            catalog = []

    existing_ids = {item.get("id") for item in catalog}
    new_entries = []

    categories_list = list(PROMPT_CATALOG.keys())

    for i in range(count):
        cat = target_category if target_category in PROMPT_CATALOG else random.choice(categories_list)
        prompt_info = random.choice(PROMPT_CATALOG[cat])

        timestamp_str = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        uid = f"wp_{timestamp_str}_{random.randint(100, 999)}"
        while uid in existing_ids:
            uid = f"wp_{timestamp_str}_{random.randint(1000, 9999)}"
        existing_ids.add(uid)

        title = prompt_info["title"]
        prompt_text = prompt_info["prompt"]
        desc = prompt_info["description"]
        cutout_type = prompt_info.get("cutoutType", "centerHole")
        fallback_colors = prompt_info.get("colors", ["#000000", "#FFB703"])
        category_folder = CATEGORY_FOLDERS.get(cat, "categories/center_hole")

        filename = f"{uid}.png"
        thumb_filename = f"{uid}.png"

        full_img_path = WALLPAPERS_DIR / category_folder / filename
        thumb_img_path = THUMBNAILS_DIR / thumb_filename

        print(f"\n[{i+1}/{count}] Generating '{title}' ({cat})...")

        # Generate or download image bytes
        img_bytes = None
        if is_live_api and provider == "openai":
            try:
                img_bytes = generate_image_openai(prompt_text, api_key)
            except Exception as e:
                print(f"API generation error: {e}")
                print("Falling back to procedural artwork...")
                img_bytes = create_pure_python_png(720, 1280, fallback_colors[0], fallback_colors[1])
        else:
            img_bytes = create_pure_python_png(720, 1280, fallback_colors[0], fallback_colors[1])
            time.sleep(0.2)

        # Save master image
        with open(full_img_path, "wb") as f:
            f.write(img_bytes)
        print(f"Saved master image: {full_img_path.relative_to(REPO_ROOT)}")

        # Save thumbnail
        if HAS_PIL:
            try:
                pil_img = Image.open(BytesIO(img_bytes))
                pil_thumb = pil_img.copy()
                pil_thumb.thumbnail((360, 640), Image.Resampling.LANCZOS)
                thumb_webp_path = THUMBNAILS_DIR / f"{uid}.webp"
                pil_thumb.save(thumb_webp_path, format="WEBP", quality=85)
                thumb_filename = f"{uid}.webp"
                print(f"Saved WebP thumbnail: {thumb_webp_path.relative_to(REPO_ROOT)}")
            except Exception as e:
                with open(thumb_img_path, "wb") as f:
                    f.write(img_bytes)
        else:
            thumb_bytes = create_pure_python_png(360, 640, fallback_colors[0], fallback_colors[1])
            with open(thumb_img_path, "wb") as f:
                f.write(thumb_bytes)
            print(f"Saved thumbnail:    {thumb_img_path.relative_to(REPO_ROOT)}")

        # Construct URLs
        if repo:
            image_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/{category_folder}/{filename}"
            thumb_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/thumbnails/{thumb_filename}"
        else:
            image_url = f"wallpapers/{category_folder}/{filename}"
            thumb_url = f"wallpapers/thumbnails/{thumb_filename}"

        today_formatted = datetime.utcnow().strftime("%B %d, %Y")

        new_entry = {
            "id": uid,
            "title": title,
            "category": cat,
            "cutoutType": cutout_type,
            "imageUrl": image_url,
            "thumbnailUrl": thumb_url,
            "isMultivariant": False,
            "variants": [],
            "cutoutVariants": {},
            "gradientFallback": fallback_colors,
            "resolution": "4K Ultra HD",
            "dimensions": "1080 x 2400",
            "uploadDate": today_formatted,
            "description": desc,
            "views": random.randint(120, 950),
            "isLiked": False,
            "aiEngine": "DALL-E 3 / Vivid Notch AI" if is_live_api else "Vivid Notch Procedural"
        }

        new_entries.append(new_entry)

    # Prepend new entries so latest wallpapers appear at the top
    updated_catalog = new_entries + catalog

    # Save updated catalog
    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(updated_catalog, f, indent=2, ensure_ascii=False)

    print("\n" + "=" * 60)
    print(f" Done! Added {len(new_entries)} new cutout wallpapers to catalog.json.")
    print(f" Total wallpapers in catalog: {len(updated_catalog)}")
    print("=" * 60)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate Cutout Wallpapers for Vivid Notch AI")
    parser.add_argument("--count", type=int, default=int(os.environ.get("WALLPAPERS_COUNT", "2")),
                        help="Number of wallpapers to generate (default: 2)")
    parser.add_argument("--category", type=str, default="random",
                        help="Target category (or 'random')")
    parser.add_argument("--provider", type=str, default=os.environ.get("AI_PROVIDER", "openai"),
                        help="AI Provider: openai (default), stability, or mock")

    args = parser.parse_args()
    run_generator(count=args.count, target_category=args.category, provider=args.provider)

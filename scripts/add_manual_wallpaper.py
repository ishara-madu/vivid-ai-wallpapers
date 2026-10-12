#!/usr/bin/env python3
"""
Vivid Notch AI - Manual Wallpaper Publisher
-------------------------------------------
Easily add high-quality manual wallpapers to the repository with auto-generated
WebP thumbnails, color extraction, and catalog.json registration.

Usage:
  python scripts/add_manual_wallpaper.py --file /path/to/image.png --title "Solar Corona" --category "Center Hole"
"""

import os
import sys
import json
import shutil
import random
import argparse
from datetime import datetime
from pathlib import Path

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
WALLPAPERS_DIR = REPO_ROOT / "wallpapers"
CATEGORIES_DIR = WALLPAPERS_DIR / "categories"
THUMBNAILS_DIR = WALLPAPERS_DIR / "thumbnails"
METADATA_DIR = WALLPAPERS_DIR / "metadata"
CATALOG_PATH = METADATA_DIR / "catalog.json"

CATEGORY_MAP = {
    "center hole": ("Center Hole", "categories/center_hole", "centerHole"),
    "dynamic island": ("Dynamic Island", "categories/dynamic_island", "dynamicIsland"),
    "left corner": ("Left Corner", "categories/left_corner", "leftHole"),
    "creative cutouts": ("Creative Cutouts", "categories/creative_cutouts", "centerHole"),
    "amoled stealth": ("AMOLED Stealth", "categories/amoled_stealth", "universal"),
}

DEFAULT_REPO = "ishara-madu/vivid-ai-wallpapers"


def get_dominant_colors(image_path: Path) -> list:
    """Extract dominant or accent colors for smooth UI gradient fallback."""
    if not HAS_PIL:
        return ["#000000", "#632FE1"]
    try:
        with Image.open(image_path) as img:
            img = img.convert("RGB")
            # Sample corners or resize to 16x16
            small = img.resize((16, 16), Image.Resampling.BOX)
            colors = small.getcolors(maxcolors=256)
            if colors:
                # Sort by count
                colors.sort(key=lambda x: x[0], reverse=True)
                top_color = colors[0][1]
                accent_color = colors[min(1, len(colors) - 1)][1]
                c1 = f"#{top_color[0]:02X}{top_color[1]:02X}{top_color[2]:02X}"
                c2 = f"#{accent_color[0]:02X}{accent_color[1]:02X}{accent_color[2]:02X}"
                return [c1, c2]
    except Exception:
        pass
    return ["#000000", "#632FE1"]


def add_wallpaper(image_file: str, title: str, category_input: str, description: str = ""):
    src_path = Path(image_file).expanduser().resolve()
    if not src_path.exists() or not src_path.is_file():
        print(f"Error: File not found: {src_path}")
        sys.exit(1)

    cat_key = category_input.strip().lower()
    if cat_key not in CATEGORY_MAP:
        valid_cats = list(CATEGORY_MAP.keys())
        print(f"Error: Invalid category '{category_input}'. Choose from: {valid_cats}")
        sys.exit(1)

    cat_display, folder_rel, cutout_type = CATEGORY_MAP[cat_key]
    dest_folder = WALLPAPERS_DIR / folder_rel
    dest_folder.mkdir(parents=True, exist_ok=True)
    THUMBNAILS_DIR.mkdir(parents=True, exist_ok=True)
    METADATA_DIR.mkdir(parents=True, exist_ok=True)

    # Generate unique ID
    timestamp_str = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    ext = src_path.suffix.lower()
    if ext not in [".png", ".jpg", ".jpeg", ".webp"]:
        ext = ".png"

    uid = f"wp_{timestamp_str}_{random.randint(100, 999)}"
    dest_filename = f"{uid}{ext}"
    dest_img_path = dest_folder / dest_filename

    # Copy original image
    shutil.copy2(src_path, dest_img_path)
    print(f"✓ Copied master image to: wallpapers/{folder_rel}/{dest_filename}")

    # Generate WebP thumbnail
    thumb_filename = f"{uid}.webp"
    thumb_path = THUMBNAILS_DIR / thumb_filename

    dimensions_str = "1080 x 2400"
    if HAS_PIL:
        try:
            with Image.open(src_path) as img:
                w, h = img.size
                dimensions_str = f"{w} x {h}"
                img_copy = img.convert("RGB")
                img_copy.thumbnail((360, 640), Image.Resampling.LANCZOS)
                img_copy.save(thumb_path, format="WEBP", quality=85)
                print(f"✓ Created WebP thumbnail: wallpapers/thumbnails/{thumb_filename}")
        except Exception as e:
            print(f"Notice: Thumbnail creation error ({e}), copying original as fallback.")
            shutil.copy2(src_path, thumb_path)
    else:
        shutil.copy2(src_path, thumb_path)

    # Extract colors
    colors = get_dominant_colors(dest_img_path)

    # Construct URLs
    repo = os.environ.get("GITHUB_REPOSITORY", DEFAULT_REPO).strip()
    image_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/{folder_rel}/{dest_filename}"
    thumb_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/thumbnails/{thumb_filename}"

    today_str = datetime.utcnow().strftime("%B %d, %Y")
    desc = description.strip() if description.strip() else f"Curated Ultra HD AMOLED wallpaper engineered for {cat_display} camera notch."

    new_item = {
        "id": uid,
        "title": title.strip(),
        "category": cat_display,
        "cutoutType": cutout_type,
        "imageUrl": image_url,
        "thumbnailUrl": thumb_url,
        "isMultivariant": False,
        "variants": [],
        "cutoutVariants": {},
        "gradientFallback": colors,
        "resolution": "4K Ultra HD",
        "dimensions": dimensions_str,
        "uploadDate": today_str,
        "description": desc,
        "views": random.randint(350, 1200),
        "isLiked": False,
        "aiEngine": "Curated Artwork"
    }

    # Load and update catalog
    catalog = []
    if CATALOG_PATH.exists():
        try:
            with open(CATALOG_PATH, "r", encoding="utf-8") as f:
                catalog = json.load(f)
        except Exception:
            catalog = []

    # Insert at top so new wallpaper appears first
    catalog.insert(0, new_item)

    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(catalog, f, indent=2, ensure_ascii=False)

    print(f"✓ Registered in wallpapers/metadata/catalog.json (Total: {len(catalog)})")
    print("\n" + "=" * 60)
    print(f" Successfully published: '{title}' [{cat_display}]")
    print("=" * 60)
    print("\nTo push changes to GitHub, run:")
    print("  git add wallpapers/ && git commit -m 'Add new wallpaper' && git push")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a manual high-quality wallpaper")
    parser.add_argument("--file", "-f", required=True, help="Path to image file (PNG/JPG)")
    parser.add_argument("--title", "-t", required=True, help="Wallpaper title (e.g. 'Cosmic Void')")
    parser.add_argument("--category", "-c", required=True,
                        choices=["Center Hole", "Dynamic Island", "Left Corner", "Creative Cutouts", "AMOLED Stealth"],
                        help="Cutout Category")
    parser.add_argument("--description", "-d", default="", help="Optional description")

    args = parser.parse_args()
    add_wallpaper(args.file, args.title, args.category, args.description)

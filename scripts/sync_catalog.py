#!/usr/bin/env python3
"""
Vivid Notch AI - Folder Sync & Catalog Generator
------------------------------------------------
Scans the wallpaper category folders. Any images dropped into
'wallpapers/categories/<folder>/' will be automatically:
  1. Thumbnailed to WebP (360x640)
  2. Registered in catalog.json
  3. Cleaned of any non-existent references

Usage:
  python scripts/sync_catalog.py
"""

import os
import json
import random
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

CATEGORY_CONFIG = {
    "center_hole": ("Center Hole", "centerHole"),
    "dynamic_island": ("Dynamic Island", "dynamicIsland"),
    "left_corner": ("Left Corner", "leftHole"),
    "creative_cutouts": ("Creative Cutouts", "centerHole"),
    "amoled_stealth": ("AMOLED Stealth", "universal"),
    "vibrant_flows": ("Vibrant Flows", "centerHole"),
    "3d": ("3D", "centerHole"),
    "minimal": ("Minimal", "universal"),
    "abstract": ("Abstract", "centerHole"),
    "landscapes": ("Landscapes", "centerHole"),
    "amoled": ("AMOLED", "universal"),
}

DEFAULT_REPO = "ishara-madu/vivid-ai-wallpapers"


def get_dominant_colors(image_path: Path) -> list:
    if not HAS_PIL:
        return ["#000000", "#632FE1"]
    try:
        with Image.open(image_path) as img:
            img = img.convert("RGB")
            small = img.resize((16, 16), Image.Resampling.BOX)
            colors = small.getcolors(maxcolors=256)
            if colors:
                colors.sort(key=lambda x: x[0], reverse=True)
                top = colors[0][1]
                accent = colors[min(1, len(colors) - 1)][1]
                c1 = f"#{top[0]:02X}{top[1]:02X}{top[2]:02X}"
                c2 = f"#{accent[0]:02X}{accent[1]:02X}{accent[2]:02X}"
                return [c1, c2]
    except Exception:
        pass
    return ["#000000", "#632FE1"]


def sync_catalog():
    THUMBNAILS_DIR.mkdir(parents=True, exist_ok=True)
    METADATA_DIR.mkdir(parents=True, exist_ok=True)

    # Load existing catalog
    existing_items = []
    if CATALOG_PATH.exists():
        try:
            with open(CATALOG_PATH, "r", encoding="utf-8") as f:
                existing_items = json.load(f)
        except Exception:
            existing_items = []

    # Map existing filenames to item
    indexed_filenames = {}
    for item in existing_items:
        img_url = item.get("imageUrl", "")
        fn = Path(img_url).name
        indexed_filenames[fn] = item

    repo = os.environ.get("GITHUB_REPOSITORY", DEFAULT_REPO).strip()
    newly_added = 0
    updated_catalog = []

    # Walk through categories
    for folder_name, (cat_display, cutout_type) in CATEGORY_CONFIG.items():
        cat_folder = CATEGORIES_DIR / folder_name
        if not cat_folder.exists():
            continue

        for img_path in sorted(cat_folder.iterdir()):
            if img_path.name.startswith(".") or img_path.suffix.lower() not in [".png", ".jpg", ".jpeg", ".webp"]:
                continue

            fn = img_path.name
            uid = img_path.stem

            # Check if thumbnail exists, create if missing
            thumb_path = THUMBNAILS_DIR / f"{uid}.webp"
            if not thumb_path.exists():
                if HAS_PIL:
                    try:
                        with Image.open(img_path) as img:
                            img_copy = img.convert("RGB")
                            img_copy.thumbnail((360, 640), Image.Resampling.LANCZOS)
                            img_copy.save(thumb_path, format="WEBP", quality=85)
                            print(f"✓ Generated WebP thumbnail: {thumb_path.name}")
                    except Exception as e:
                        print(f"Notice: Could not thumbnail {fn} ({e})")
                else:
                    import shutil
                    shutil.copy2(img_path, thumb_path)

            thumb_filename = f"{uid}.webp" if thumb_path.exists() else fn
            image_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/categories/{folder_name}/{fn}"
            thumb_url = f"https://raw.githubusercontent.com/{repo}/main/wallpapers/thumbnails/{thumb_filename}"

            if fn in indexed_filenames:
                # Update URLs and preserve metadata
                entry = indexed_filenames[fn]
                entry["imageUrl"] = image_url
                entry["thumbnailUrl"] = thumb_url
                entry["category"] = cat_display
                entry["cutoutType"] = entry.get("cutoutType", cutout_type)
                updated_catalog.append(entry)
            else:
                # Brand new image discovered
                newly_added += 1
                colors = get_dominant_colors(img_path)
                dims = "1080 x 2400"
                if HAS_PIL:
                    try:
                        with Image.open(img_path) as img:
                            dims = f"{img.width} x {img.height}"
                    except Exception:
                        pass

                clean_title = uid.replace("wp_", "").replace("_", " ").title()
                if clean_title.replace(" ", "").isdigit():
                    clean_title = f"{cat_display} Wallpaper"

                new_entry = {
                    "id": uid,
                    "title": clean_title,
                    "category": cat_display,
                    "cutoutType": cutout_type,
                    "imageUrl": image_url,
                    "thumbnailUrl": thumb_url,
                    "isMultivariant": False,
                    "variants": [],
                    "cutoutVariants": {},
                    "gradientFallback": colors,
                    "resolution": "4K Ultra HD",
                    "dimensions": dims,
                    "uploadDate": "Recently added",
                    "description": f"Ultra HD AMOLED artwork for {cat_display}.",
                    "views": random.randint(200, 800),
                    "isLiked": False,
                    "aiEngine": "Curated Master"
                }
                updated_catalog.insert(0, new_entry)
                print(f"✓ Discovered and added new image: {fn} [{cat_display}]")

    # Save synchronized catalog
    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(updated_catalog, f, indent=2, ensure_ascii=False)

    print("\n" + "=" * 60)
    print(f" Sync complete! Catalog has {len(updated_catalog)} wallpapers.")
    if newly_added > 0:
        print(f" Added {newly_added} new images.")
    print("=" * 60)


if __name__ == "__main__":
    sync_catalog()

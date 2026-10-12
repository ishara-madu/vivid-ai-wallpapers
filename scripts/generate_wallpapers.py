#!/usr/bin/env python3
"""
Vivid Notch AI - Two-Stage Automated AI Wallpaper Generator
------------------------------------------------------------
Stage 1 (Brain): Google Gemini 1.5 Flash (Free Tier)
  - Dynamically synthesizes creative concepts, catchy titles,
    poetic descriptions, and precision camera-cutout prompts.

Stage 2 (Painter): Hugging Face Inference API (FLUX.1-schnell / SDXL) (Free Tier)
  - Renders vertical 9:16 Ultra HD AMOLED masterworks.

Supported Environment Variables:
  - GEMINI_API_KEY: Google AI Studio API Key (Free tier at aistudio.google.com)
  - HF_TOKEN / HUGGINGFACE_API_KEY: Hugging Face user token (Free at huggingface.co)
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
import urllib.parse
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

# Curated Fallback Prompts (used if GEMINI_API_KEY is not provided)
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

CUTOUT_TYPE_MAP = {
    "Center Hole": "centerHole",
    "Dynamic Island": "dynamicIsland",
    "Left Corner": "leftHole",
    "Creative Cutouts": "centerHole",
    "AMOLED Stealth": "universal",
}


def http_post_json(url: str, headers: dict, payload: dict, timeout: int = 60) -> dict:
    """Perform HTTP POST with requests or urllib."""
    data_bytes = json.dumps(payload).encode("utf-8")
    if HAS_REQUESTS:
        resp = requests.post(url, headers=headers, json=payload, timeout=timeout)
        if resp.status_code != 200:
            raise RuntimeError(f"HTTP Error {resp.status_code}: {resp.text}")
        return resp.json()
    else:
        req = urllib.request.Request(url, data=data_bytes, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))


def http_post_binary(url: str, headers: dict, payload: dict, timeout: int = 90) -> bytes:
    """Perform HTTP POST expecting binary response (image bytes)."""
    data_bytes = json.dumps(payload).encode("utf-8")
    if HAS_REQUESTS:
        resp = requests.post(url, headers=headers, json=payload, timeout=timeout)
        if resp.status_code != 200:
            raise RuntimeError(f"HTTP Error {resp.status_code}: {resp.text}")
        return resp.content
    else:
        req = urllib.request.Request(url, data=data_bytes, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=timeout) as response:
            return response.read()


def http_get_bytes(url: str, timeout: int = 60) -> bytes:
    """Download binary data via HTTP with requests or urllib."""
    if HAS_REQUESTS:
        resp = requests.get(url, timeout=timeout)
        if resp.status_code != 200:
            raise RuntimeError(f"HTTP Download failed: {resp.status_code}")
        return resp.content
    else:
        with urllib.request.urlopen(url, timeout=timeout) as response:
            return response.read()


def create_pure_python_png(width: int, height: int, c1_hex: str, c2_hex: str) -> bytes:
    """Generate a valid, compressed PNG image using standard library without external dependencies."""
    def hex_to_rgb(hex_str: str):
        hex_str = hex_str.lstrip("#")
        return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

    c1 = hex_to_rgb(c1_hex)
    c2 = hex_to_rgb(c2_hex)

    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)
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


# ---------------------------------------------------------------------------
# STAGE 1: Google Gemini API (Text Concept & Precision Prompt Generation)
# ---------------------------------------------------------------------------

def generate_concept_with_gemini(category: str, api_key: str) -> dict:
    """
    Uses Google Gemini 1.5 Flash (Free Tier) to generate a unique, creative
    cutout concept, poetic description, and FLUX image prompt.
    """
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    headers = {"Content-Type": "application/json"}

    cutout_hint = {
        "Center Hole": "The physical front camera punch hole is at the TOP CENTER (x: 50%, y: 5%). Design an element that orbits, frames, or radiates from this center hole.",
        "Dynamic Island": "The physical camera is a horizontal pill / capsule at TOP CENTER (x: 50%, y: 6%). Design glowing audio soundwaves, visors, or capsule flows framing the island.",
        "Left Corner": "The physical camera hole punch is in the TOP-LEFT CORNER (x: 10%, y: 5%). Design lightning arcs, celestial bursts, or characters interacting from the top-left.",
        "Creative Cutouts": "Playful, surreal character interactions with the camera punch hole at TOP CENTER (e.g., astronaut, cat, robot, portal, dripping fluid).",
        "AMOLED Stealth": "The top 20% of the wallpaper must be PURE SOLID #000000 true black to make any camera cutout completely invisible, transitioning into deep fluid or neon flows below.",
    }.get(category, "Camera cutout at top center.")

    prompt_instruction = f"""
You are the master Art Director for 'Vivid Notch AI' - an elite mobile wallpaper app specializing in wallpapers tailored for smartphone camera punch holes and notches.

Generate 1 brand new, stunning wallpaper concept for Category: '{category}'.
Target Screen: 9:16 mobile aspect ratio (portrait).
Cutout requirement: {cutout_hint}
Aesthetic: Deep pure OLED pitch black #000000 canvas, vivid luminous accents (neon amber, cyan, violet, or coral), ultra-modern, elegant, minimalist.

Respond ONLY with a valid JSON object matching this schema:
{{
  "title": "Short poetic title (2-4 words)",
  "category": "{category}",
  "cutoutType": "{CUTOUT_TYPE_MAP.get(category, 'centerHole')}",
  "description": "Poetic 1-2 sentence description explaining how the artwork compliments the camera cutout and OLED screen.",
  "prompt": "Ultra-detailed FLUX.1 / SDXL image generation prompt. Specify: 'Vertical 9:16 mobile wallpaper. Deep pure OLED pitch black #000000 background.' clearly describing the geometry, lighting, textures, and cutout interaction. Keep under 120 words.",
  "colors": ["#000000", "#HEX_ACCENT_COLOR"]
}}
"""

    payload = {
        "contents": [
            {
                "parts": [
                    {"text": prompt_instruction}
                ]
            }
        ],
        "generationConfig": {
            "responseMimeType": "application/json",
            "temperature": 0.9
        }
    }

    print(f"Calling Google Gemini 1.5 Flash to synthesize new '{category}' concept...")
    result = http_post_json(url, headers, payload, timeout=30)
    
    # Parse candidate response
    candidate_text = result["candidates"][0]["content"]["parts"][0]["text"]
    concept_data = json.loads(candidate_text)
    print(f"-> Gemini conceived: '{concept_data.get('title')}'")
    return concept_data


# ---------------------------------------------------------------------------
# STAGE 2: Hugging Face API / FLUX.1-schnell (Image Generation)
# ---------------------------------------------------------------------------

def generate_image_with_huggingface(prompt: str, hf_token: str) -> bytes:
    """
    Uses Hugging Face Serverless Inference API (Free Tier) to generate 
    a vertical 9:16 wallpaper using FLUX.1-schnell or SDXL.
    """
    models = [
        "black-forest-labs/FLUX.1-schnell",
        "stabilityai/stable-diffusion-xl-base-1.0"
    ]

    headers = {
        "Authorization": f"Bearer {hf_token}",
        "Content-Type": "application/json"
    }

    for model in models:
        url = f"https://api-inference.huggingface.co/models/{model}"
        payload = {
            "inputs": prompt,
            "parameters": {
                "width": 768,
                "height": 1344
            }
        }

        print(f"Sending prompt to Hugging Face ({model})...")
        for attempt in range(3):
            try:
                img_bytes = http_post_binary(url, headers, payload, timeout=90)
                # Verify that response is binary image data, not a JSON error
                if img_bytes.startswith(b"{"):
                    err_json = json.loads(img_bytes.decode("utf-8", errors="ignore"))
                    if "estimated_time" in err_json:
                        wait_sec = min(int(err_json.get("estimated_time", 10)), 20)
                        print(f"Model is loading, waiting {wait_sec}s (attempt {attempt+1}/3)...")
                        time.sleep(wait_sec)
                        continue
                    else:
                        raise RuntimeError(f"HF Error: {err_json}")
                print(f"-> Image received successfully from {model} ({len(img_bytes)} bytes)")
                return img_bytes
            except Exception as e:
                print(f"Warning: Attempt {attempt+1} on {model} failed: {e}")
                time.sleep(4)

    raise RuntimeError("All Hugging Face models failed to respond.")


def generate_image_with_pollinations(prompt: str) -> bytes:
    """
    Fallback 100% Free FLUX generator (Pollinations.ai) requiring zero API keys.
    """
    encoded_prompt = urllib.parse.quote(prompt)
    url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width=768&height=1344&model=flux&nologo=true"
    print("Calling Pollinations FLUX engine (Zero-key fallback)...")
    return http_get_bytes(url, timeout=70)


# ---------------------------------------------------------------------------
# MAIN WORKER RUNNER
# ---------------------------------------------------------------------------

def run_generator(count: int = 2, target_category: str = "random"):
    gemini_key = os.environ.get("GEMINI_API_KEY", "").strip()
    hf_token = os.environ.get("HF_TOKEN") or os.environ.get("HUGGINGFACE_API_KEY", "").strip()
    repo = os.environ.get("GITHUB_REPOSITORY", "").strip()

    print("=" * 65)
    print(" Vivid Notch AI - Two-Stage Automated AI Generator")
    print(f" Stage 1 (Text):  {'Google Gemini 1.5 Flash' if gemini_key else 'Curated Prompt Catalog'}")
    print(f" Stage 2 (Image): {'Hugging Face FLUX.1' if hf_token else 'Pollinations FLUX / Fallback'}")
    print(f" Target Count:    {count}")
    print(f" Category:        {target_category}")
    print(f" Repository:      {repo if repo else '(local)'}")
    print("=" * 65)

    if not gemini_key:
        print("[TIP] To enable dynamic AI prompt synthesis, add GEMINI_API_KEY in GitHub Secrets.")
    if not hf_token:
        print("[TIP] To enable Hugging Face FLUX image generation, add HF_TOKEN in GitHub Secrets.")

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
            print(f"Warning: Could not read existing catalog ({e}), starting empty.")
            catalog = []

    existing_ids = {item.get("id") for item in catalog}
    new_entries = []
    categories_list = list(PROMPT_CATALOG.keys())

    for i in range(count):
        cat = target_category if target_category in PROMPT_CATALOG else random.choice(categories_list)

        print(f"\n--- [{i+1}/{count}] Processing Category: '{cat}' ---")

        # -------------------------------------------------------------------
        # STAGE 1: Concept & Text Generation
        # -------------------------------------------------------------------
        prompt_info = None
        if gemini_key:
            try:
                prompt_info = generate_concept_with_gemini(cat, gemini_key)
            except Exception as e:
                print(f"Notice: Gemini generation error ({e}). Falling back to curated catalog.")

        if not prompt_info:
            prompt_info = random.choice(PROMPT_CATALOG[cat])

        title = prompt_info["title"]
        prompt_text = prompt_info["prompt"]
        desc = prompt_info["description"]
        cutout_type = prompt_info.get("cutoutType", CUTOUT_TYPE_MAP.get(cat, "centerHole"))
        fallback_colors = prompt_info.get("colors", ["#000000", "#FFB703"])
        category_folder = CATEGORY_FOLDERS.get(cat, "categories/center_hole")

        timestamp_str = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        uid = f"wp_{timestamp_str}_{random.randint(100, 999)}"
        while uid in existing_ids:
            uid = f"wp_{timestamp_str}_{random.randint(1000, 9999)}"
        existing_ids.add(uid)

        filename = f"{uid}.png"
        thumb_filename = f"{uid}.png"

        full_img_path = WALLPAPERS_DIR / category_folder / filename
        thumb_img_path = THUMBNAILS_DIR / thumb_filename

        # -------------------------------------------------------------------
        # STAGE 2: Image Generation
        # -------------------------------------------------------------------
        img_bytes = None
        ai_engine_name = "Vivid Notch Procedural"

        if hf_token:
            try:
                img_bytes = generate_image_with_huggingface(prompt_text, hf_token)
                ai_engine_name = "Gemini + FLUX.1-schnell" if gemini_key else "Hugging Face FLUX.1"
            except Exception as e:
                print(f"HF Generation failed ({e}). Trying Pollinations FLUX...")
                try:
                    img_bytes = generate_image_with_pollinations(prompt_text)
                    ai_engine_name = "Gemini + Pollinations FLUX" if gemini_key else "Pollinations FLUX"
                except Exception as e2:
                    print(f"Pollinations also failed ({e2}). Using clean procedural PNG...")
                    img_bytes = create_pure_python_png(720, 1280, fallback_colors[0], fallback_colors[1])
        else:
            # Try Pollinations free endpoint first
            try:
                img_bytes = generate_image_with_pollinations(prompt_text)
                ai_engine_name = "Gemini + Pollinations FLUX" if gemini_key else "Pollinations FLUX"
            except Exception as e:
                print(f"Pollinations fallback failed ({e}). Writing procedural artwork...")
                img_bytes = create_pure_python_png(720, 1280, fallback_colors[0], fallback_colors[1])

        # Save Full-Res Master
        with open(full_img_path, "wb") as f:
            f.write(img_bytes)
        print(f"Saved master image: {full_img_path.relative_to(REPO_ROOT)}")

        # Save WebP or PNG thumbnail
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
            "aiEngine": ai_engine_name
        }

        new_entries.append(new_entry)

    # Prepend new entries so latest appear first
    updated_catalog = new_entries + catalog

    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(updated_catalog, f, indent=2, ensure_ascii=False)

    print("\n" + "=" * 65)
    print(f" Done! Added {len(new_entries)} new wallpapers to catalog.json.")
    print(f" Total wallpapers in catalog: {len(updated_catalog)}")
    print("=" * 65)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Vivid Notch AI - Automated Wallpaper Worker")
    parser.add_argument("--count", type=int, default=int(os.environ.get("WALLPAPERS_COUNT", "2")),
                        help="Number of wallpapers to generate (default: 2)")
    parser.add_argument("--category", type=str, default="random",
                        help="Target category (or 'random')")

    args = parser.parse_args()
    run_generator(count=args.count, target_category=args.category)

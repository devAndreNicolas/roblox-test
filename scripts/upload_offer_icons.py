"""Upload Bingo Noir marketplace icons using an Open Cloud API key file.

Usage: python scripts/upload_offer_icons.py --key-file PATH --universe 10772003576
The key stays outside the repository and is never printed.
"""

import argparse
import json
import urllib.error
import urllib.request
import uuid
from pathlib import Path


ICONS = (
    ("developer-products/v2", "developer-products", 3720520619, "fichas_120.png", "imageFile"),
    ("developer-products/v2", "developer-products", 3720520624, "fichas_350.png", "imageFile"),
    ("developer-products/v2", "developer-products", 3720520631, "fichas_800.png", "imageFile"),
    ("developer-products/v2", "developer-products", 3720520635, "suborn.png", "imageFile"),
    ("game-passes/v1", "game-passes", 2044514400, "dossier_blue.png", "file"),
    ("game-passes/v1", "game-passes", 2045168372, "stage_star.png", "file"),
    ("game-passes/v1", "game-passes", 2045120362, "club_seal.png", "file"),
    ("game-passes/v1", "game-passes", 2045108372, "on_air.png", "file"),
    ("game-passes/v1", "game-passes", 2045330347, "velvet_gala.png", "file"),
)


def request(url, key, method="GET", file=None, field=None):
    headers = {"x-api-key": key}
    body = None
    if file is not None:
        boundary = "bingo-" + uuid.uuid4().hex
        body = (
            f"--{boundary}\r\nContent-Disposition: form-data; name=\"{field}\"; filename=\"{file.name}\"\r\n"
            "Content-Type: image/png\r\n\r\n"
        ).encode("ascii") + file.read_bytes() + f"\r\n--{boundary}--\r\n".encode("ascii")
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
    req = urllib.request.Request(url, headers=headers, data=body, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            payload = response.read()
            return json.loads(payload) if payload else {}
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"Roblox API returned HTTP {exc.code} for {method} {url}") from None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key-file", type=Path, required=True)
    parser.add_argument("--universe", required=True)
    args = parser.parse_args()
    key = args.key_file.read_text(encoding="utf-8-sig").strip()
    if not key or any(char.isspace() for char in key):
        raise SystemExit("API key file must contain one key with no internal whitespace")
    icons_dir = Path(__file__).resolve().parents[1] / "assets" / "bingo" / "offer-icons"
    for service, collection, offer_id, filename, field in ICONS:
        url = f"https://apis.roblox.com/{service}/universes/{args.universe}/{collection}/{offer_id}"
        icon_field = "iconImageAssetId" if collection == "developer-products" else "iconAssetId"
        default_icon = 88963008124478 if collection == "developer-products" else 133448903949274
        before = request(url + "/creator", key)
        old_icon = before.get(icon_field)
        if old_icon and old_icon != default_icon:
            print(f"existing {filename}: {old_icon}", flush=True)
            continue
        request(url, key, method="PATCH", file=icons_dir / filename, field=field)
        after = request(url + "/creator", key)
        new_icon = after.get(icon_field)
        if not new_icon or new_icon == old_icon:
            raise RuntimeError(f"Icon not assigned for {filename} ({offer_id})")
        print(f"uploaded {filename}: {new_icon}", flush=True)


if __name__ == "__main__":
    main()

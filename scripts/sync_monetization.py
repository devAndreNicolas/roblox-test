"""Create Bingo Noir offers in one Roblox universe, without duplicating names.

Usage: python scripts/sync_monetization.py --key-file PATH --universe 10772003576
The API key is read locally and is never printed or stored in this repository.
"""

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path


OFFERS = (
    ("developerProducts", "Punhado de Fichas", "Adiciona 120 Fichas ao saldo deste jogo.", 29),
    ("developerProducts", "Pacote de Fichas", "Adiciona 350 Fichas ao saldo deste jogo.", 79),
    ("developerProducts", "Maleta de Fichas", "Adiciona 800 Fichas ao saldo deste jogo.", 169),
    ("developerProducts", "Suborno do MC", "Adiciona uma unidade de Suborno ao estoque. Limite de um uso por jogador e dois por partida.", 149),
    ("gamePasses", "Dossiê Azul", "Tema permanente de cartela. Também pode ser obtido jogando.", 49),
    ("gamePasses", "Estrela de Palco", "Tema permanente de cartela. Também pode ser obtido jogando.", 99),
    ("gamePasses", "Selo do Clube", "Tema permanente de cartela. Também pode ser obtido por convite.", 99),
    ("gamePasses", "No Ar", "Tema permanente e exclusivo de cartela.", 99),
    ("gamePasses", "Veludo de Gala", "Tema permanente e exclusivo de cartela.", 149),
)


def request_json(url, key, method="GET", fields=None):
    headers = {"x-api-key": key}
    data = None
    if fields is not None:
        boundary = "bingo-" + uuid.uuid4().hex
        chunks = []
        for field, value in fields.items():
            chunks.append(
                f"--{boundary}\r\nContent-Disposition: form-data; name=\"{field}\"\r\n\r\n{value}\r\n".encode("utf-8")
            )
        chunks.append(f"--{boundary}--\r\n".encode("ascii"))
        data = b"".join(chunks)
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            body = response.read()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        # Do not print request headers or bodies: they contain the API key.
        raise RuntimeError(f"Roblox API returned HTTP {exc.code} for {method} {url}") from None


def list_offers(base, key, collection):
    found = {}
    page_token = ""
    while True:
        params = {"pageSize": "50"}
        if page_token:
            params["pageToken"] = page_token
        page = request_json(base + "/creator?" + urllib.parse.urlencode(params), key)
        for offer in page.get(collection, []):
            name = offer.get("name")
            if name in found:
                raise RuntimeError(f"Duplicate remote offer name: {name}")
            found[name] = offer
        page_token = page.get("nextPageToken") or ""
        if not page_token:
            return found


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key-file", type=Path, required=True)
    parser.add_argument("--universe", required=True)
    args = parser.parse_args()
    key = args.key_file.read_text(encoding="utf-8-sig").strip()
    if not key or any(char.isspace() for char in key):
        raise SystemExit("API key file must contain exactly one key with no internal whitespace")

    product_base = f"https://apis.roblox.com/developer-products/v2/universes/{args.universe}/developer-products"
    pass_base = f"https://apis.roblox.com/game-passes/v1/universes/{args.universe}/game-passes"
    bases = {"developerProducts": product_base, "gamePasses": pass_base}
    ids = {"developerProducts": {}, "gamePasses": {}}
    for collection, base in bases.items():
        existing = list_offers(base, key, collection)
        id_field = "productId" if collection == "developerProducts" else "gamePassId"
        for kind, name, description, price in OFFERS:
            if kind != collection:
                continue
            offer = existing.get(name)
            if offer is None:
                offer = request_json(
                    base,
                    key,
                    method="POST",
                    fields={"name": name, "description": description, "isForSale": "true", "price": str(price)},
                )
                print(f"created {name}: {offer.get(id_field)}", flush=True)
                time.sleep(0.5)
            else:
                print(f"existing {name}: {offer.get(id_field)}", flush=True)
            if not isinstance(offer.get(id_field), int) or offer[id_field] <= 0:
                raise RuntimeError(f"Missing {id_field} for {name}")
            ids[collection][name] = offer[id_field]
    print("ids=" + json.dumps(ids, ensure_ascii=False, sort_keys=True), flush=True)


if __name__ == "__main__":
    main()

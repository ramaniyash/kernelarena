#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the 24-hour RGym/EmbedBench hackathon scaffold."
    )
    parser.add_argument(
        "--domain",
        choices=("kernel", "firmware"),
        help="Validate only one domain plus the shared files.",
    )
    return parser.parse_args()


def check_path(repo_root: Path, rel_path: str, missing: list[str]) -> None:
    path = repo_root / rel_path
    if path.exists():
        print(f"[ok] {rel_path}")
        return

    print(f"[missing] {rel_path}")
    missing.append(rel_path)


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parent.parent
    manifest_path = (
        repo_root / "docs" / "kernelarena" / "hackathon-rgym-embedbench-mvp.json"
    )

    manifest = json.loads(manifest_path.read_text())
    missing: list[str] = []

    print(f"Validating {manifest['name']}")
    print()

    print("[shared]")
    for rel_path in manifest.get("required_files", []):
        check_path(repo_root, rel_path, missing)

    domains = [args.domain] if args.domain else list(manifest.get("domains", {}))

    for domain in domains:
        domain_spec = manifest["domains"][domain]
        print()
        print(f"[{domain}]")

        for rel_path in domain_spec.get("required_paths", []):
            check_path(repo_root, rel_path, missing)

        for task in domain_spec.get("tasks", []):
            print()
            print(f"{task['id']} ({task['priority']})")
            for rel_path in task.get("required_files", []):
                check_path(repo_root, rel_path, missing)

    print()
    if missing:
        print(f"Hackathon scaffold is incomplete: {len(missing)} missing path(s).")
        return 1

    print("Hackathon scaffold is in place.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

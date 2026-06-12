#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if grep -qx '\*\*Antigravity (macOS/Linux):\*' "$repo_root/README.md"; then
  echo "ERROR: README has mismatched bold delimiters for Antigravity (macOS/Linux)" >&2
  exit 1
fi

if ! grep -qx '\*\*Antigravity (macOS/Linux):\*\*' "$repo_root/README.md"; then
  echo "ERROR: README is missing the expected bold Antigravity heading" >&2
  exit 1
fi

echo "PASS"

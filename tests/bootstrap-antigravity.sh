#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! grep -q 'Automatic installation not supported for this OS' "$repo_root/bootstrap-antigravity.sh"; then
  echo "ERROR: bootstrap script is missing an explicit unsupported-OS branch for non-darwin/non-linux systems" >&2
  exit 1
fi

if grep -q 'read -p "   Remove temporary files? (y/n) "' "$repo_root/bootstrap-antigravity.sh" && ! grep -q 'if \[ -t 0 \]; then' "$repo_root/bootstrap-antigravity.sh"; then
  echo "ERROR: bootstrap cleanup prompt appears to be unconditional" >&2
  exit 1
fi

echo "PASS"

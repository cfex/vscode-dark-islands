#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"

cleanup() { rm -rf "$tmp_home"; }
trap cleanup EXIT

mkdir -p "$tmp_home/.config/Antigravity IDE/User" "$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-0.0.2" "$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-1.0.0" "$tmp_home/.antigravity-ide/extensions/other.extension"

printf '%s\n' '[{"identifier":{"id":"bwya77.islands-dark"}},{"identifier":{"id":"other.extension"}}]' > "$tmp_home/.antigravity-ide/extensions/extensions.json"

HOME="$tmp_home" OSTYPE=linux-gnu /bin/bash "$repo_root/uninstall-antigravity.sh" >/dev/null 2>&1

if [ -d "$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-1.0.0" ] || [ -d "$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-0.0.2" ]; then
  echo "ERROR: matching Islands Dark extension dirs were not fully removed" >&2
  exit 1
fi

if [ ! -d "$tmp_home/.antigravity-ide/extensions/other.extension" ]; then
  echo "ERROR: unrelated extension dir was removed" >&2
  exit 1
fi

echo "PASS"

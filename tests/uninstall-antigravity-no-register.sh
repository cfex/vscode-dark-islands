#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"
output_file="$tmp_home/uninstall-no-register.out"

cleanup() { rm -rf "$tmp_home"; }
trap cleanup EXIT

mkdir -p "$tmp_home/.config/Antigravity IDE/User" "$tmp_home/.antigravity-ide/extensions"

if HOME="$tmp_home" OSTYPE=linux-gnu /bin/bash "$repo_root/uninstall-antigravity.sh" >"$output_file" 2>&1; then
  :
else
  echo "uninstall-antigravity.sh exited nonzero" >&2
  cat "$output_file" >&2
  exit 1
fi

if grep -q "✓ Extension unregistered" "$output_file"; then
  echo "ERROR: green unregister line should not be printed when nothing was removed" >&2
  cat "$output_file" >&2
  exit 1
fi

if ! grep -Eq "Extension was not registered|Could not update extensions\.json|No extensions\.json found|not found" "$output_file"; then
  echo "ERROR: expected a neutral/warning unregister message" >&2
  cat "$output_file" >&2
  exit 1
fi

echo "PASS"

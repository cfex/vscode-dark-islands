#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"
output_file="$tmp_home/uninstall-antigravity.out"

cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT

settings_dir="$tmp_home/.config/Antigravity IDE/User"
settings_file="$settings_dir/settings.json"
backup_file="$settings_file.pre-islands-dark"
ext_dir="$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-0.0.2"
ext_json="$tmp_home/.antigravity-ide/extensions/extensions.json"

mkdir -p "$settings_dir" "$ext_dir" "$(dirname "$ext_json")"
printf '%s\n' '{"workbench.colorTheme":"Islands Dark"}' > "$settings_file"
printf '%s\n' '{"workbench.colorTheme":"Default Dark+"}' > "$backup_file"
printf '%s\n' '[{"identifier":{"id":"bwya77.islands-dark"}},{"identifier":{"id":"other.extension"}}]' > "$ext_json"

if HOME="$tmp_home" OSTYPE=linux-gnu /bin/bash "$repo_root/uninstall-antigravity.sh" >"$output_file" 2>&1; then
  :
else
  echo "uninstall-antigravity.sh exited nonzero" >&2
  cat "$output_file" >&2
  exit 1
fi

if [ "$(cat "$settings_file")" != '{"workbench.colorTheme":"Default Dark+"}' ]; then
  echo "ERROR: settings.json was not restored from Antigravity backup" >&2
  cat "$output_file" >&2
  exit 1
fi

if [ -e "$ext_dir" ]; then
  echo "ERROR: Antigravity extension directory was not removed" >&2
  cat "$output_file" >&2
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  if node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1], 'utf8')); process.exit(data.some(e => e.identifier?.id === 'bwya77.islands-dark') ? 1 : 0);" "$ext_json"; then
    :
  else
    echo "ERROR: Antigravity extension was not removed from extensions.json" >&2
    cat "$output_file" >&2
    exit 1
  fi
fi

if ! grep -q "Islands Dark has been uninstalled from Antigravity IDE" "$output_file"; then
  echo "ERROR: uninstall output did not mention Antigravity IDE completion" >&2
  cat "$output_file" >&2
  exit 1
fi

echo "PASS"

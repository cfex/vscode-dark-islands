#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"
tmp_bin="$tmp_home/bin"
output_file="$tmp_home/install-antigravity.out"

cleanup() { rm -rf "$tmp_home"; }
trap cleanup EXIT

mkdir -p "$tmp_bin" "$tmp_home/.antigravity-ide/extensions" "$tmp_home/.gemini/antigravity-ide"

cat >"$tmp_bin/agy-ide" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$tmp_bin/agy-ide"

printf '%s\n' '[{"identifier":{"id":"other.extension"},"version":"1.2.3"}]' > "$tmp_home/.antigravity-ide/extensions/extensions.json"

if HOME="$tmp_home" PATH="$tmp_bin:$PATH" OSTYPE=linux-gnu /bin/bash "$repo_root/install-antigravity.sh" >"$output_file" 2>&1; then
  :
else
  echo "install-antigravity.sh exited nonzero" >&2
  cat "$output_file" >&2
  exit 1
fi

ext_dir="$tmp_home/.antigravity-ide/extensions/bwya77.islands-dark-0.0.2"
if [ ! -d "$ext_dir" ]; then
  echo "ERROR: expected package.json-derived extension dir at $ext_dir" >&2
  cat "$output_file" >&2
  exit 1
fi

if [ ! -f "$tmp_home/.antigravity-ide/extensions/extensions.json" ]; then
  echo "ERROR: extensions.json was deleted" >&2
  cat "$output_file" >&2
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1], 'utf8')); if (!Array.isArray(data) || !data.some(e => e.identifier?.id === 'other.extension')) process.exit(1);" "$tmp_home/.antigravity-ide/extensions/extensions.json" || {
    echo "ERROR: unrelated extension entry was not preserved in extensions.json" >&2
    cat "$output_file" >&2
    exit 1
  }
fi

echo "PASS"

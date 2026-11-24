#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
mkdir "$tmp/bin" "$tmp/data"
export DATA_DIR="$tmp/data" REPOS_FILE="$tmp/repos.txt" PATH="$tmp/bin:$PATH"
printf 'previous snapshot\n' > "$DATA_DIR/owner--bad.json"
printf 'owner/bad\nowner/good' > "$REPOS_FILE"

cat > "$tmp/bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  "auth status") exit 0 ;;
  *name=bad*) exit 1 ;;
  *name=good*) printf '{"data": {"repository": {}}}\n' ;;
  *) exit 99 ;;
esac
GH
chmod +x "$tmp/bin/gh"

if "$root/fetch.sh"; then
  echo 'expected a failed fetch to return a nonzero status' >&2
  exit 1
fi
grep -Fx 'previous snapshot' "$DATA_DIR/owner--bad.json"
grep -Fx '{"data": {"repository": {}}}' "$DATA_DIR/owner--good.json"
